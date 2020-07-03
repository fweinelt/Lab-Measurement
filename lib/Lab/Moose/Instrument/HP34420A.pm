package Lab::Moose::Instrument::HP34420A;

#ABSTRACT: HP 34420A nanovolt meter.

use v5.20;

# So far only one channel. Could add support for two channels
# by using validated_channel_(setter/getter) in the SCPI/SENSE roles.


use Moose;
use Moose::Util::TypeConstraints 'enum';
use MooseX::Params::Validate;
use Lab::Moose::Instrument qw/validated_getter validated_setter/;
use Carp;
use Lab::Moose::Instrument::Cache;
use namespace::autoclean;

extends 'Lab::Moose::Instrument';

with qw(
    Lab::Moose::Instrument::Common
    Lab::Moose::Instrument::SCPI::Sense::Function
    Lab::Moose::Instrument::SCPI::Sense::Range
    Lab::Moose::Instrument::SCPI::Sense::NPLC
);

sub BUILD {
    my $self = shift;
    $self->clear();
    $self->cls();
}

=head1 SYNOPSIS

 my $dmm = instrument(
    type => 'HP34420A',
    connection_type => 'LinuxGPIB',
    connection_options => {pad => 24},
    );

 # Set properties of channel1:
 $dmm->sense_range(value => 10);
 $dmm->sense_nplc(value => 2);  
  
 my $voltage = $dmm->get_value();
 
The C<SENSE> methods only support channel 1 so far.

=cut

=head1 METHODS

Used roles:

=over

=item L<Lab::Moose::Instrument::SCPI::Sense::Function>

=item L<Lab::Moose::Instrument::SCPI::Sense::Range>

=item L<Lab::Moose::Instrument::SCPI::Sense::NPLC>

=back
    
=head2 get_value

 my $voltage = $dmm->get_value();

Perform voltage/current measurement.

=cut

sub get_value {
    my ( $self, %args ) = validated_getter( \@_ );
    return $self->query( command => 'READ?', %args );
}

=head2 route_terminals/route_terminals_query

 $dmm->route_terminals(value => 'FRON2');

Set/get used measurement channel. Allowed values: C<FRON[1], FRON2>.

=cut

cache route_terminals => ( getter => 'route_terminals_query' );

sub route_terminals_query {
    my ( $self, %args ) = validated_getter( \@_ );
    return $self->cached_route_terminals(
        $self->query( command => 'ROUT:TERM?', %args ) );
}

sub route_terminals {
    my ( $self, $value, %args ) = validated_setter(
        \@_,
        value => { isa => enum( [qw/FRON FRON1 FRON2/] ) }
    );
    $self->write( command => "ROUT:TERM $value" );
    $self->cached_route_terminals($value);
}

__PACKAGE__->meta()->make_immutable();

1;
