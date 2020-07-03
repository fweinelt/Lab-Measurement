package Lab::Moose::Sweep::Continuous::Magnet;

#ABSTRACT: Continuous sweep of magnetic field

use v5.20;

=head1 SYNOPSIS

 use Lab::Moose;

 #
 # 1D sweep of magnetic field
 #
 
 my $ips = instrument(
     type => 'OI_Mercury::Magnet'
     connection_type => ...,
     connection_options => {...}
 );

 my $multimeter = instrument(...);
 
 my $sweep = sweep(
     type => 'Continuous::Magnet',
     instrument => $ips,
     from => -1, # Tesla
     to => 1,
     rate => 1, (Tesla/min, always positive)
     interval => 0.5, # one measurement every 0.5 seconds
 );

 my $datafile = sweep_datafile(columns => ['B-field', 'current']);
 $datafile->add_plot(x => 'B-field', y => 'current');
 
 my $meas = sub {
     my $sweep = shift;
     my $field = $ips->get_field();
     my $current = $multimeter->get_value();
     $sweep->log('B-field' => $field, current => $current);
 };

 $sweep->start(
     datafiles => [$datafile],
     measurement => $meas,
 );

=cut

use Moose;
use Carp;
use Time::HiRes 'time';

extends 'Lab::Moose::Sweep::Continuous';

has filename_extension => ( is => 'ro', isa => 'Str', default => 'Field=' );

# field value for filename extensions.
# Only used if separate datafiles are produces for different fields.
# Should use 'step' sweep for this in most cases.
sub get_value {
    my $self = shift;
    my $from = $self->from;
    my $to   = $self->to;
    my $rate = abs( $self->rate );
    my $sign = $to > $from ? 1 : -1;

    # Only estimate field.
    # Do not query field for performance reasons.
    # Will give wrong results, if the sweep slowly saturates to the setpoint.

    my $t0 = $self->start_time();
    if ( not defined $t0 ) {
        croak "sweep not started";
    }
    my $t = time();
    return $from + ( $t - $to ) * $sign * $rate / 60;
}

__PACKAGE__->meta->make_immutable();
1;
