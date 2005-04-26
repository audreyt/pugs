#!/usr/bin/pugs

use v6;
use Test;

=kwid

String appending with ~ operator

=cut

plan 4;

# Again, mostly stolen from Perl 5

my $a = 'ab' ~ 'c';
is($a, 'abc', '~ two literals correctly');

my $b = 'def';

my $c = $a ~ $b;
is($c, 'abcdef', '~ two variables correctly');

$c ~= "xyz";
is($c, 'abcdefxyz', '~= a literal string correctly');

my $d = $a;
$d ~= $b;
is($d, 'abcdef', '~= variable correctly');
