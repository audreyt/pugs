use v6-alpha;

use Test;

plan 4;

unless "a" ~~ rx:P5/a/ {
  skip_rest "skipped tests - P5 regex support appears to be missing";
  exit;
}

# returns the count of matches in scalar
my $vals = "hello world" ~~ rx:perl5:g{(\w+)};
is($vals, 2, 'returned two values in the match');

# return all the strings we matched
my @vals = "hello world" ~~ rx:perl5:g{(\w+)};
is(+@vals, 2, 'returned two values in the match');
is(@vals[0], 'hello', 'returned correct first value in the match');
is(@vals[1], 'world', 'returned correct second value in the match');
