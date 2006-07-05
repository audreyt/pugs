use v6-pugs;

use Test;

=pod

This file was derived from the perl5 CPAN module Perl6::Rules,
version 0.3 (12 Apr 2004), file t/inline.t.

It has (hopefully) been, and should continue to be, updated to
be valid perl6.

=cut

plan 2;

if(!eval('("a" ~~ /a/)')) {
  skip_rest "skipped tests - rules support appears to be missing";
} else {

ok("abcDEFghi" ~~ m/abc (:i def) ghi/, 'Match');
ok(!( "abcDEFGHI" ~~ m/abc (:i def) ghi/ ), 'Mismatch');

}

