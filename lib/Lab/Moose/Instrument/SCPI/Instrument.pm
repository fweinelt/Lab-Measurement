package Lab::Moose::Instrument::SCPI::Instrument;

#ABSTRACT: Role for SCPI INSTrument subsystem.

use v5.20;

use Moose::Role;
use Lab::Moose::Instrument::Cache;
use Lab::Moose::Instrument qw/validated_getter validated_setter/;
use MooseX::Params::Validate;
use Carp;

use namespace::autoclean;

=head1 METHODS

=head2 instrument_nselect_query

=head2 instrument_nselect

Query/Set instrument channel for multi-channel instruments.

=head2 

=cut

cache instrument_nselect => ( getter => 'instrument_nselect_query' );

sub instrument_nselect_query {
    my ( $self, %args ) = validated_getter( \@_ );

    return $self->cached_instrument_nselect(
        $self->query( command => 'INST:NSEL?', %args ) );
}

sub instrument_nselect {
    my ( $self, $value, %args ) = validated_setter( \@_ );

    $self->write( command => "INST:NSEL $value", %args );

    return $self->cached_instrument_nselect($value);
}

1;
