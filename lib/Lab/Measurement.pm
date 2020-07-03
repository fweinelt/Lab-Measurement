package Lab::Measurement;

#ABSTRACT: Log, describe and plot data on the fly

use v5.20;

use strict;
use warnings;
use Lab::Generic;
use Carp;

use Exporter 'import';
use Lab::XPRESS::hub qw(DataFile Sweep Frame Instrument Connection);
our @EXPORT = qw(DataFile Sweep Frame Instrument Connection);

carp <<"EOF";
\"use Lab::Measurement;\" imports the legacy interface of Lab::Measurement.
Please consider porting your measurement scripts to the new, Moose-based code.
Documentation can be found at https://www.labmeasurement.de/
EOF
1;

__END__

=encoding utf8

=head1 SYNOPSIS

  use Lab::Measurement;

However, by now you probably want to use the following instead:

  use Lab::Moose;

=head1 DESCRIPTION

The Lab::Measurement module distribution simplifies the task of running a
measurement, writing the data to disk and keeping track of necessary meta
information that usually later you don't find in your lab book anymore.

If your measurements don't come out nice, it's not because you were using the 
wrong software. 

The actual Lab::Measurement module belongs to the deprecated legacy module
stack. We are in the process of re-writing the entire code base using Modern
Perl techniques and the Moose object system. Please port your code to the new
API; its documentation can be found on the Lab::Measurement homepage.

=head1 SEE ALSO

=over 4

=item L<Lab::Measurement::Manual>

=item L<Lab::Measurement::Tutorial>

=item L<Lab::Measurement::Roadmap>

=item L<https://www.labmeasurement.de/>

=back

=cut
