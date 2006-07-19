use v6-alpha;
use Test;

=pod

This file was derived from the perl5 CPAN module Perl6::Rules,
version 0.3 (12 Apr 2004), file t/qinterp.t.

It has (hopefully) been, and should continue to be, updated to
be valid perl6.

=cut

plan 4;

skip_rest "This file was in t_disabled/.  Remove this SKIP of it now works.";
exit;

if !eval('("a" ~~ /a/)') {
  skip_rest "skipped tests - rules support appears to be missing";
} else {

ok("ab cd" ~~ m/a <'b c'> d/, 'ab cd 1');
ok(!( "abcd" ~~ m/a <'b c'> d/ ), 'not abcd 1');
ok("ab cd" ~~ m/ab <' '> c d/, 'ab cd 2');
ok("ab/cd" ~~ m/ab <'/'> c d/, 'ab/cd');

}

