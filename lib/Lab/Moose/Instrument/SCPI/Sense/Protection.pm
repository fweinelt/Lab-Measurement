package Lab::Moose::Instrument::SCPI::Sense::Protection;

#ABSTRACT: Role for the SCPI SENSe:$function:Protection subsystem

use v5.20;

use Moose::Role;
use Lab::Moose::Instrument::Cache;
use Lab::Moose::Instrument qw/validated_getter validated_setter/;

use namespace::autoclean;

=head1 METHODS

=head2 sense_protection_query

=head2 sense_protection

 $self->sense_protection(value => 1e-6);

Query/Set the measurement protection limit

=cut

requires 'cached_sense_function';

cache sense_protection => ( getter => 'sense_protection_query' );

sub sense_protection_query {
    my ( $self, %args ) = validated_getter( \@_ );

    my $func = $self->cached_sense_function();

    return $self->cached_sense_protection(
        $self->query( command => "SENS:$func:PROT?", %args ) );
}

sub sense_protection {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => 'Lab::Moose::PosNum' },
    );

    my $func = $self->cached_sense_function();

    $self->write( command => "SENS:$func:PROT $value", %args );

    $self->cached_sense_protection($value);
}

=head2 sense_protection_tripped_query

 my $tripped = $self->sense_protection_tripped_query();

Return '1' if source is in compliance, and '0' if source is not in compliance.

=cut

sub sense_protection_tripped_query {
    my ( $self, %args ) = validated_getter( \@_ );
    my $func = $self->cached_sense_function();
    return $self->query( command => "SENS:$func:PROT:TRIP?" );
}

=head2 sense_protection_rsynchronize_query/sense_protection_rsynchronize

Get/Set measure and compliance range synchronization.

=cut

cache sense_protection_rsynchronize =>
    ( getter => 'sense_protection_rsynchronize_query' );

sub sense_protection_rsynchronize_query {
    my ( $self, %args ) = validated_getter( \@_ );
    my $func = $self->cached_sense_function();
    return $self->cached_sense_protection_rsynchronize(
        $self->query( command => "SENS:$func:PROT:RSYN?", %args ) );
}

sub sense_protection_rsynchronize {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => 'Bool' }
    );
    my $func = $self->cached_sense_function();
    $self->write( command => "SENS:$func:PROT:RSYN $value" );
    $self->cached_sense_protection_rsynchronize($value);
}

1;

