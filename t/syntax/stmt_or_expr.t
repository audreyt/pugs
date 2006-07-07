use v6-alpha;

use Test;

plan 2;

my $x = do {
	10
} + 1;

is($x, 11, "'} + 1' is in a single statement");

my $y = do {
	10
}
+ 1;

# L<A04/"RFC 022: Control flow: Builtin switch statement" /the final curly is on a line by itself/>

is($y, 10, "}\\n + 1 are two statements", :todo<bug>);



