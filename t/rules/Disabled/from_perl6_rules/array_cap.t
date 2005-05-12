#!/usr/bin/pugs

use v6;
use Test;

=pod

This file was derived from the perl5 CPAN module Perl6::Rules,
version 0.3 (12 Apr 2004), file t/array_cap.t.

It has (hopefully) been, and should continue to be, updated to
be valid perl6.

=cut

plan 44;

ok("  a b\tc" ~~ m/@<chars>:=[ \s+ \S+ ]+/, 'Named simple array capture');
is(join("|",@{$/<chars>}), "  a| b|\tc", 'Captured strings');

ok("  a b\tc" ~~ m/@<first>:=[ \s+ \S+ ]+ @<last>:=[ \s+ \S+]+/, 'Sequential simple array capture');
is(join("|",@{$/<first>}), "  a| b", 'First captured strings');
is(join("|",@{$/<last>}), "\tc", 'Last captured strings');

ok("abcxyd" ~~ m/a  @<foo>:=(.(.))+ d/, 'Repeated hypothetical array capture');
is("@{$/<foo>}", "c y", 'Hypothetical variable captured');
ok(%$/.keys == 1, 'No extra captures');

ok("abcd" ~~ m/a  @<foo>:=(.(.))  d/, 'Hypothetical array capture');
is("@{$/<foo>}", "c", 'Hypothetical variable captured');

our @GA;
ok("abcxyd" ~~ m/a  @GA:=(.(.))+  d/, 'Global array capture');
is("@GA", "c y", 'Global array captured');
ok(%$/.keys == 0, 'No vestigal captures');

my @foo;
ok("abcxyd" ~~ m/a  @foo:=(.(.))+  d/, 'Package array capture');
is("@foo", "c y", 'Package array captured');

rule two {..}

ok("abcd" ~~ m/a  @<foo>:=(<two>)  d/, 'Compound hypothetical capture');
is($/[0]<two>, "bc", 'Implicit hypothetical variable captured');
ok(! @{$/<foo>}, 'Explicit hypothetical variable not captured');

ok("  a b\tc" ~~ m/@<chars>:=( @<spaces>:=[\s+] (\S+))+/, 'Nested array capture');
is("@{$/<chars>}", "a b c", 'Outer array capture');
is(join("|",@{$/<spaces>}), "  | |\t", 'Inner array capture');

rule spaces { @<spaces>:=[(\s+)] }

ok("  a b\tc" ~~ m/@<chars>:=( <spaces> (\S+))+/, 'Subrule array capture');

is("@{$/<chars>}", "a b c", 'Outer rule array capture');
is($/<spaces>, "\t", 'Final subrule array capture');

ok("  a b\tc" ~~ m/@<chars>:=( @<spaces>:=[<?spaces>] (\S+))+/, 'Nested subrule array capture');
is("@{$/<chars>}", "a b c", 'Outer rule nested array capture');
is(join("|",@{$/<spaces>}), "  | |\t", 'Subrule array capture');


ok("  a b\tc" ~~ m/@<chars>:=[ (<?spaces>) (\S+)]+/, 'Nested multiple array capture');
is(ref $/<chars>, "Array", 'Multiple capture to nested array');
ok(@{$/<chars>} == 3, 'Multiple capture count');
is(ref $/<chars>[0], "Match", 'Multiple capture to nested AoA[0]');
is(ref $/<chars>[1], "Match", 'Multiple capture to nested AoA[2]');
is(ref $/<chars>[2], "Match", 'Multiple capture to nested AoA[3]');
is($/<chars>[0][0], "  ", 'Multiple capture value of nested AoA[0][0]');
is($/<chars>[0][1], "a", 'Multiple capture value of nested AoA[0][1]');
is($/<chars>[1][0], " ", 'Multiple capture value of nested AoA[1][0]');
is($/<chars>[1][1], "b", 'Multiple capture value of nested AoA[1][1]');
is($/<chars>[2][0], "\t", 'Multiple capture value of nested AoA[2][0]');
is($/<chars>[2][1], "c", 'Multiple capture value of nested AoA[2][1]');


my @bases = ();
ok("GATTACA" ~~ m/ @bases:=[A|C|G|T]+ /, 'All your bases...');
is("@bases", "G A T T A C A", '...are belong to us');

@bases = ();
ok("GATTACA" ~~ m/ @bases:=[A|C|G|T]**{4} (@bases+) /, 'Array reinterpolation');
is("@bases", "G A T T", '...are belong to...');
is("$0", "ACA", '...ACA');
