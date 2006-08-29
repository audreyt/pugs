use v6-alpha;

use Test;

=kwid

Splatted parameters shouldn't be rw even if stated as such

=cut

plan 3;

# test splatted parameter for rw ability

my @test = 1..5;
try {
    sub should_fail ( *@list is rw ) {
        @list[0] = "failure expected"; 
    }
    should_fail(@test);
};

ok(
    defined($!),
    "trying to use an 'is rw' splat doesn't work out",
    :todo<feature>
);
is(@test[0], 1, "@test was unchanged");

try {
    sub should_fail (*@list is rw) { }
};

ok(
    defined($!),
    "trying to define an 'is rw' splat doesn't work either",
    :todo<feature>
);
