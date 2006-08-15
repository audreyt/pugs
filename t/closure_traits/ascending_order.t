use v6-alpha;

# Test the running order of BEGIN/CHECK/INIT/END
# These blocks appear in ascending order
# [TODO] add tests for ENTER/LEAVE/KEEP/UNDO/PRE/POST/etc

use Test;

plan 7;

# L<S04/Closure traits/END "at run time" ALAP>

my $var;
my ($var_at_begin, $var_at_check, $var_at_init, $var_at_start, $var_at_enter);
my $eof_var;

$var = 13;

my $hist;

BEGIN {
    $hist ~= 'begin ';
    $var_at_begin = $var;
}

CHECK {
    $hist ~= 'check ';
    $var_at_check = $var;
}

INIT {
    $hist ~= 'init ';
    $var_at_init = $var;
}

ENTER {
    $hist ~= 'enter ';
    $var_at_enter = $var;
}

START {
    $hist ~= 'start ';
    $var_at_start = $var + 1;
}

END {
    # tests for END blocks:
    is $var, 13, '$var gets initialized at END time';
    is $eof_var, 29, '$eof_var gets assigned at END time';
}

is $hist, 'begin check init start ', 'BEGIN {} runs only once';
is $var_at_begin, undef, 'BEGIN {...} ran at compile time';
is $var_at_check, undef, 'CHECK {...} ran at compile time';
is $var_at_init, undef, 'INIT {...} ran at runtime, but ASAP';
is $var_at_enter, undef, 'ENTER {...} at runtime, but before the mainline body';
is $var_at_start, 14, 'START {...} at runtime, just in time';

$eof_var = 29;
