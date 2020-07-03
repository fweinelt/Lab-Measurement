package Lab::XPRESS::Sweep::Amplitude;

#ABSTRACT: Amplitude sweep of AC voltage/current

use v5.20;

use Lab::XPRESS::Sweep;
use Time::HiRes qw/usleep/, qw/time/;
use strict;

our @ISA = ('Lab::XPRESS::Sweep');

sub new {
    my $proto                  = shift;
    my @args                   = @_;
    my $class                  = ref($proto) || $proto;
    my $self->{default_config} = {
        id                  => 'Amplitude_Sweep',
        filename_extension  => 'AMP=',
        interval            => 1,
        points              => [],
        rate                => [1],
        mode                => 'step',
        allowed_instruments => [
            qw/Lab::Instrument::SR830 Lab::Moose::Instrument::ZI_MFLI Lab::Moose::Instrument::ZI_MFIA/
        ],
        allowed_sweep_modes => [ 'list', 'step' ],
        number_of_points    => [undef]
    };

    $self = $class->SUPER::new( $self->{default_config}, @args );
    bless( $self, $class );

    return $self;
}

sub go_to_sweep_start {
    my $self = shift;

    # go to start:
    $self->{config}->{instrument}
        ->set_amplitude( { value => @{ $self->{config}->{points} }[0] } );
}

sub start_continuous_sweep {
    my $self = shift;

    return;

}

sub go_to_next_step {
    my $self = shift;

    $self->{config}->{instrument}->set_amplitude(
        { value => @{ $self->{config}->{points} }[ $self->{iterator} ] } );

}

sub exit_loop {
    my $self = shift;

    if ( $self->{config}->{mode} =~ /step|list/ ) {
        if (
            not
            defined @{ $self->{config}->{points} }[ $self->{iterator} + 1 ] )
        {
            return 1;
        }
        else {
            return 0;
        }
    }
}

sub get_value {
    my $self = shift;
    return $self->{config}->{instrument}->get_amplitude();
}

sub exit {
    my $self = shift;
    $self->{config}->{instrument}->abort();
}

1;

=encoding utf8

=head1 SYNOPSIS

    use Lab::Measurement
	
	my $sweep_amplitude = Sweep('Amplitude',
		{
		instrument => $lock_in,
		points => [0,1],
		stepwidth => [0.1],
		mode => 'step',		
		backsweep => 0 
		});
		


=head1 CAVEATS/BUGS

probably none

=head1 SEE ALSO

=over 4

=item L<Lab::XPRESS::Sweep>

=back

=cut
