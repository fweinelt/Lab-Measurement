package Lab::Moose::Instrument::HP34410A;

#ABSTRACT: HP 34410A digital multimeter.

use v5.20;


use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Params::Validate;
use Lab::Moose::Instrument qw/validated_getter validated_setter/;
use Carp;
use Lab::Moose::Instrument::Cache;
use namespace::autoclean;

extends 'Lab::Moose::Instrument';

with qw(
    Lab::Moose::Instrument::Common
    Lab::Moose::Instrument::SCPI::Sense::Function
    Lab::Moose::Instrument::SCPI::Sense::Impedance
    Lab::Moose::Instrument::SCPI::Sense::NPLC
    Lab::Moose::Instrument::SCPI::Sense::Null
    Lab::Moose::Instrument::SCPI::Sense::Range
    Lab::Moose::Instrument::AdjustRange
);

sub BUILD {
    my $self = shift;
    $self->clear();
    $self->cls();
}

around default_connection_options => sub {
    my $orig     = shift;
    my $self     = shift;
    my $options  = $self->$orig();
    my $usb_opts = { vid => 0x03f0 };    # what is PID??

    $options->{USB} = $usb_opts;
    $options->{'VISA::USB'} = $usb_opts;
    $options->{'Socket'} = { port => 5025 };

    return $options;
};

=head1 SYNOPSIS

 my $dmm = instrument(
    type => 'HP34410A',
    connection_type => 'VXI11',
    connection_options => {host => '192.168.3.27'},
    );

 $dmm->sense_range(value => 10);
 $dmm->sense_nplc(value => 2);  
      
 my $voltage = $dmm->get_value();
 
=cut

=head1 METHODS

Used roles:

=over

=item L<Lab::Moose::Instrument::SCPI::Sense::Function>

=item L<Lab::Moose::Instrument::SCPI::Sense::Impedance>

=item L<Lab::Moose::Instrument::SCPI::Sense::NPLC>

=item L<Lab::Moose::Instrument::SCPI::Sense::Null>


=item L<Lab::Moose::Instrument::SCPI::Sense::Range>


=back
    
=head2 get_value

 my $voltage = $dmm->get_value();

Perform voltage/current measurement.

=cut

sub get_value {
    my ( $self, %args ) = validated_getter( \@_ );
    return $self->query( command => ':read?', %args );
}

### Required methods of AdjustRange role

sub allowed_ranges {
    my $self     = shift;
    my $function = $self->cached_sense_function();
    if ( $function eq 'VOLT' ) {
        return [ 0.1, 1, 10, 100, 1000 ];
    }
    elsif ( $function eq 'CURR' ) {
        return [ 1e-4, 1e-3, 1e-2, 1e-1, 1, 3 ];
    }
    else {
        croak "function $function not yet supported";
    }
}

sub set_range {
    my $self = shift;
    return $self->sense_range(@_);
}

sub get_cached_range {
    my $self = shift;
    return $self->cached_sense_range(@_);
}

__PACKAGE__->meta()->make_immutable();

1;
