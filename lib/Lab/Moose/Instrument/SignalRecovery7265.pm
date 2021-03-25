package Lab::Moose::Instrument::SignalRecovery7265;

#ABSTRACT: Model 7265 Lock-In Amplifier

use v5.20;

use Moose;
use Moose::Util::TypeConstraints qw/enum/;
use MooseX::Params::Validate;
use Lab::Moose::Instrument qw/
    validated_getter validated_setter setter_params /;
use Lab::Moose::Instrument::Cache;
use Carp;
use namespace::autoclean;

extends 'Lab::Moose::Instrument';

sub BUILD {
    my $self = shift;

}

=encoding utf8

=head1 WORK IN PROGRESS...

At the moment this is still a sceleton.

=head1 SYNOPSIS

 use Lab::Moose;

 # Constructor
 my $lia = instrument(type => 'SignalRecovery7265', %connection_options);
 


=cut

sub reset {

}

sub set_imode {

}

sub get_imode {

}

sub set_vmode {

}

sub get_vmode {

}

sub set_fet {

}

sub get_fet {

}

sub set_float {

}

sub get_float {

}

sub set_cp {

}

sub get_cp {

}

sub set_sen {

}

sub get_sen {

}

sub set_acgain {

}

sub get_acgain {

}

sub set_linefilter {

}

sub get_linefilter {

}

sub set_refchannel {

}

sub get_refchannel {

}

sub autophase {

}

sub set_refpha {

}

sub get_refpha {

}

sub set_outputfilter_slope {

}

sub get_ouputfilter_slope {

}

sub set_tc {

}

sub get_tc {

}

sub set_offset {

}

sub get_offset {

    # not implemented in Lab::Instrument driver
}

sub set_osc {

}

sub get_osc {

}

sub set_frq {

}

sub get_frq {

}

sub get_value {

}

sub config_measurement {

}

sub get_data {

}

sub trg {

}

sub abort {

}

sub active {

}

sub wait {

}

sub display_on {

}

sub display_off {

}

sub _clear_buffer {

}

sub _set_buffer_datachannels {

}

sub _set_buffer_length {

}

sub _set_buffer_storageinterval {

}

__PACKAGE__->meta()->make_immutable();

1;
