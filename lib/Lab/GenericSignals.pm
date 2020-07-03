package Lab::GenericSignals;

#ABSTRACT: Signal handling

use v5.20;

use warnings;
use strict;

use sigtrap 'handler' => \&abort_all, qw(normal-signals error-signals);

sub abort_all {
    foreach my $object ( @{Lab::Generic::OBJECTS} ) {
        $object->abort();
    }
    @{Lab::Generic::OBJECTS} = ();
    exit;
}

END {
    abort_all();
}

1;
