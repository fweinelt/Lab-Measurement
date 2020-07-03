package Lab::Moose::Instrument::SCPI::Sense::NPLC;

#ABSTRACT: Role for the SCPI SENSe:$function:NPLC subsystem

use v5.20;

use Moose::Role;
use Lab::Moose::Instrument::Cache;
use Lab::Moose::Instrument qw/validated_getter validated_setter/;

use namespace::autoclean;

=head1 METHODS

=head2 sense_nplc_query

=head2 sense_nplc

 $self->sense_nplc(value => '0.001');

Query/Set the input nplc.

=cut

requires 'cached_sense_function';

cache sense_nplc => ( getter => 'sense_nplc_query' );

sub sense_nplc_query {
    my ( $self, %args ) = validated_getter( \@_ );

    my $func = $self->cached_sense_function();

    return $self->cached_sense_nplc(
        $self->query( command => "SENS:$func:NPLC?", %args ) );
}

sub sense_nplc {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => 'Num' },
    );

    my $func = $self->cached_sense_function();

    $self->write( command => "SENS:$func:NPLC $value", %args );

    $self->cached_sense_nplc($value);
}

1;
