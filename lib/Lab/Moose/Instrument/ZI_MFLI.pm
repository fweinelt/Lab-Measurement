package Lab::Moose::Instrument::ZI_MFLI;

#ABSTRACT: Zurich Instruments MFLI Lock-in Amplifier

use v5.20;

use Moose;
use MooseX::Params::Validate;
use Lab::Moose::Instrument::Cache;
use Carp;
use namespace::autoclean;
use Moose::Util::TypeConstraints 'enum';
use Lab::Moose::Instrument qw/validated_setter validated_getter/;
use Lab::Moose::Instrument::Cache;
use constant {
    ZI_LIST_NODES_RECURSIVE => 1,
    ZI_LIST_NODES_ABSOLUTE  => 2,
};

extends 'Lab::Moose::Instrument::Zhinst';

=head1 SYNOPSIS

 use Lab::Moose;

 my $mfli = instrument(
     type => 'ZI_MFLI',
     connection_type => 'Zhinst',
     oscillator => 1, # 0 is default
     connection_options => {
         host => '132.188.12.13',
         port => 8004,
     });

 $mfli->set_frequency(value => 10000);

 # Set time constants of first two demodulators to 0.5 sec:
 $mfli->set_tc(demod => 0, value => 0.5);
 $mfli->set_tc(demod => 1, value => 0.5);

 # Read out demodulators:
 my $xy_0 = $mfli->get_xy(demod => 0);
 my $xy_1 = $mfli->get_xy(demod => 1);
 say "x_0, y_0: ", $xy_0->{x}, ", ", $xy_0->{y};

=cut

# FIXME: warn/croak on AUTO freq, bw, ...

has num_demods => (
    is       => 'ro',
    isa      => 'Int',
    builder  => '_get_num_demods',
    lazy     => 1,
    init_arg => undef,
);

my %oscillator_arg
    = ( oscillator => { isa => 'Lab::Moose::PosInt', optional => 1 } );
has oscillator => (
    is      => 'ro',
    isa     => 'Lab::Moose::PosInt',
    default => 0
);

sub _get_oscillator {
    my $self = shift;
    my %args = @_;
    my $osc  = delete $args{oscillator};
    if ( not defined $osc ) {
        $osc = $self->oscillator();
    }
    $osc;
}

sub _get_num_demods {
    my $self  = shift;
    my $nodes = $self->list_nodes(
        path => '/',
        mask => ZI_LIST_NODES_ABSOLUTE | ZI_LIST_NODES_RECURSIVE
    );

    my @demods = $nodes =~ m{^/dev\w+/demods/[0-9]+/}gmi;
    @demods = map {
        my $s = $_;
        $s =~ m{/([0-9]+)/$};
        $1;
    } @demods;
    my %hash = map { $_ => 1 } @demods;
    @demods = keys %hash;
    if ( @demods == 0 ) {
        croak "did not find any demods";
    }
    return ( @demods + 0 );
}

=head1 METHODS

If the MFLI has the Impedance Analyzer option, calling some of the following
setter options might be without effect. E.g. if the B<Bandwith Control> option
of the Impedance Analyzer module is set, manipulating the time constant with
C<set_tc> will not work.

=head2 get_frequency

 # Get oscillator frequency of default oscillator.
 my $freq = $mfli->get_frequency();


 my $freq = $mfli->get_frequency(oscillator => ...);

=cut

cache frequency => ( getter => 'get_frequency' );

sub get_frequency {
    my ( $self, %args ) = validated_hash(
        \@_,
        %oscillator_arg,
    );

    my $osc = $self->_get_oscillator(%args);

    return $self->cached_frequency(
        $self->get_value(
            path => $self->device() . "/oscs/$osc/freq",
            type => 'D'
        )
    );

}

sub get_frq {
    my $self = shift;
    return $self->get_frequency(@_);
}

=head2 get_frq

Alias for L</get_frequency>.

=cut

=head2 set_frequency

 $mfli->set_frequency(value => 10000);

Set oscillator frequency.

=cut

sub set_frequency {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        %oscillator_arg,
        value => { isa => 'Num' },
    );
    my $osc = $self->_get_oscillator(%args);
    return $self->cached_frequency(
        $self->sync_set_value(
            path  => $self->device() . "/oscs/$osc/freq", type => 'D',
            value => $value
        )
    );

}

=head2 set_frq

Alias for L</set_frequency>.

=cut

sub set_frq {
    my $self = shift;
    return $self->set_frequency(@_);
}

=head2 get_voltage_sens

 my $sens = $mfli->get_voltage_sens();

Get sensitivity (range) of voltage input.

=cut

cache voltage_sens => ( getter => 'voltage_sens' );

sub get_voltage_sens {
    my $self = shift;
    return $self->cached_voltage_sens(
        $self->get_value(
            path => $self->device() . "/sigins/0/range",
            type => 'D'
        )
    );
}

=head2 set_voltage_sens

 $mfli->set_voltage_sens(value => 1);

Set sensitivity (range) of voltage input.

=cut

sub set_voltage_sens {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => 'Num' },
    );

    return $self->cached_voltage_sens(
        $self->sync_set_value(
            path  => $self->device() . "/sigins/0/range",
            type  => 'D',
            value => $value
        )
    );
}

=head2 get_current_sens

 my $sens = $mfli->get_current_sens();

Get sensitivity (range) of current input.

=cut

cache current_sens => ( getter => 'get_current_sens' );

sub get_current_sens {
    my $self = shift;
    return $self->cached_current_sens(
        $self->get_value(
            path => $self->device() . "/currins/0/range",
            type => 'D'
        )
    );
}

=head2 set_current_sens

 $mfli->set_current_sens(value => 100e-6);

Set sensitivity (range) of current input.

=cut

sub set_current_sens {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => 'Num' },
    );

    return $self->cached_current_sens(
        $self->sync_set_value(
            path  => $self->device() . "/currins/0/range",
            type  => 'D',
            value => $value
        )
    );
}

=head2 get_amplitude_range

 my $amplitude_range = $mfli->get_amplitude_range();

Get range of voltage output.

=cut

cache amplitude_range => ( getter => 'get_amplitude_range' );

sub get_amplitude_range {
    my $self = shift;
    return $self->cached_amplitude_range(
        $self->get_value(
            path => $self->device() . "/sigouts/0/range",
            type => 'D'
        )
    );
}

=head2 set_amplitude_range

 $mfli->set_amplitude_range(value => 1);

Set amplitude of voltage output.

=cut

sub set_amplitude_range {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => 'Num' }
    );

    return $self->cached_amplitude_range(
        $self->sync_set_value(
            path  => $self->device() . "/sigouts/0/range",
            type  => 'D',
            value => $value
        )
    );
}

=head2 set_output_status

 $mfli->set_output_status(value => 1); # Enable output
 $mfli->set_output_status(value => 0); # Disable output

=cut

sub set_output_status {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => enum( [ 0, 1 ] ) },
    );

    return $self->sync_set_value(
        path  => $self->device() . "/sigouts/0/on",
        type  => 'I',
        value => $value,
    );
}

cache offset_voltage => ( getter => 'get_offset_voltage' );

=head2 get_offset_voltage

 my $offset = $mfli->get_offset_voltage();

Get DC offset.

=cut

sub get_offset_voltage {
    my $self = shift;
    return $self->cached_offset_voltage(
        $self->get_value(
            path => $self->device() . "/sigouts/0/offset",
            type => 'D'
        )
    );
}

=head2 set_offset_voltage

 $mfli->set_offset_voltage(value => 1e-3);

Set DC offset.
 
=cut

sub set_offset_voltage {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => 'Num' }
    );
    return $self->cached_offset_voltage(
        $self->sync_set_value(
            path  => $self->device() . "/sigouts/0/offset",
            type  => 'D',
            value => $value
        )
    );
}

=head2 set_offset_status

 $mfli->set_offset_status(value => 1); # Enable offset voltage
 $mfli->set_offset_status(value => 0); # Disable offset voltage

=cut

sub set_offset_status {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => enum( [ 0, 1 ] ) },
    );

    return $self->sync_set_value(
        path  => $self->device() . "/sigouts/0/add",
        type  => 'I',
        value => $value,
    );
}

#
# compatibility with XPRESS::Sweep::Voltage sweep
#

sub get_level {
    my $self = shift;
    return $self->get_offset_voltage();
}

sub sweep_to_level {
    my $self = shift;
    my ( $target, $time, $stepwidth ) = @_;
    $self->set_offset_voltage( value => $target );
}

sub config_sweep {
    croak "ZI_MFLI only supports step/list sweep with 'jump => 1'";
}

sub set_voltage {
    my $self  = shift;
    my $value = shift;
    $self->set_offset_voltage( value => $value );
}

my %adcselect_signals = (
    0   => 'sigin1',
    1   => 'currin1',
    2   => 'trigger1',
    3   => 'trigger2',
    4   => 'auxout1',
    5   => 'auxout2',
    6   => 'auxout3',
    7   => 'auxout4',
    8   => 'auxin1',
    9   => 'auxin2',
    174 => 'constant_input',
);
my %adcselect_signals_revers = reverse %adcselect_signals;
my @adcselect_signals        = values %adcselect_signals;

#
# Demodulators
#

=head2 set_input/get_input

 $mfli->set_input(demod => 0, value => 'CurrIn1');
 my $signal = $mfli->get_input(demod => 0);

Valid inputs:   currin1, trigger1, trigger2, auxout1, auxout2, auxout3, auxout4, auxin1, auxin2, constant_input

t
=cut

sub set_input {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => enum( [@adcselect_signals] ) },
        demod => { isa => 'Int' },
    );

    $value = $adcselect_signals_revers{$value};
    my $demod = delete $args{demod};
    $self->sync_set_value(
        path => $self->device() . "/demods/$demod/adcselect",
        type => 'I', value => $value
    );
}

sub get_input {
    my $self = shift;
    my ($demod) = validated_list(
        \@_, demod => { isa => 'Int' },
    );
    my $v = $self->get_value(
        path => $self->device() . "/demods/$demod/adcselect",
        type => 'I'
    );
    return $adcselect_signals{$v};
}

=head2 get_phase

 my $phase = $mfli->get_phase(demod => 0);

Get demodulator phase shift.

=cut

cache phase => ( getter => 'get_phase', index_arg => 'demod' );

sub get_phase {
    my $self = shift;
    my ($demod) = validated_list(
        \@_,
        demod => { isa => 'Int' },
    );

    return $self->cached_phase(
        demod => $demod,
        value => $self->get_value(
            path => $self->device() . "/demods/$demod/phaseshift",
            type => 'D'
        )
    );
}

=head2 set_phase

 $mfli->set_phase(demod => 0, value => 10);

Set demodulator phase.

=cut

sub set_phase {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => 'Num' },
        demod => { isa => 'Int' },
    );
    my $demod = delete $args{demod};
    return $self->cached_phase(
        demod => $demod,
        value => $self->sync_set_value(
            path => $self->device() . "/demods/$demod/phaseshift",
            type => 'D', value => $value
        )
    );
}

=head2 get_tc

 my $tc = $mfli->get_tc(demod => 0);

Get demodulator time constant.

=cut

cache tc => ( getter => 'get_tc', index_arg => 'demod' );

sub get_tc {
    my $self = shift;
    my ($demod) = validated_list(
        \@_,
        demod => { isa => 'Int' },
    );
    return $self->cached_tc(
        demod => $demod,
        value => $self->get_value(
            path => $self->device() . "/demods/$demod/timeconstant",
            type => 'D'
        )
    );
}

=head2 set_tc

 $mfli->set_tc(demod => 0, value => 0.5);

Set demodulator time constant.

=cut

sub set_tc {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => 'Num' },
        demod => { isa => 'Int' },
    );
    my $demod = delete $args{demod};
    return $self->cached_tc(
        demod => $demod,
        value => $self->sync_set_value(
            path  => $self->device() . "/demods/$demod/timeconstant",
            type  => 'D',
            value => $value
        )
    );
}

=head2 get_order

 my $order = $mfli->get_order(demod => 0);

Get demodulator filter order.

=cut

cache order => ( getter => 'get_order', index_arg => 'demod' );

sub get_order {
    my $self = shift;
    my ($demod) = validated_list(
        \@_,
        demod => { isa => 'Int' },
    );
    return $self->cached_order(
        demod => $demod,
        value => $self->get_value(
            path => $self->device() . "/demods/$demod/order",
            type => 'I'
        )
    );
}

=head2 set_order

 $mfli->set_order(demod => 0, order => 4);

Set demodulator filter order.

=cut

sub set_order {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => 'Int' },
        demod => { isa => 'Int' },
    );
    my $demod = delete $args{demod};
    return $self->cached_order(
        demod => $demod,
        value => $self->sync_set_value(
            path  => $self->device() . "/demods/$demod/order", type => 'I',
            value => $value
        )
    );
}

=head2 get_amplitude

 # set amplitude for default oscillator
 my $amplitude = $mfli->get_amplitude();

 # set amplitude of oscillator 1
 my $amplitude = $mfli->get_amplitude(oscillator => 1);

Get peak amplitude of voltage output. The default oscillator is determined by the C<oscillator> attribute.

=cut

cache amplitude => ( getter => 'get_amplitude' );

sub get_amplitude {
    my ( $self, %args ) = validated_getter(
        \@_,
        demod => { isa => 'Int' },
    );

    my $demod = delete $args{demod};
    return $self->cached_amplitude(
        $self->get_value(
            path => $self->device() . "/sigouts/0/amplitudes/$demod",
            type => 'D'
        )
    );
}

=head2 set_amplitude

 $mfli->set_amplitude(value => 300e-3);
 $mfli->set_amplitude(value => ..., demod => ...);

Set peak amplitude of voltage output. The oscillator is determined by the C<oscillator> attribute.

=cut

sub set_amplitude {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => 'Num' },
        demod => { isa => 'Int' },
    );
    my $osc   = $self->_get_oscillator(%args);
    my $demod = delete $args{demod};
    return $self->cached_amplitude(
        $self->sync_set_value(
            path  => $self->device() . "/sigouts/0/amplitudes/$demod",
            type  => 'D',
            value => $value
        )
    );
}

=head2 get_amplitude_rms/set_amplitude_rms

Get/Set root mean square value of amplitude. These are wrappers around get_amplitude/set_amplitude and divide/multiply the peak amplitude with sqrt(2).

=cut

sub get_amplitude_rms {
    my $self  = shift;
    my $value = $self->get_amplitude(@_);
    return $value / sqrt(2);
}

sub set_amplitude_rms {
    my $self = shift;
    my %args = @_;
    $args{value} *= sqrt(2);
    return $self->set_amplitude(%args);
}

#
# Output commands
#

=head2 get_xy

 my $xy_0 = $mfli->get_xy(demod => 0);
 my $xy_1 = $mfli->get_xy(demod => 1);
 
 printf("x: %g, y: %g\n", $xy_0->{x}, $xy_0->{y});

Get demodulator X and Y output measurement values.

=cut

sub get_xy {
    my $self = shift;
    my ($demod) = validated_list(
        \@_,
        demod => { isa => 'Int' },
    );
    my $demod_sample = $self->get_value(
        path => $self->device() . "/demods/$demod/sample",
        type => 'Demod'
    );

    return { x => $demod_sample->{x}, y => $demod_sample->{y} };
}

__PACKAGE__->meta()->make_immutable();

1;
