use v6-alpha;

use Test;

=pod

This file was derived from the perl5 CPAN module Perl6::Rules,
version 0.3 (12 Apr 2004), file t/repeat.t.

It has (hopefully) been, and should continue to be, updated to
be valid perl6.

=cut

plan 6;

if !eval('("a" ~~ /a/)') {
  skip_rest "skipped tests - rules support appears to be missing";
} else {

force_todo(1,3,5);

# L<S05/Bracket rationalization/The general repetition specifier is now>

ok("abcabcabcabcd"    ~~ m/[abc]**{4}/, 'Fixed exact repetition');
ok(!( "abcabcabcabcd" ~~ m/[abc]**{5}/ ), 'Fail fixed exact repetition');
ok("abcabcabcabcd"    ~~ m/[abc]**{2..4}/, 'Fixed range repetition');
ok(!( "abc"           ~~ m/[abc]**{2..4}/ ), 'Fail fixed range repetition');
ok("abcabcabcabcd"    ~~ m/[abc]**{2..}/, 'Open range repetition');
ok(!( "abcd"          ~~ m/[abc]**{2..}/ ), 'Fail open range repetition');

}

