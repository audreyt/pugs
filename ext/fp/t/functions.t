use v6;
use Test;

use fp;

plan 5;

is identity(3),  3, "id() works";
is const(3).(5), 3, "const() works";

is ~tail((1,2,3)), "2 3", "tail() works";
is ~init((1,2,3)), "1 2", "init() works";

is ~replicate(3, { state $x; ++$x }), "1 2 3", "take() with a Code works";
