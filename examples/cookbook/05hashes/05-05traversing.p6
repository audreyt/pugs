#!/usr/bin/perl6

use v6;

=head1 Traversing a hash

You want to perform an action on each entry (i.e., each pair) in a hash.

=cut

my %hash = (
    'one'   => 'un',
    'two'   => 'deux',
    'three' => 'trois'
);

for (%hash.kv) -> $key, $value {
    say "The word '$key' is '$value' in French.";
}

for (%hash.keys) -> $key {
    say "$key => %hash{$key}";
}

for %hash {
    say $_; # hmm ...
}
