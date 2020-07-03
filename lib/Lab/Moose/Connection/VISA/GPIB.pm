package Lab::Moose::Connection::VISA::GPIB;

#ABSTRACT: GPIB frontend to National Instruments' VISA library.

use v5.20;

=head1 SYNOPSIS

 use Lab::Moose
 my $instrument = instrument(
     type => 'random_instrument',
     connection_type => 'VISA::GPIB',
     connection_options => {gpib_address => 10}
 );

=head1 DESCRIPTION

Creates a GPIB resource name for the VISA backend. Valid connection options:
gpib_address (or pad), sad (secondary address), board_index (defaults to 0).

=cut


use Moose;
use Moose::Util::TypeConstraints qw(enum);

use Carp;

use namespace::autoclean;

extends 'Lab::Moose::Connection::VISA';

has pad => (
    is        => 'ro',
    isa       => enum( [ ( 0 .. 30 ) ] ),
    predicate => 'has_pad',
    writer    => '_pad'
);

has gpib_address => (
    is        => 'ro',
    isa       => enum( [ ( 0 .. 30 ) ] ),
    predicate => 'has_gpib_address'
);

has sad => (
    is        => 'ro',
    isa       => enum( [ 0, ( 96 .. 126 ) ] ),
    predicate => 'has_sad',
);

has board_index => (
    is      => 'ro',
    isa     => 'Int',
    default => 0,
);

has '+resource_name' => (
    required => 0,
);

sub gen_resource_name {
    my $self = shift;
    if ( $self->has_gpib_address() ) {
        $self->_pad( $self->gpib_address() );
    }

    if ( not $self->has_pad() ) {
        croak "no primary GPIB address provided";
    }

    my $resource_name = "GPIB" . $self->board_index() . '::' . $self->pad();
    if ( $self->has_sad ) {
        $resource_name .= '::' . $self->sad();
    }
    $resource_name .= '::INSTR';
    return $resource_name;
}

__PACKAGE__->meta->make_immutable();

1;
