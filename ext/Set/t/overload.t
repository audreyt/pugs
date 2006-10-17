use v6-alpha;
use Test;

plan 38;

use Set;

class Person {};

my $bob = Person.new;
my $bert = Person.new;

my $set = set(0, 1, 2, 3, $bob);
my $union = $set + set(4,5,6);
isa_ok($union, Set, "set() - infix:<+>");

my $stringified = ~$set;
ok($stringified ~~ rx:P5/^set\(.*Person.*\)$/, "prefix:<~>", :todo<bug>);

ok($union == set(0..6, $bob), "set() - infix:<==>");
ok(!($union != set(0..6, $bob)), "set() - !infix:<!=>");

ok($union != set(0..5, $bob), "set() - infix:<!=>");
ok(!($union == set(0..5, $bob)), "set() - !infix:<==>");

ok($union != set(0..6, $bob, $bert), "set() - infix:<!=>");
ok(!($union == set(0..6, $bob, $bert)), "set() - !infix:<==>");

my $other_set = set(2..3, 7, $bob, $bert);

my $intersection = $set * $other_set;
is($intersection, set(2..3, $bob), "intersection");

my $difference = $set - $other_set;
is($difference, set(0,1), "difference");

my $sym_difference = $set % $other_set;
is($sym_difference, set(0,1,7,$bert), "symmetric_difference");

is( ($set - $other_set) + ($other_set - $set), $set % $other_set,
    "long form of symmetric difference");

my ($homer, $marge, $bart, $lisa, $maggie) = (1..5).map:{ Person.new };

my $simpsons = set($homer, $marge, $bart, $lisa, $maggie);
my $parents = set($homer, $marge);
my $empty = set();

ok($parents < $simpsons, 'infix:"<"');
ok(!($simpsons < $parents), '!infix:"<"');
ok(!($parents < $parents), '!infix:"<" (equal sets)');

ok($parents <= $simpsons, 'infix:"<="');
ok(!($simpsons <= $parents), '!infix:"<="');
ok($parents <= $parents, 'infix:"<=" (equal sets)');

ok($empty < $simpsons, "infix:'<' (empty)");
ok($empty <= $simpsons, "infix:'<=' (empty)");

ok($simpsons > $parents, "infix:'>'");
ok(!($parents > $simpsons), "!infix:'>'");
ok(!($parents > $parents), "!infix:'>' (equal sets)");

ok($simpsons >= $parents, "infix:'>='");
ok(!($parents >= $simpsons), "!infix:'>='");
ok($parents >= $parents, "infix:'>=' (equal sets)");

ok($simpsons > $empty, "infix:'>' (empty)");
ok($parents >= $empty, "infix:'>=' (empty)");

ok((set(1,2,3) ∋ 1), "infix:<∋>");

# Smartmatch operator
ok     42 ~~ set(23, 42, 63),  "infix:<~~> works (1)";
ok not(42 ~~ set(23, 43, 63)), "infix:<~~> works (2)";

# Rubyish set operations on arrays
# Note: We only test for the correct number of elements, as there's no
# particular order.

# "Why do you write "+[hash]" instead of "+#" in the test descriptions?"
# -- The test harness doesn't get that the "#" in "+#" does not start a
# comment, and thus doesn't interpret the "# TODO feature".
is eval('+([1,2,3] +# [1,2,3])'),   3, "infix:<+[hash]> works (1)";
is eval('+([1,2,3] +# [1,2,3,4])'), 4, "infix:<+[hash]> works (2)";
is eval('+([1,2,3] -# [1,2,3])'),   0, "infix:<-[hash]> works (1)";
is eval('+([1,2,3] -# [1,2,3,4])'), 0, "infix:<-[hash]> works (2)";
is eval('+([1,2,3] *# [2,3])'),     2, "infix:<*[hash]> works (1)", :todo<feature>;
is eval('+([1,2,3] *# [])'),        0, "infix:<*[hash]> works (2)", :todo<feature>;
is eval('+([1,2,3] %# [1,2,6])'),   2, "infix:<%[hash]> works",     :todo<feature>;
