#!/usr/bin/perl6

use v6;

=head1 Swapping values

You want to swap values without using a temporary variable

=cut

my ($x, $y) = (3,2);
($x, $y) = ($y, $x);
# XXX Binding (:=) is more efficient, because it doesn't copy the values.
# XXX Compile-time binding (::=) could not be used here, as the cells
#     would be swapped at compile-time, not runtime. ::= doesn't have an effect
#     at runtime:
#         $a ::= $b;  # sugar for
#         BEGIN { $a := $b }
say $x;
say $y;
