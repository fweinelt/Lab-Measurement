package Lab::Moose::Sweep::Step::Magnet;

#ABSTRACT: Step/list sweep of magnetic field

=head1 SYNOPSIS

 my $sweep = sweep(
     type => 'Step::Magnet',
     instrument => $ips,
     from => -1, # Tesla
     to => 1,
     step => 0.1, # steps of 0.1 Tesla
     rate => 1, # Tesla/min, mandatory, always positive
     persistent_mode => 1, # use persistent mode (default: 0)
 );

=head1 Description

Step sweep with following properties:

=over

=item *

 Uses instruments C<sweep_to_field> method to set the field.

=item *

Default filename extension: C<'Field='>

=back

=cut

use 5.010;
use Moose;
use Lab::Moose::Countdown;

extends 'Lab::Moose::Sweep::Step';
has instrument =>
    ( is => 'ro', isa => 'Lab::Moose::Instrument', required => 1 );

has start_rate =>
    ( is => 'ro', isa => 'Lab::Moose::PosNum', writer => '_start_rate' );
has rate => ( is => 'ro', isa => 'Lab::Moose::PosNum', required => 1 );

has _current_rate => ( is => 'rw', isa => 'Lab::Moose::PosNum' );

has filename_extension => ( is => 'ro', isa => 'Str', default => 'Field=' );

has setter => ( is => 'ro', isa => 'CodeRef', builder => '_build_setter' );

has persistent_mode => ( is => 'ro', isa => 'Bool', default => 0 );

sub BUILD {
    my $self = shift;
    if ( not defined $self->start_rate ) {
        $self->_start_rate( $self->rate );
    }

    if ( $self->persistent_mode ) {
        $self->_current_rate( $self->start_rate );

        # the _field_setter needs a well-defined initial state
        $self->set_persistent_mode();
    }
}

before 'go_to_sweep_start' => sub {
    my $self = shift;
    $self->_current_rate( $self->start_rate );
};

after 'go_to_sweep_start' => sub {
    my $self = shift;
    $self->_current_rate( $self->rate );
};

sub _build_setter {
    return \&_field_setter;
}

sub set_persistent_mode {
    my $self       = shift;
    my $instrument = $self->instrument();
    if ( $instrument->in_persistent_mode ) {
        return;
    }

    $instrument->heater_off();
    my $rate = $self->_current_rate;
    $instrument->sweep_to_field( target => 0, rate => $rate );
    countdown( 10, "Set persistent mode: " );
}

sub unset_persistent_mode {
    my $self       = shift;
    my $instrument = $self->instrument();
    if ( not $instrument->in_persistent_mode ) {
        return;
    }
    my $persistent_field = $instrument->get_persistent_field();
    my $rate             = $self->_current_rate;
    $instrument->sweep_to_field( target => $persistent_field, rate => $rate );
    $instrument->heater_on();
}

sub _field_setter {
    my $self  = shift;
    my $value = shift;
    my $rate  = $self->_current_rate;
    if ( $self->persistent_mode ) {
        $self->unset_persistent_mode();
    }

    $self->instrument->sweep_to_field( target => $value, rate => $rate );

    if ( $self->persistent_mode ) {
        $self->set_persistent_mode();
    }
}

__PACKAGE__->meta->make_immutable();
1;
