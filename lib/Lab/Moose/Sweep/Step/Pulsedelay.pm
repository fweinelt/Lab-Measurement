package Lab::Moose::Sweep::Step::Pulsedelay;

#ABSTRACT: Pulsedelay sweep.

use v5.20;

=head1 Description

Step sweep with following properties:

=over

=item *

Uses instruments C<set_pulsedelay> method to change the pulsewidth. On initialization
an optional boolean parameter C<constant_width> can be passed to keep a constant
pulse width over a period.

=item *

Default filename extension: C<'Pulsedelay='>

=back

=cut

use Moose;

extends 'Lab::Moose::Sweep::Step';

has filename_extension =>
    ( is => 'ro', isa => 'Str', default => 'Pulsedelay=' );

has setter => ( is => 'ro', isa => 'CodeRef', builder => '_build_setter' );

has instrument =>
    ( is => 'ro', isa => 'Lab::Moose::Instrument', required => 1 );

has constant_width => ( is => 'ro', isa => 'Num', default => 0 );

sub _build_setter {
    return \&_pulsedelay_setter;
}

sub _pulsedelay_setter {
    my $self  = shift;
    my $value = shift;
    $self->instrument->set_pulsedelay(
      value => $value,
      constant_width => $self->constant_width
    );
}

__PACKAGE__->meta->make_immutable();
1;

__END__
