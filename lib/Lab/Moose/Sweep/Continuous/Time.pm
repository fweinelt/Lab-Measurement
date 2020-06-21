package Lab::Moose::Sweep::Continuous::Time;

#ABSTRACT: Time sweep

=head1 SYNOPSIS

 use Lab::Moose;

 my $sweep = sweep(
     type => 'Continuous::Time',
     interval => 0.5, # optional, default is 0 (no delay)
     duration => 60
 );

 # Multiple segments with different intervals
 my $sweep = sweep(
     type => 'Continuous::Time',
     # 60s with 0.5s interval followed by 120s with 1s interval
     durations => [60, 120],
     intervals => [0.5, 1],
 );

=cut

use 5.010;
use Moose;
use Time::HiRes qw/time sleep/;
use Carp;

extends 'Lab::Moose::Sweep::Continuous';

#
# Public attributes
#

has [qw/ +instrument +points +rates/] => ( required => 0 );

has duration => ( is => 'ro', isa => 'Lab::Moose::PosNum' );

has durations => (
    is      => 'ro',
    isa     => 'ArrayRef[Lab::Moose::PosNum]',
    traits  => ['Array'],
    handles => {
        get_duration  => 'get',   shift_durations => 'shift',
        num_durations => 'count', durations_array => 'elements',
    },
    writer => '_durations'
);

# TODO: make duration optional => infinite

sub BUILD {
    my $self = shift;

    # Do not mess with intervals/durations attribute arrays. Make copies of them.
    my @intervals;
    my @durations;

    if ( defined $self->interval ) {
        if ( defined $self->intervals ) {
            croak "Use either interval or intervals attribute";
        }
        @intervals = ( $self->interval );
    }
    elsif ( defined $self->intervals ) {
        @intervals = $self->intervals_array;
    }
    else {
        # default interval
        @intervals = (0);
    }

    if ( defined $self->duration ) {
        if ( defined $self->durations ) {
            croak "Use either duration or durations attribute";
        }
        @durations = ( $self->duration );
    }
    elsif ( defined $self->durations ) {
        @durations = $self->durations_array;
    }
    else {
        croak "Missing mandatory duration or durations argument";
    }

    $self->_intervals( \@intervals );
    $self->_durations( \@durations );

    if ( $self->num_intervals < 1 ) {
        croak "need at least one interval";
    }

    if ( $self->num_intervals != $self->num_durations ) {
        croak "need same number of intervals and durations";
    }
}

sub go_to_sweep_start {
    my $self = shift;
    $self->reset_index();
    $self->reset_points_index();
    $self->inc_points_index();
}

sub start_sweep {
    my $self = shift;
    $self->_start_time( time() );
}

sub sweep_finished {
    my $self = shift;

    my $duration = $self->get_duration( $self->points_index - 1 );

    if ( time() - $self->start_time < $duration ) {

        # still in duration
        return 0;
    }

    # duration is finished.
    $self->inc_points_index();

    # Are there more durations?
    if ( $self->points_index < $self->num_durations() ) {
        $self->reset_index();
        $self->start_sweep();
        return 0;
    }
    else {
        return 1;
    }
}

sub get_value {
    my $self = shift;
    return time();
}

__PACKAGE__->meta->make_immutable();
1;
