package Lab::Instrument::SR830::AuxIn;
#ABSTRACT: Aux Inputs of the Stanford Research SR830 Lock-In Amplifier

use v5.20;

=head1 SYNOPSIS

 use Lab::Instrument::SR830::AuxIn
 my $multimeter = Lab::Instrument::SR830::AuxIn->new(%options, channel => 1);

 print $multimeter->get_value();

=head1 DESCRIPTION

This class provides access to the four DC inputs of the SR830. You have to
provide a C<channel> (1..4) parameter in the constructor. 

B<To use multiple virtual instruments, which use the same physical device, you have to share the connection between the virtual instruments:>

 use Lab::Measurement;

 # Create the shared connection.
 my $connection = Connection('LinuxGPIB', {gpib_address => 8});
 
 # Array of instrument objects. Each element belongs to one of the four
 # channels. 
 my @inputs;
 
 for my $channel (1..4) {
 	$inputs[$channel] = Instrument('SR830::AuxIn', {
 		connection => $connection,
 		channel => $channel,
 				 });
 }
 
 for my $channel (1..4) {
 	say "channel $channel: ", $inputs[$channel]->get_value();
 }



=cut

use warnings;
use strict;

use Data::Dumper;
use Carp;

use parent 'Lab::Instrument';


our %fields = (
    channel               => undef,
    supported_connections => [ 'GPIB', 'VISA_GPIB', 'DEBUG' ],
);

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = $class->SUPER::new(@_);
    $self->${ \( __PACKAGE__ . '::_construct' ) }(__PACKAGE__);
    $self->empty_buffer();
    my $channel = $self->channel;
    if ( not defined $channel ) {
        croak "need channel (1-4) in constructor for ", __PACKAGE__;
    }
    elsif ( $channel !~ /^[1-4]$/ ) {
        croak "channel '$channel' is not in the range (1..4)";
    }
    return $self;
}

sub empty_buffer {
    my $self = shift;
    my ($times) = $self->_check_args( \@_, ['times'] );
    if ($times) {
        for ( my $i = 0; $i < $times; $i++ ) {
            eval { $self->read( brutal => 1 ) };
        }
    }
    else {
        while ( $self->read( brutal => 1 ) ) {
            print "Cleaning buffer.";
        }
    }
}

=head1 Methods

=head2 get_value()

Return the input voltage.

=cut

sub get_value {
    my $self = shift;
    my ($tail) = $self->_check_args( \@_, [] );
    my $channel = $self->channel;
    return $self->query("OAUX? $channel");
}

1;
