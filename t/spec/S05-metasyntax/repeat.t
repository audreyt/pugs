use v6;

use Test;

=begin pod

This file was derived from the perl5 CPAN module Perl6::Rules,
version 0.3 (12 Apr 2004), file t/repeat.t.

It has (hopefully) been, and should continue to be, updated to
be valid perl6.

=end pod

# Note: single-quotes.t tests repetition on single quoted items in regexes.

plan 17;

# L<S05/Bracket rationalization/The general repetition specifier is now>

# Exact repetition
ok("abcabcabcabcd" ~~ m/[abc]**4/, 'Fixed exact repetition');
ok("abcabcabcabcd" ~~ m/[abc]**5/, 'Fail fixed exact repetition');
#?pugs todo force_todo
ok("abcabcabcabcd"    ~~ m/[abc]**{4}/, 'Fixed exact repetition using closure');
ok(!( "abcabcabcabcd" ~~ m/[abc]**{5}/ ), 'Fail fixed exact repetition using closure');

# Closed range repetition
ok("abcabcabcabcd" ~~ m/[abc]**2..4/, 'Fixed range repetition');
ok(!( "abc"        ~~ m/[abc]**2..4/ ), 'Fail fixed range repetition');
#?pugs todo force_todo
ok("abcabcabcabcd" ~~ m/[abc]**{2..4}/, 'Fixed range repetition using closure');
ok(!( "abc"        ~~ m/[abc]**{2..4}/ ), 'Fail fixed range repetition using closure');

# Open range repetition
ok("abcabcabcabcd" ~~ m/[abc]**2..*/, 'Open range repetition');
ok(!( "abcd"       ~~ m/[abc]**2..*/ ), 'Fail open range repetition');
#?pugs todo force_todo
ok("abcabcabcabcd" ~~ m/[abc]**{2..*}/, 'Open range repetition using closure');
ok(!( "abcd"       ~~ m/[abc]**{2..*}/), 'Fail open range repetition using closure');

# It is illegal to return a list, so this easy mistake fails:
eval_dies_ok('"foo" ~~ m/o{1,3}/', 'P5-style {1,3} range mistake is caught');
eval_dies_ok('"foo" ~~ m/o{1,}/}',  'P5-style {1,} range mistake is caught');

# XXX Is it specced that smartmatching m// returns the matched string?
# A successful match of such a quantifier always ends "in the middle"
is('foo,bar,baz,' ~~ m/<alpha> ** ','/, 'foo,bar,baz', '** with a term worked');
is('foo,bar,baz,' ~~ m/<alpha>**? ','/, 'foo', '**? with a term worked');
is('foo, bar,' ~~ m/<alpha>**[','\s*]/, 'foo, bar', '** with a more complex term');
