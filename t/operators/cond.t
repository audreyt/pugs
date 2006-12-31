use v6-alpha;

use Test;

=kwid

Tests some basic conditional operators
(==, !=, eq and ne)

=cut

plan 6;

#L<S03/Changes to Perl 5 operators/"same as in Perl 5">

my $x = '1';
my $y = 'a';

ok $x eq $x, "check that eq works";
ok $x == $x, "check that == works";
ok $x ne $y, "check string comparsion";

# Comparison using auto conversion from num->str and str->num.
ok $x == 1, "check conversion from number to string";
ok 1 == $x, "check string conversion to number";

ok 3 != 4, "check that != works";
