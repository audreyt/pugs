use v6-alpha;

use Test;

=pod

This file was derived from the perl5 CPAN module Perl6::Rules,
version 0.3 (12 Apr 2004), file t/rulecode.t.

It has (hopefully) been, and should continue to be, updated to
be valid perl6.

=cut

plan 4;

if !eval('("a" ~~ /a/)') {
  skip_rest "skipped tests - rules support appears to be missing";
} else {

regex abc { <null> a b c }  # coredumps without the <null> for some reason

my $var = "";
ok("aaabccc" ~~ m/aa <{ $var ?? $var !! rx{abc} }> cc/, 'Rule block second', :todo<feature>);

$var = rx/<?abc>/;
ok("aaabccc" ~~ m/aa <{ $var ?? $var !! rx{<?null>} }> cc/, 'Rule block first', :todo<feature>);

$var = rx/xyz/;
ok(!( "aaabccc" ~~ m/aa <{ $var ?? $var !! rx{abc} }> cc/ ), 'Rule block fail');

$var = rx/<?abc>/;
ok("aaabccc" ~~ m/aa <{ $var ?? $var !! rx{abc} }> cc/, 'Rule block interp', :todo<feature>);

}

