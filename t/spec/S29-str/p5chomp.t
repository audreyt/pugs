use v6-alpha;
use Test;

=begin pod

L<S29/Str/"=item p5chomp">

=end pod

plan 6;

my $string = "abc";

is(p5chomp($string), 0, 'p5chomp leaves strings untouched that don\'t end in \n');
is($string, "abc", 'p5chomp did not change "abc"');

$string = "abc\n\n";

is(p5chomp($string), 1, 'p5chomp removes one \n even if the string ends in \n\n');
is($string, "abc\n", 'p5chomp removed one \n');

my @s = "abc", "def\n", "gh\n";
is(p5chomp(@s), 2, 'p5chomp on lists returns the number of removed \ns');
is(@s, <abc def gh>, 'p5chomp on lists works');
