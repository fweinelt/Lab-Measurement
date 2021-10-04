package Lab::Moose::Instrument::SignalRecovery7265;

#ABSTRACT: Model 7265 Lock-In Amplifier

use v5.20;

use strict;
use Moose;
use Moose::Util::TypeConstraints qw/enum/;
use MooseX::Params::Validate;
use Lab::Moose::Instrument qw/
    validated_getter validated_setter validated_no_param_setter setter_params /;
use Lab::Moose::Instrument::Cache;
use Carp;
use namespace::autoclean;
use Time::HiRes qw (usleep);

extends 'Lab::Moose::Instrument';

sub BUILD {
    my $self = shift;

}

=encoding utf8

=head1 WORK IN PROGRESS...

The subroutines are ported to Moose but not yet tested, beware of bugs.

=head1 SYNOPSIS

 use Lab::Moose;

 # Constructor
 my $SR = instrument(
    type => 'SignalRecovery7265',
    %connection_options
 );



=cut

sub reset {
    my $self = shift;
    $self->write(command => "ADF 1");
}

# ------------------ SIGNAL CHANNEL -------------------------

=head2 set_imode

	$SR->set_imode(value => $imode);

Preset Signal Recovery 7260 / 7265 Lock-in Amplifier

=over 4

=item $imode

	 $imode == 0  --> Current Mode OFF
	 $imode == 1  --> High Bandwidth Current Mode
	 $imode == 2  --> Low Noise Current Mode

=back

=cut

cache imode => (getter => 'get_imode');

sub set_imode {    # basic setting
    my ( $self, $value, %args ) = validated_setter( \@_,
        value => { isa => 'Int' }
    );

    # $imode == 0  --> Current Mode OFF
    # $imode == 1  --> High Bandwidth Current Mode
    # $imode == 2  --> Low Noise Current Mode

    if ( defined $value and ( $value == 0 || $value == 1 || $value == 2 ) ) {
        $self->write(command => sprintf("IMODE %d", $value));
        $self->cached_imode($value);
    } else {
        croak "\nSIGNAL RECOVERY 7265:\nunexpected value for IMODE in sub set_imode. Expected values are:\n 0 --> Current Mode OFF\n 1 --> High Bandwidth Current Mode\n 2 --> Low Noise Current Mode\n";
    }
}

sub get_imode {
    my ( $self, %args ) = validated_getter( \@_ );

    return $self->cached_imode($self->query(command => "IMODE", %args ));
}

=head2 set_vmode

	$SR->set_vmode($vmode);

Preset Signal Recovery 7260 / 7265 Lock-in Amplifier

=over 4

=item $vmode

	  $vmode == 0  --> Both inputs grounded (testmode)
	  $vmode == 1  --> A input only
	  $vmode == 2  --> -B input only
	  $vmode == 3  --> A-B differential mode

=back

=cut

cache vmode => (getter => 'get_vmode');

sub set_vmode {
    my ( $self, $value, %args ) = validated_setter( \@_,
        value => { isa => 'Int' }
    );

    # $vmode == 0  --> Both inputs grounded (testmode)
    # $vmode == 1  --> A input only
    # $vmode == 2  --> -B input only
    # $vmode == 3  --> A-B differential mode

    if ( defined $value
        and ( $value == 0 || $value == 1 || $value == 2 || $value == 3 ) ) {
        $self->write(command => sprintf( "VMODE %d", $value ));
        $self->cached_vmode($value);
    } else {
        croak "\nSIGNAL REOCOVERY 726x:\nunexpected value for VMODE in sub set_vmode. Expected values are:\n 0 --> Both inputs grounded (testmode)\n 1 --> A input only\n 2 --> -B input only\n 3 --> A-B differential mode\n";
    }
}

sub get_vmode {
    my ( $self, %args ) = validated_getter( \@_ );

    return $self->cached_vmode($self->query(command => "VMODE", %args ));
}

=head2 set_fet

	$SR->set_fet($value);

Preset Signal Recovery 7260 / 7265 Lock-in Amplifier

=over 4

=item $value

	  $value == 0 --> Bipolar device, 10 kOhm input impedance, 2nV/sqrt(Hz) voltage noise at 1 kHz
	  $value == 1 --> FET, 10 MOhm input impedance, 5nV/sqrt(Hz) voltage noise at 1 kHz

=back

=cut

cache fet => (getter => 'get_fet');

sub set_fet {
    my ( $self, $value, %args ) = validated_setter( \@_,
        value => { isa => 'Int' }
    );
    # $value == 0 --> Bipolar device, 10 kOhm input impedance, 2nV/sqrt(Hz) voltage noise at 1 kHz
    # $value == 1 --> FET, 10 MOhm input impedance, 5nV/sqrt(Hz) voltage noise at 1 kHz

    if ( defined $value and ( $value == 0 || $value == 1 ) ) {
        $self->write(command => sprintf( "FET %d", $value ));
        $self->cached_fet($value);
    } else {
        croak "\nSIGNAL REOCOVERY 726x:\nunexpected value in sub set_fet. Expected values are:\n 0 --> Bipolar device, 10 kOhm input impedance, 2nV/sqrt(Hz) voltage noise at 1 kHz\n 1 --> FET, 10 MOhm input impedance, 5nV/sqrt(Hz) voltage noise at 1 kHz\n";
    }
}

sub get_fet {
    my ( $self, %args ) = validated_getter( \@_ );

    return $self->cached_fet($self->query(command => "FET", %args ));
}

=head2 set_float

	$SR->set_float($value);

Preset Signal Recovery 7260 / 7265 Lock-in Amplifier

=over 4

=item $value

	  $value == 0 --> input conector shield set to GROUND
	  $value == 1 --> input conector shield set to FLOAT

=back

=cut

cache float => (getter => 'get_float');

sub set_float {
    my ( $self, $value, %args ) = validated_setter( \@_,
        value => { isa => 'Int' }
    );

    # $value == 0 --> input conector shield set to GROUND
    # $value == 1 --> input conector shield set to FLOAT

    if ( defined $value and ( $value == 0 || $value == 1 ) ) {
        $self->write(command => sprintf( "FLOAT %d", $value ));
        $self->cached_float($value);
    } else {
        croak "\nSIGNAL REOCOVERY 726x:\nunexpected value in sub set_float. Expected values are:\n 0 --> input conector shield set to GROUND\n 1 --> input conector shield set to FLOAT\n";
    }
}

sub get_float {
    my ( $self, %args ) = validated_getter( \@_ );

    return $self->cached_float($self->query(command => "FLOAT", %args ));
}

=head2 set_cp

	$SR->set_cp($value);

Preset Signal Recovery 7260 / 7265 Lock-in Amplifier

=over 4

=item $value

	  $value == 0 --> input coupling mode AC\n
	  $value == 1 --> input coupling mode DC\n

=back

=cut

cache cp => (getter => 'get_cp');

sub set_cp {
    my ( $self, $value, %args ) = validated_setter( \@_,
        value => { isa => 'Int' }
    );

    # $value == 0 --> input conector shield set to GROUND
    # $value == 1 --> input conector shield set to FLOAT

    if ( defined $value and ( $value == 0 || $value == 1 ) ) {
        $self->write(command => sprintf( "CP %d", $value ));
        $self->cached_cp($value);
    } else {
        croak "\nSIGNAL REOCOVERY 726x:\nunexpected value in sub set_cp. Expected values are:\n 0 --> input coupling mode AC\n 1 --> input coupling mode DC\n";
    }
}

sub get_cp {
    my ( $self, %args ) = validated_getter( \@_ );

    return $self->cached_cp($self->query(command => "CP", %args ));
}

=head2 set_sen

	$SR->set_sen($value);

Preset Signal Recovery 7260 / 7265 Lock-in Amplifier

=over 4

=item $value

	  SENSITIVITY (IMODE == 0) --> 2nV, 5nV, 10nV, 20nV, 50nV, 100nV, 200nV, 500nV, 1uV, 2uV, 5uV, 10uV, 20uV, 50uV, 100uV, 200uV, 500uV, 1mV, 2mV, 5mV, 10mV, 20mV, 50mV, 100mV, 200mV, 500mV, 1V\n
	  SENSITIVITY (IMODE == 1) --> 2fA, 5fA, 10fA, 20fA, 50fA, 100fA, 200fA, 500fA, 1pA, 2pA, 5pA, 10pA, 20pA, 50pA, 100pA, 200pA, 500pA, 1nA, 2nA, 5nA, 10nA, 20nA, 50nA, 100nA, 200nA, 500nA, 1uA\n
	  SENSITIVITY (IMODE == 2) --> 2fA, 5fA, 10fA, 20fA, 50fA, 100fA, 200fA, 500fA, 1pA, 2pA, 5pA, 10pA, 20pA, 50pA, 100pA, 200pA, 500pA, 1nA, 2nA, 5nA, 10nA\n

=back

=cut

cache sen => (getter => 'get_sen');

sub set_sen {
    my ( $self, $value, %args ) = validated_setter( \@_,
        value => { isa => 'Int' }
    );

    my @matrix = (
        {
            2e-9  => 1,
            5e-9  => 2,
            10e-9 => 3,
            2e-8  => 4,
            5e-8  => 5,
            10e-8 => 6,
            2e-7  => 7,
            5e-7  => 8,
            10e-7 => 9,
            2e-6  => 10,
            5e-6  => 11,
            10e-6 => 12,
            2e-5  => 13,
            5e-5  => 14,
            10e-5 => 15,
            2e-4  => 16,
            5e-4  => 17,
            10e-4 => 18,
            2e-3  => 19,
            5e-3  => 20,
            10e-3 => 21,
            2e-2  => 22,
            5e-2  => 23,
            10e-2 => 24,
            2e-1  => 25,
            5e-1  => 26,
            10e-1 => 27
        },
        {
            2e-15  => 1,
            5e-15  => 2,
            10e-15 => 3,
            2e-14  => 4,
            5e-14  => 5,
            10e-14 => 6,
            2e-13  => 7,
            5e-13  => 8,
            10e-13 => 9,
            2e-12  => 10,
            5e-12  => 11,
            10e-12 => 12,
            2e-11  => 13,
            5e-11  => 14,
            10e-11 => 15,
            2e-10  => 16,
            5e-10  => 17,
            10e-10 => 18,
            2e-9   => 19,
            5e-9   => 20,
            10e-9  => 21,
            2e-8   => 22,
            5e-8   => 23,
            10e-8  => 24,
            2e-7   => 25,
            5e-7   => 26,
            10e-7  => 27
        },
        {
            2e-15  => 7,
            5e-15  => 8,
            10e-15 => 9,
            2e-14  => 10,
            5e-14  => 11,
            10e-14 => 12,
            2e-13  => 13,
            5e-13  => 14,
            10e-13 => 15,
            2e-12  => 16,
            5e-12  => 17,
            10e-12 => 18,
            2e-11  => 19,
            5e-11  => 20,
            10e-11 => 21,
            2e-10  => 22,
            5e-10  => 23,
            10e-10 => 24,
            2e-9   => 25,
            5e-9   => 26,
            10e-9  => 27
        }
    );

    my $imode = $self->get_imode();

    # SENSITIVITY (IMODE == 0) --> 2nV, 5nV, 10nV, 20nV, 50nV, 100nV, 200nV, 500nV, 1uV, 2uV, 5uV, 10uV, 20uV, 50uV, 100uV, 200uV, 500uV, 1mV, 2mV, 5mV, 10mV, 20mV, 50mV, 100mV, 200mV, 500mV, 1V\n
    # SENSITIVITY (IMODE == 1) --> 2fA, 5fA, 10fA, 20fA, 50fA, 100fA, 200fA, 500fA, 1pA, 2pA, 5pA, 10pA, 20pA, 50pA, 100pA, 200pA, 500pA, 1nA, 2nA, 5nA, 10nA, 20nA, 50nA, 100nA, 200nA, 500nA, 1uA\n
    # SENSITIVITY (IMODE == 2) --> 2fA, 5fA, 10fA, 20fA, 50fA, 100fA, 200fA, 500fA, 1pA, 2pA, 5pA, 10pA, 20pA, 50pA, 100pA, 200pA, 500pA, 1nA, 2nA, 5nA, 10nA\n

    if ( index( $value, "n" ) >= 0 ) {
        $value = int($value) * 1e-9;
    }
    elsif ( index( $value, "f" ) >= 0 ) {
        $value = int($value) * 1e-15;
    }
    elsif ( index( $value, "p" ) >= 0 ) {
        $value = int($value) * 1e-12;
    }
    elsif ( index( $value, "u" ) >= 0 ) {
        $value = int($value) * 1e-6;
    }
    elsif ( index( $value, "m" ) >= 0 ) {
        $value = int($value) * 1e-3;
    }

    if ( exists $matrix[$imode]->{$value} ) {
        $self->write(command => sprintf( "SEN %d", $matrix[$imode]->{$value} ));
        $self->cached_sen($matrix[$imode]->{$value})
    }
    elsif ( $value == "AUTO" ) {
        $self->write(command => "AS");
    }

    else {
        croak "\nSIGNAL REOCOVERY 726x:\nunexpected value for SENSITIVITY in sub set_sen. Expected values are: \n\n SENSITIVITY (IMODE == 0) --> 2nV, 5nV, 10nV, 20nV, 50nV, 100nV, 200nV, 500nV, 1uV, 2uV, 5uV, 10uV, 20uV, 50uV, 100uV, 200uV, 500uV, 1mV, 2mV, 5mV, 10mV, 20mV, 50mV, 100mV, 200mV, 500mV, 1V\n\n SENSITIVITY (IMODE == 1) --> 2fA, 5fA, 10fA, 20fA, 50fA, 100fA, 200fA, 500fA, 1pA, 2pA, 5pA, 10pA, 20pA, 50pA, 100pA, 200pA, 500pA, 1nA, 2nA, 5nA, 10nA, 20nA, 50nA, 100nA, 200nA, 500nA, 1uA\n\n SENSITIVITY (IMODE == 2) --> 2fA, 5fA, 10fA, 20fA, 50fA, 100fA, 200fA, 500fA, 1pA, 2pA, 5pA, 10pA, 20pA, 50pA, 100pA, 200pA, 500pA, 1nA, 2nA, 5nA, 10nA\n";
    }
}

sub get_sen {
    my ( $self, %args ) = validated_getter( \@_ );

    my @matrix_reverse = (
        [
            2e-9,  5e-9,  10e-9, 2e-8,  5e-8,  10e-8, 2e-7,  5e-7,
            10e-7, 2e-6,  5e-6,  10e-6, 2e-5,  5e-5,  10e-5, 2e-4,
            5e-4,  10e-4, 2e-3,  5e-3,  10e-3, 2e-2,  5e-2,  10e-2,
            2e-1,  5e-1,  10e-1
        ],
        [
            2e-15,  5e-15,  10e-15, 2e-14,  5e-14, 10e-14, 2e-13,  5e-13,
            10e-13, 2e-12,  5e-12,  10e-12, 2e-11, 5e-11,  10e-11, 2e-10,
            5e-10,  10e-10, 2e-9,   5e-9,   10e-9, 2e-8,   5e-8,   10e-8,
            2e-7,   5e-7,   10e-7
        ],
        [
            2e-15,  5e-15,  10e-15, 2e-14,  5e-14, 10e-14, 2e-13,  5e-13,
            10e-13, 2e-12,  5e-12,  10e-12, 2e-11, 5e-11,  10e-11, 2e-10,
            5e-10,  10e-10, 2e-9,   5e-9,   10e-9
        ]
    );

    my $imode = $self->get_imode();

    return $matrix_reverse[$imode][ $self->cached_sen($self->query(command =>"SEN", %args)) - 1 ];
}

=head2 set_acgain

	$SR->set_acgain($value);

Preset Signal Recovery 7260 / 7265 Lock-in Amplifier

=over 4

=item $value

	  AC-GAIN == 0 -->  0 dB gain of the signal channel amplifier\n
	  AC-GAIN == 1 --> 10 dB gain of the signal channel amplifier\n
	  ...
	  AC-GAIN == 9 --> 90 dB gain of the signal channel amplifier\n

=back

=cut

cache acgain => (getter => 'get_acgain');

sub set_acgain {
    my ( $self, $value, %args ) = validated_setter( \@_,
        value => { isa => 'Int' | 'Str'}
    );

    # AC-GAIN == 0 -->  0 dB gain of the signal channel amplifier\n
    # AC-GAIN == 1 --> 10 dB gain of the signal channel amplifier\n
    # ...
    # AC-GAIN == 9 --> 90 dB gain of the signal channel amplifier\n

    if ( defined $value
        and int($value) == $value
        and $value <= 9
        and $value >= 0 ) {

        $self->write(command => sprintf( "ACGAIN %d", $value ));
        $self->cached_acgain($value);
    }
    elsif ( $value eq "AUTO" ) {
        $self->write(command => "AUTOMATIC 1");
        $self->cached_acgain("AUTO");
    }
    else {
        croak "\nSIGNAL REOCOVERY 726x:\nunexpected value for AC-GAIN in sub set_acgain. Expected values are:\n AC-GAIN == 0 -->  0 dB gain of the signal channel amplifier\n AC-GAIN == 1 --> 10 dB gain of the signal channel amplifier\n ...\n AC-GAIN == 9 --> 90 dB gain of the signal channel amplifier\n";
    }
}

sub get_acgain {
    my ( $self, %args ) = validated_getter( \@_ );

    return $self->cached_acgain($self->query(command => "ACGAIN", %args ));
}

=head2 set_linefilter

	$SR->set_linefilter($value);

Preset Signal Recovery 7260 / 7265 Lock-in Amplifier

=over 4

=item $value

	  LINE-FILTER == 0 --> OFF\n
	  LINE-FILTER == 1 --> enable 50Hz/60Hz notch filter\n
	  LINE-FILTER == 2 --> enable 100Hz/120Hz notch filter\n
	  LINE-FILTER == 3 --> enable 50Hz/60Hz and 100Hz/120Hz notch filter\n

=back

=cut

cache linefilter => (getter => 'get_linefilter');

sub set_linefilter {
    my ( $self, $value, $linefrequency, %args ) = validated_setter( \@_,
        value => { isa => 'Int'},
        linefrequency => { isa => enum([qw/50Hz 60Hz/])}
    );

    if    ( not defined $linefrequency ) { $linefrequency = 1; }  # 1-->50Hz
    elsif ( $linefrequency eq "50Hz" )   { $linefrequency = 1; }
    elsif ( $linefrequency eq "60Hz" )   { $linefrequency = 0; }  # 0 --> 60Hz
    else {
        croak "\nSIGNAL REOCOVERY 726x:\nunexpected value for LINEFREQUENCY in sub set_linefilter. Expected values are '50Hz' or '60Hz'.";
    }

    # LINE-FILTER == 0 --> OFF\n
    # LINE-FILTER == 1 --> enable 50Hz/60Hz notch filter\n
    # LINE-FILTER == 2 --> enable 100Hz/120Hz notch filter\n
    # LINE-FILTER == 3 --> enable 50Hz/60Hz and 100Hz/120Hz notch filter\n

    if ( defined $value
        and ( $value == 0 || $value == 1 || $value == 2 || $value == 3 ) ) {

        $self->write(command => sprintf( "LF %d, %d", $value, $linefrequency ));
        $self->cached_linefilter($value);
    }
    else {
        croak "\nSIGNAL REOCOVERY 726x:\nunexpected value for FILTER in sub set_linefilter. Expected values are:\n LINE-FILTER == 0 --> OFF\n LINE-FILTER == 1 --> enable 50Hz/60Hz notch filter\n LINE-FILTER == 2 --> enable 100Hz/120Hz notch filter\n LINE-FILTER == 3 --> enable 50Hz/60Hz and 100Hz/120Hz notch filter\n";
    }
}

sub get_linefilter {
    my ( $self, %args ) = validated_getter( \@_ );

    return $self->cached_linefilter($self->query(command => "LF", %args ));
}

# ------------------REFERENCE CHANNEL ---------------------------

=head2 set_refchannel

	$SR->set_refchannel($value);

Preset Signal Recovery 7260 / 7265 Lock-in Amplifier

=over 4

=item $value

	  INT --> internal reference input mode\n
	  EXT LOGIC --> external rear panel TTL input\n
	  EXT --> external front panel analog input\n

=back

=cut

cache refchannel => (getter => 'get_refchannel');

sub set_refchannel {
    my ( $self, $value, %args ) = validated_setter( \@_,
        value => { isa => enum(["INT", "EXT LOGIC", "EXT"])}
    );

    # INT --> internal reference input mode\n
    # EXT LOGIC --> external rear panel TTL input\n
    # EXT --> external front panel analog input\n

    $self->cached_refchannel($value); # Save the String value to the cache

    if    ( $value eq "INT" )       { $value = 0; }
    elsif ( $value eq "EXT LOGIC" ) { $value = 1; }
    elsif ( $value eq "EXT" )       { $value = 2; }
    else {
        croak "\nSIGNAL REOCOVERY 726x:\nunexpected value for REFERENCE CHANEL in sub set_refchennel. Expected values are:\n INT --> internal reference input mode\n EXT LOGIC --> external rear panel TTL input\n EXT --> external front panel analog input\n";
    }

    $self->write(command => sprintf( "IE %d", $value ));
}

sub get_refchannel {
    my ( $self, %args ) = validated_getter( \@_ );

    my $result = $self->query(command => "IE", %args );

    if ( $result == 0 ) {
        return $self->cached_refchannel('INT');
    }
    elsif ( $result == 1 ) {
        return $self->cached_refchannel('EXT LOGIC');
    }
    elsif ( $result == 2 ) {
        return $self->cached_refchannel('EXT');
    }
}

=head2 autophase

	$SR->autophase();

Trigger an autophase procedure

=cut

sub autophase {
    my ( $self, %args ) = validated_getter( \@_ );
    $self->write(command => "AQN");
    usleep( 5 * $self->get_tc() * 1e6 );
}

=head2 set_refpha

	$SR->set_refpha($value);

Preset Signal Recovery 7260 / 7265 Lock-in Amplifier

=over 4

=item $value

	  REFERENCE PHASE can be between 0 ... 306°

=back

=cut

cache refpha => (getter => 'refpha');

sub set_refpha {
    my ( $self, $value, %args ) = validated_setter( \@_,
        value => { isa => 'Int'}
    );

    if ( $value >= 0 && $value <= 360 ) {
        $self->write(command => sprintf( "REFP %d", $value * 1e3 ));
        $self->cached_refpha($value);
    }
    else {
        croak "\nSIGNAL REOCOVERY 726x:\nunexpected value for REFERENCE PHASE in sub set_refpha. Expected values must be in the range 0..360";
    }
}

sub get_refpha {
    my ( $self, %args ) = validated_getter( \@_ );

    my $val = $self->query(command => "REFP.", %args );

    # Trailing zero byte if phase is zero. Device bug??
    $val =~ s/\0//;

    return $self->cached_refpha($val);
}

# ----------------- SIGNAL CHANNEL OUTPUT FILTERS ---------------

=head2 set_outputfilter_slope

	$SR->set_outputfilter_slope($value);

Preset Signal Recovery 7260 / 7265 Lock-in Amplifier

=over 4

=item $value

	   6dB -->  6dB/octave slope of output filter\n
	  12dB --> 12dB/octave slope of output filter\n
	  18dB --> 18dB/octave slope of output filter\n
	  24dB --> 24dB/octave slope of output filter\n

=back

=cut

cache ouputfilter_slope => (getter => 'get_ouputfilter_slope');

sub set_outputfilter_slope {
    my ( $self, $value, %args ) = validated_setter( \@_,
        value => { isa => enum([qw/6dB 12dB 18dB 24dB/])}
    );

    # 6dB -->  6dB/octave slope of output filter\n
    # 12dB --> 12dB/octave slope of output filter\n
    # 18dB --> 18dB/octave slope of output filter\n
    # 24dB --> 24dB/octave slope of output filter\n

    $self->cached_ouputfilter_slope($value); # Save the String value to the cache

    if    ( $value eq "6dB" )  { $value = 0; }
    elsif ( $value eq "12dB" ) { $value = 1; }
    elsif ( $value eq "18dB" ) { $value = 2; }
    elsif ( $value eq "24dB" ) { $value = 3; }
    else {
        croak "\nSIGNAL REOCOVERY 726x:\nunexpected value for SLOPE in sub set_ouputfilter_slope. Expected values are:\n  6dB -->  6dB/octave slope of output filter\n 12dB --> 12dB/octave slope of output filter\n 18dB --> 18dB/octave slope of output filter\n 24dB --> 24dB/octave slope of output filter\n";
    }

    $self->write(command => sprintf( "SLOPE %d", $value ));
}

sub get_ouputfilter_slope {
    my ( $self, %args ) = validated_getter( \@_ );

    my $result = $self->query( command => "SLOPE", %args );

    if ( $result == 0 ) {
        return '6dB';
    }
    elsif ( $result == 1 ) {
        return '12dB';
    }
    elsif ( $result == 2 ) {
        return '18dB';
    }
    elsif ( $result == 3 ) {
        return '24dB';
    }

    return $self->cached_ouputfilter_slope($result);
}

=head2 set_tc

	$SR->set_tc($value);

Preset the output(signal channel) low pass filters time constant tc of the Signal Recovery 7260 / 7265 Lock-in Amplifier

=over 4

=item $value

	  Filter Time Constant:
	10us, 20us, 40us, 80us, 160us, 320us, 640us, 5ms, 10ms, 20ms, 50ms, 100ms, 200ms, 500ms, 1s, 2s, 5s, 10s, 20s, 50s, 100s, 200s, 500s, 1ks, 2ks, 5ks, 10ks, 20ks, 50ks, 100ks\n

=back

=cut

cache tc => (getter => 'get_tc');

sub set_tc {
    my ( $self, $value, %args ) = validated_setter( \@_,
        value => { isa => enum([qw/
            10us 20us 40us 80us 160us 320us 640us
            5ms 10ms 20ms 50ms 100ms 200ms 500ms
            1 2 5 10 20 50 100 200 500
            1ks 2ks 5ks 10ks 20ks 50ks 100ks
        /])}
    );

    # Filter Time Constant: 10us, 20us, 40us, 80us, 160us, 320us, 640us, 5ms, 10ms, 20ms, 50ms, 100ms, 200ms, 500ms, 1s, 2s, 5s, 10s, 20s, 50s, 100s, 200s, 500s, 1ks, 2ks, 5ks, 10ks, 20ks, 50ks, 100ks\n

    my %list = (
        10e-6  => 0,
        20e-6  => 1,
        40e-6  => 2,
        80e-6  => 3,
        160e-6 => 4,
        320e-6 => 5,
        640e-6 => 6,
        5e-3   => 7,
        10e-3  => 8,
        20e-3  => 9,
        50e-3  => 10,
        100e-3 => 11,
        200e-3 => 12,
        500e-3 => 13,
        1      => 14,
        2      => 15,
        5      => 16,
        10     => 17,
        20     => 18,
        50     => 19,
        100    => 20,
        200    => 21,
        500    => 22,
        1e3    => 23,
        2e3    => 24,
        5e3    => 25,
        10e3   => 26,
        20e3   => 27,
        50e3   => 28,
        100e3  => 29
    );

    if ( $value =~ /\b(\d+\.?[\d+]?)us?\b/ ) {
        $value = $1 * 1e-6;
    }
    elsif ( $value =~ /\b(\d+\.?[\d+]?)ms?\b/ ) {
        $value = $1 * 1e-3;
    }
    elsif ( $value =~ /\b(\d+\.?[\d+]?)ks?\b/ ) {
        $value = $1 * 1000;
    }

    $self->cached_tc($value);
    $self->write(command => sprintf( "TC %d", $list{$value} ));
}

sub get_tc {
    my ( $self, %args ) = validated_getter( \@_ );

    my @list = (
        10e-6, 20e-6, 40e-6, 80e-6,  160e-6, 320e-6, 640e-6, 5e-3,
        10e-3, 20e-3, 50e-3, 100e-3, 200e-3, 500e-3, 1,      2,
        5,     10,    20,    50,     100,    200,    500,    1e3,
        2e3,   5e3,   10e3,  20e3,   50e3,   100e3
    );

    my $tc = $self->query(command => "TC", %args );

    return $self->cached_tc($list[$tc]);
}

# ---------------- SIGNAL CHANNEL OUTPUT AMPLIFIERS --------------

=head2 set_offset

Yet to document

=cut

cache offset => (getter => 'get_offset');

sub set_offset {
    my ( $self, $X, $Y, %args ) = validated_setter( \@_ );

    my @offset;

    if ( $X >= -300 || $X <= 300 ) {
        $self->write(command => sprintf( "XOF 1 %d", $X * 100 ));
        my @temp = split( /,/, $self->query(command => "XOF") );
        $offset[0] = $temp[1] / 100;
        if ( $offset[0] != $X ) {
            croak "\nSIGNAL REOCOVERY 726x:\ncouldn't set X chanel output offset";
        }
    }

    if ( $Y >= -300 || $Y <= 300 ) {
        $self->write(command => sprintf( "YOF 1 %d", $Y * 100 ));
        my @temp = split( /,/, $self->query(command => "YOF") );
        $offset[1] = $temp[1] / 100;
        if ( $offset[1] != $Y ) {
            croak "\nSIGNAL REOCOVERY 726x:\ncouldn't set Y chanel output offset";
        }
    }

    if ( $X eq 'OFF' ) {
        $self->write(command => "XOF 0");
        my @temp = split( /,/, $self->query(command => "XOF") );
        $offset[0] = $temp[0];
        if ( $offset[0] != 0 ) {
            croak "\nSIGNAL REOCOVERY 726x:\ncouldn't set X chanel output offset";
        }
    }

    if ( $Y eq 'OFF' ) {
        $self->write(command => "YOF 0");
        my @temp = split( /,/, $self->query(command => "YOF") );
        $offset[1] = $temp[0];
        if ( $offset[1] != 0 ) {
            croak "\nSIGNAL REOCOVERY 726x:\ncouldn't set Y chanel output offset";
        }
    }

    if ( $X eq 'AUTO' ) {
        $self->write(command => "AXO");
        my @temp = split( /,/, $self->query(command => "XOF") );
        $offset[0] = $temp[1];
        @temp = split( /,/, $self->query(command => "YOF") );
        $offset[1] = $temp[1];
    }

    $self->cached_offset(\@offset);
}

sub get_offset {

    # not yet implemented
}

# -------------- INTERNAL OSCILLATOR ------------------------------

=head2 set_osc

	$SR->set_osc($value);

Preset the oscillator output voltage of the Signal Recovery 7260 / 7265 Lock-in Amplifier

=over 4

=item $value

	  OSCILLATOR OUTPUT VOLTAGE can be between 0 ... 5V in steps of 1mV (Signal Recovery 7260) and 1uV (Signal Recovery 7265)

=back

=cut

cache osc => (getter => 'get_osc');

sub set_osc {
    my ( $self, $value, %args ) = validated_setter( \@_ );

    my $id = $self->query( command => "ID" );

    if ( index( $value, "u" ) >= 0 ) {
        $value = int($value) * 1e-6;
    }
    elsif ( index( $value, "m" ) >= 0 ) {
        $value = int($value) * 1e-3;
    }

    if ( $value >= 0 && $value <= 5 ) {
        if ( $id == 7260 ) {
            $self->write( command => sprintf( "OA %d", sprintf( "%d", $value * 1e3 ) ) );
        }
        elsif ( $id == 7265 ) {
            $self->write( command => sprintf( "OA %d", sprintf( "%d", $value * 1e6 ) ) );
        }
        $self->cached_osc($value);

    }
    else {
        croak "\nSIGNAL REOCOVERY 726x:\n\nSIGNAL REOCOVERY 726x:\nunexpected value for OSCILLATOR OUTPUT in sub set_osc. Expected values must be in the range 0..5V.";
    }
}

sub get_osc {
    my ( $self, %args ) = validated_getter( \@_ );

    my $id = $self->query( command => "ID" );

    if ( $id == 7260 ) {
        return $self->cached_osc($self->query( command => "OA", %args ) / 1e3);
    }
    elsif ( $id == 7265 ) {
        return $self->cached_osc($self->query( command => "OA", %args ) / 1e6);
    }
}

=head2 set_frq

	$SR->set_frq($value);

Preset the oscillator frequency of the Signal Recovery 7260 / 7265 Lock-in Amplifier

=over 4

=item $value

	  OSCILLATOR FREQUENCY can be between 0 ... 259kHz

=back

=cut

cache frq => (getter => 'get_frq');

sub set_frq {
    my ( $self, $value, %args ) = validated_setter( \@_ );

    if ( index( $value, "m" ) >= 0 ) {
        $value = int($value) * 1e-3;
    }
    elsif ( index( $value, "k" ) >= 0 ) {
        $value = int($value) * 1e3;
    }

    if ( $value > 0 && $value <= 250000 ) {
        $self->write( command => sprintf( "OF %d", $value * 1e3 ) );
        $self->cached_frq($value);
    }
    else {
        croak "\nSIGNAL REOCOVERY 726x:\n\nSIGNAL REOCOVERY 726x:\nunexpected value for OSCILLATOR FREQUENCY in sub set_frq. Expected values must be in the range 0..250kHz";
    }
}

sub get_frq {
    my ( $self, %args ) = validated_getter( \@_ );

    return $self->cached_frq($self->query( command => "OF", %args ) / 1e3);
}

# --------------- INSTRUMENT OUTPUTS ------------------------------

=head2 get_value

	$value=$SR->get_value($channel);

Makes a measurement using the actual settings.
The CHANNELS defined by $channel are returned as floating point values.
If more than one value is requested, they will be returned as an array.

=over 4

=item $channel

CHANNEL can be:

	  in floating point notation:

	-----------------------------

	'X'   --> X channel output\n
	'Y'   --> Y channel output\n
	'MAG' --> Magnitude\n
	'PHA' --> Signale phase\n
	'XY'  --> X and Y channel output\n
	'MP'  --> Magnitude and signal Phase\n
	'ALL' --> X,Y, Magnitude and signal Phase\n

=back

=cut

cache value => (getter => 'get_value', isa => 'HashRef');

sub get_value {
    my ( $self, $channel, $read_mode, %args ) = validated_setter( \@_,
        channel => {isa => enum([qw/X Y MAG PHA XY MP ALL/])},
        read_mode => {isa => 'Str', optional => 1}
    );

    my $result;

    # $channel can be:\n X   --> X channel output\n Y   --> Y channel output\n MAG --> Magnitude\n PHA --> Signale phase\n XY  --> X and Y channel output\n MP  --> Magnitude and signal Phase\n ALL --> X,Y, Magnitude and signal Phase\n
    if ( $channel eq "X" ) {

        if ( $read_mode eq 'cache'
            and defined ${$self->cached_value()}{X} ) {
            return ${$self->cached_value()}{X};
        }

        $result = $self->query( command => "X.", %args );
        $result =~ s/\x00//g;
        ${$self->cached_value()}{X} = $result;
        return $result;
    }
    elsif ( $channel eq "Y" ) {

        if ( $read_mode eq 'cache'
            and defined ${$self->cached_value()}{'Y'} ) {
            return ${$self->cached_value()}{'Y'};
        }

        $result = $self->query( command => "Y.", %args );
        $result =~ s/\x00//g;
        ${$self->cached_value()}{'Y'} = $result;
        return $result;
    }
    elsif ( $channel eq "MAG" ) {

        if ( $read_mode eq 'cache'
            and defined ${$self->cached_value()}{'MAG'} ) {
            return ${$self->cached_value()}{'MAG'};
        }

        $result = $self->query( command => "MAG.", %args );
        $result =~ s/\x00//g;
        ${$self->cached_value()}{'MAG'} = $result;
        return $result;
    }
    elsif ( $channel eq "PHA" ) {

        if ( $read_mode eq 'cache'
            and defined ${$self->cached_value()}{'PHA'} ) {
            return ${$self->cached_value()}{'PHA'};
        }

        $result = $self->query( command => "PHA.", %args );
        $result =~ s/\x00//g;
        ${$self->cached_value()}{'PHA'} = $result;
        return $result;
    }
    elsif ( $channel eq "XY" ) {

        if (    $read_mode eq 'cache'
            and defined ${$self->cached_value()}{'X'}
            and defined ${$self->cached_value()}{'Y'} ) {
            return $self->cached_value();
        }

        $result = $self->query( command => "XY.", %args );
        $result =~ s/\x00//g;

        (
            ${$self->cached_value()}{'X'},
            ${$self->cached_value()}{'Y'}
        ) = split( ",", $result );

        return $self->cached_value();
    }
    elsif ( $channel eq "MP" ) {

        if (    $read_mode eq 'cache'
            and defined ${$self->cached_value()}{'MAG'}
            and defined ${$self->cached_value()}{'PHA'} ) {
            return $self->cached_value();
        }

        $result = $self->query( command => "MP.", %args );
        $result =~ s/\x00//g;
        (
            ${$self->cached_value()}{'MAG'},
            ${$self->cached_value()}{'PHA'}
        ) = split( ",", $result );
        return $self->cached_value();
    }
    elsif ( $channel eq "ALL" or $channel eq "" ) {

        if (    $read_mode eq 'cache'
            and defined ${$self->cached_value()}{'X'}
            and defined ${$self->cached_value()}{'Y'}
            and defined ${$self->cached_value()}{'MAG'}
            and defined ${$self->cached_value()}{'PHA'} ) {
            return $self->cached_value();
        }

        $result = $self->query( command => "XY.", %args ) . ","
            . $self->query( command => "MP.", %args );
        $result =~ s/\x00//g;
        (
            ${$self->cached_value()}{'X'},
            ${$self->cached_value()}{'Y'},
            ${$self->cached_value()}{'MAG'},
            ${$self->cached_value()}{'PHA'}
        ) = split( ",", $result );
        return $self->cached_value();
    }
}

=head2 config_measurement

	$SR->config_measurement($channel, $number_of_points, $interval, [$trigger]);

Preset the Signal Recovery 7260 / 7265 Lock-in Amplifier for a TRIGGERED measurement.

=over 4

=item $channel

CHANNEL can be:

	  in floating point notation:

	-----------------------------

	'X'   --> X channel output\n
	'Y'   --> Y channel output\n
	'MAG' --> Magnitude\n
	'PHA' --> Signale phase\n
	'XY'  --> X and Y channel output\n
	'MP'  --> Magnitude and signal Phase\n
	'ALL' --> X,Y, Magnitude and signal Phase\n

.

	  in percent of full range notation:

	------------------------------------

	'X-'   --> X channel output\n
	'Y-'   --> Y channel output\n
	'MAG-' --> Magnitude\n
	'PHA-' --> Signale phase\n
	'XY-'  --> X and Y channel output\n
	'MP-'  --> Magnitude and signal Phase\n
	'ALL-' --> X,Y, Magnitude and signal Phase\n


=item $number_of_points

Preset the NUMBER OF POINTS to be taken for one measurement trace.
The single measured points will be stored in the internal memory of the Lock-in Amplifier.
For the Signal Recovery 7260 / 7265 Lock-in Amplifier the internal memory is limited to 32.000 values.

	--> If you request data for the channels X and Y in floating point notation, for each datapoint three values have to be stored in memory (X,Y and Sensitivity).
	--> So you can store effectivly 32.000/3 = 10666 datapoints.
	--> You can force the instrument not to store additionally the current value of the Sensitivity setting by appending a '-' when you select the channels, eg. 'XY-' instead of simply 'XY'.
	--> Now you will recieve only values between -30000 ... + 30000 from the Lock-in, which is called the full range notation.
	--> You can calculate the measurement value by ($value/100)*Sensitivity. This is easy if you used only a single setting for Sensitivity during the measurement, and it's very hard if you changed the Sensitivity several times during the measurment or even used the auto-range function.

=item $interval

Preset the STORAGE INTERVAL in which datavalues will be stored during the measurement.
Note: the storage interval is independent from the low pass filters time constant tc.


=item $trigger

Optional value. Presets the source where the trigger signal is expected.
	'EXT' --> external trigger source
	'INT' --> internal trigger source

DEF is 'INT'. If no value is given, DEF will be selected.

=back

=cut

sub config_measurement {
    my ( $self, $channel, $nop, $interval, $trigger, %args ) = validated_setter( \@_,
        channel => {isa => enum([qw/X Y MAG PHA XY MP ALL X- Y- MAG- PHA -XY- MP- ALL-/])},
        nop => {isa => 'Int'},
        trigger => {isa => enum([qw/INT EXT/]), optional => 1, default => 'INT'}
    );

    print "--------------------------------------\n";
    print "SignalRecovery sub config_measurement:\n";

    $self->_clear_buffer();

    # select which data to store in buffer
    if    ( $channel eq "X" )   { $channel = 17; }
    elsif ( $channel eq "Y" )   { $channel = 18; }
    elsif ( $channel eq "XY" )  { $channel = 19; }
    elsif ( $channel eq "MAG" ) { $channel = 20; }
    elsif ( $channel eq "PHA" ) { $channel = 24; }
    elsif ( $channel eq "MP" )  { $channel = 28; }
    elsif ( $channel eq "ALL" ) { $channel = 31; }
    elsif ( $channel eq "X-" ) {
        $channel = 1;
    } # only X channel; Sensitivity not logged --> floating point read out not possible!
    elsif ( $channel eq "Y-" ) {
        $channel = 2;
    } # only Y channel; Sensitivity not logged --> floating point read out not possible!
    elsif ( $channel eq "XY-" ) {
        $channel = 3;
    } # only XY channel; Sensitivity not logged --> floating point read out not possible!
    elsif ( $channel eq "MAG-" ) {
        $channel = 4;
    } # only MAG channel; Sensitivity not logged --> floating point read out not possible!
    elsif ( $channel eq "PHA-" ) {
        $channel = 8;
    } # only PHA channel; Sensitivity not logged --> floating point read out not possible!
    elsif ( $channel eq "MP-" ) {
        $channel = 12;
    } # only MP channel; Sensitivity not logged --> floating point read out not possible!
    elsif ( $channel eq "ALL-" ) {
        $channel = 15;
    } # only XYMP channel; Sensitivity not logged --> floating point read out not possible!

    $self->_set_buffer_datachannels($channel);

    print "SIGNAL REOCOVERY 726x: set channels: "
        . $self->_set_buffer_datachannels($channel);

    # set buffer size
    print "SIGNAL REOCOVERY 726x: set buffer length: "
        . $self->_set_buffer_length($nop);

    # set measurement interval
    if ( not defined $interval ) {
        $interval = $self->set_tc();
    }
    print "SIGNAL REOCOVERY 726x: set storage interval: "
        . $self->_set_buffer_storageinterval($interval) . "\n";

    if ( $trigger eq "EXT" ) {
        $self->write(command => "TDT");
        usleep(1e6);
    }

    print "SignalRecovery config_measurement complete\n";
    print "--------------------------------------\n";
}

=head2 get_data

	@data = $SR->get_data(<$sensitivity>);

Reads all recorded values from the internal buffer and returns them as an (2-dim) array of floatingpoint values.

Example:

	requested channels: X --> $SR->get_data(); returns an 1-dim array containing the X-trace as floatingpoint-values
	requested channels: XY --> $SR->get_data(); returns an 2-dim array:
		--> @data[0] contains an 1-dim array containing the X-trace as floatingpoint-values
		--> @data[1] contains an 1-dim array containing the Y-trace as floatingpoint-values

Note: Reading the buffer will not start before all predevined measurement values have been recorded.
The LabVisa-script cannot be continued until all requested readings have been recieved.

=over 4

=item $sensitivity

SENSITIVITY is an optional parameter.
When it is defined, it will be assumed that the data recieved from the Lock-in are in full range notation.
The return values will be calculated by $value = ($value/100)*$sensitifity.

=back

=cut

sub get_data {
    my ( $self, $SEN, $timeout, %args ) = validated_setter( \@_,
        timeout => {isa => 'Num', optional => 1, default => 100} # it takes approx. 4ms per datapoint; 25k-Points --> 100sec
    );

    my @dummy;
    my @data;
    my %channel_list = (
        1  => "0",
        2  => "1",
        3  => "0,1",
        4  => "2",
        8  => "3",
        12 => "2,3",
        15 => "0,1,2,3",
        17 => "0",
        18 => "1",
        19 => "0,1",
        20 => "2",
        24 => "3",
        28 => "2,3",
        31 => "0,1,2,3"
    );

    my @channels = split( ",", $channel_list{ int( $self->query(command => "CBD", timeout => $timeout) ) } );

    #if ($channels == 17) { $channels = 1; }
    #elsif ($channels == 19) { $channels = 2; }
    #elsif ($channels == 31) { $channels = 4; }

    $self->wait();    # wait until active sweep has been finished

    foreach my $i (@channels) {
        if ( defined $SEN and $SEN >= 2e-15 and $SEN <= 1 ) {
            $self->write( command => sprintf( "DC %d", $i ) );
            my @temp;
            my $data;

            while (1) {
                eval '$self->read(timeout => $timeout)*$SEN*0.01';
                if ( $@ =~ /(Error while reading:)/ ) { last; }
                push( @temp, $data );
            }
            push( @data, \@temp );

        }
        else {
            $self->write( command => sprintf( "DC. %d", $i ) );
            my @temp;
            my $data;

            while (1) {
                eval '$data = $self->read(timeout => $timeout)';
                if ( $@ =~ /(Error while reading:)/ ) { last; }
                push( @temp, $data );
            }
            push( @data, \@temp );
        }

    }

    return @data;
}

=head2 trg

	$SR->trg();

Sends a trigger signal via the GPIB-BUS to start the predefined measurement.
The LabVisa-script can immediatally be continued, e.g. to start another triggered measurement using a second Signal Recovery 7260 / 7265 Lock-in Amplifier.

=cut

sub trg {
    my ( $self, %args ) = validated_no_param_setter( \@_ );
    $self->write(command => "TD");
}

=head2 abort

	$SR->abort();

Aborts current (triggered) measurement.

=cut

sub abort {
    my ( $self, %args ) = validated_no_param_setter( \@_ );
    $self->write(command => "HC");
}

=head2 active

	$SR->active();

Returns '1' if  current (triggered) measurement is still running and '0' if current (triggered) measurement has been finished.

=cut

sub active {
    my ( $self, %args ) = validated_getter( \@_ );

    my @status = split( ",", $self->query(command => "M") );
    if ( $status[0] == 0 ) {
        return 0;
    }
    else {
        return 1;
    }
}

=head2 wait

	$SR->wait();

Waits until current (triggered) measurement has been finished.

=cut

sub wait {
    my ( $self, %args ) = validated_getter( \@_ );

    while (1) {
        usleep(1e3);
        my @status = split( ",", $self->query(command => "M") );
        if ( $status[0] == 0 ) { last; }
    }
    return 0;
}

# --------------- DISPLAY ------------------------------

=head2 display_on

	$SR->display_on();

=cut

sub display_on {
    my ( $self, %args ) = validated_no_param_setter( \@_ );
    $self->write(command => "LTS 1");
}

=head2 display_off

	$SR->display_off();

=cut

sub display_off {
    my ( $self, %args ) = validated_no_param_setter( \@_ );
    $self->write(command => "LTS 0");
}

# --------------- OUTPUT DATA CURVE BUFFER -------------------------

sub _clear_buffer {
    my ( $self, %args ) = validated_no_param_setter( \@_ );
    $self->write(command => "NC");
}

sub _set_buffer_datachannels {
    my ( $self, $value, %args ) = validated_setter( \@_,
        value => {optional => 1}
    );
    if ( not defined $value ) {
        return $self->query(command => "CBD");
    }

    $self->write( command => sprintf( "CBD %d", $value ) );
    return $self->query(command => "CBD");
}

sub _set_buffer_length {
    my ( $self, $nop, %args ) = validated_no_param_setter( \@_,
        nop => {optional => 1}
    );

    if ( not defined $nop ) {
        return $self->query(command => "LEN");
    }

    # get number of channels to be stored
    my $channels = $self->query(command => "CBD");
    if    ( $channels == 17 ) { $channels = 2; }
    elsif ( $channels == 19 ) { $channels = 3; }
    elsif ( $channels == 31 ) { $channels = 5; }

    # check buffer size
    if ( $nop > int( 32000 / $channels ) ) {
        croak "\nSIGNAL REOCOVERY 726x:\n\nSIGNAL REOCOVERY 726x:\ncan't init BUFFER. Buffersize is too small for the given NUMBER OF POINTS and NUMBER OF CHANNELS to store.\n POINTS x (CHANNELS+1) cant exceed 32000.\n";
    }

    $self->write( command => sprintf( "LEN %d", $nop ) );
    return my $return = $self->query(command => "LEN");
}

sub _set_buffer_storageinterval {
    my ( $self, $value, %args ) = validated_setter( \@_,
        value => {isa => 'Num', optional => 1}
    );

    if ( not defined $value ) {
        return $self->query(command => "STR") / 1e3;
    }

    if ( $value < 5e-3 or $value > 1e6 ) {
        croak "\nSIGNAL REOCOVERY 726x:\nunexpected value for INTERVAL in sub set_buffer_interval. Expected values are between 5ms...1E6s with a resolution of 5ms.";
    }

    $self->write( command => sprintf( "STR %d", $value * 1e3 ) );

    return $self->query(command => "STR") / 1e3;
}

__PACKAGE__->meta()->make_immutable();

1;

=head1 CAVEATS/BUGS

probably many

=head1 SEE ALSO

=over 4

=item L<Lab::Moose::Instrument>

=back
