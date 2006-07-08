use v6-alpha;
use Test;

=pod

This file was derived from the perl5 CPAN module Perl6::Rules,
version 0.3 (12 Apr 2004), file t/noncap.t.

It has (hopefully) been, and should continue to be, updated to
be valid perl6.

=cut

plan 8;

skip_rest "This file was in t_disabled/.  Remove this SKIP of it now works.";
exit;

if(!eval('("a" ~~ /a/)')) {
  skip_rest "skipped tests - rules support appears to be missing";
} else {

my $str = "abbbbbbbbc";

ok($str ~~ m{a(b+)c}, 'Matched 1');
ok($/, 'Saved 1');
is($/, $str, 'Grabbed all 1');
is($/[0], substr($str,1,-1), 'Correctly captured 1');

ok($str ~~ m{a[b+]c}, 'Matched 2');
ok($/, 'Saved 2');
is($/, $str, 'Grabbed all 2');
ok(!defined $/[0], "Correctly didn't capture 2");

}

