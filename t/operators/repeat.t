use v6-alpha;

use Test;

=kwid

Repeat operators for strings and lists

=cut

plan 23;

#L<S03/Changes to Perl 5 operators/"x (which concatenates repetitions of a string to produce a single string">

is('a' x 3, 'aaa', 'string repeat operator works on single character');
is('ab' x 4, 'abababab', 'string repeat operator works on multiple character');
is(1 x 5, '11111', 'number repeat operator works on number and creates string');
is('' x 6, '', 'repeating an empty string creates an empty string');
is('a' x 0, '', 'repeating zero times produces an empty string');
is('a' x -1, '', 'repeating negative times produces an empty string');

#L<S03/Changes to Perl 5 operators/"and xx (which creates a list of repetitions of a list or item)">
my @foo = 'x' xx 10;
is(@foo[0], 'x', 'list repeat operator created correct array');
is(@foo[9], 'x', 'list repeat operator created correct array');
is(+@foo, 10, 'list repeat operator created array of the right size');


lives_ok { my @foo2 = undef xx 2; }, 'can repeat undefs';
my @foo3 = (1, 2) xx 2;
is(@foo3[0], 1, 'can repeat lists');
is(@foo3[1], 2, 'can repeat lists');
is(@foo3[2], 1, 'can repeat lists');
is(@foo3[3], 2, 'can repeat lists');

my @foo4 = 'x' xx 0;
is(+@foo4, 0, 'repeating zero times produces an empty list');

my @foo5 = 'x' xx -1;
is(+@foo5, 0, 'repeating negative times produces an empty list');

my @foo_2d = [1, 2] xx 2; # should create 2d
is(@foo_2d[1], [1, 2], 'can create 2d arrays', :todo<bug>); # creates a flat 1d array
# Wrong/unsure: \(1, 2) does not create a ref to the array/list (1,2), but
# returns a list containing two references, i.e. (\1, \2).
#my @foo_2d2 = \(1, 2) xx 2; # just in case it's a parse bug
#is(@foo_2d[1], [1, 2], 'can create 2d arrays (2)', :todo<bug>); # creates a flat 1d array

# test x=
my $twin = 'Lintilla';
ok($twin x= 2, 'operator x= for string works');
is($twin, 'LintillaLintilla', 'operator x= for string repeats correct');

my @array = (4, 2);
ok(@array xx= 2, 'operator xx= for list works');
is(@array[0], 4, 'operator xx= for list repeats correct');
is(@array[3], 2, 'operator xx= for list repeats correct');
is(+@array, 4, 'operator xx= for list created the right size');
