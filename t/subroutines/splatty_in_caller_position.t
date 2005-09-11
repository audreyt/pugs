#!/usr/bin/pugs

use v6;
use Test;

plan 4;

# L<S03/"List Flattening">

# try to flatten the args for baz() to match

sub baz ($a, $b) { return "a: $a b: $b"}
sub invoke (*@args) { baz(*@args) }

my $val;
lives_ok {
    $val = invoke(1, 2);
}, '... slurpy args flattening and matching parameters', :todo<bug>;

is($val, 'a: 1 b: 2', '... slurpy args flattening and matching parameters', :todo<bug>);

# try to flatten the args for the anon sub to match

sub invoke2 ($f, *@args) { $f(*@args) }; 
is(try { invoke2(sub ($a, $b) { return "a: $a b: $b"}, 1, 2) }, 'a: 1 b: 2', 
    '... slurpy args flattening and matching parameters', :todo<bug>);    

dies_ok {
    invoke2(sub ($a, $b) { return "a: $a b: $b"}, 1, 2, 3);
}, '... slurpy args flattening and not matching because of too many parameters';  
