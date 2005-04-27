#!/usr/bin/pugs

use Test;
use v6;

plan 6;

=head1 DESCRIPTION

This test tests the C<uniq> builtin.

Reference:
L<http://groups.google.com/groups?selm=420DB295.3000902%40conway.org>

=cut

my @array = <5 -3 7 0 1 -9>;

# Tests for C<min>:
eval_is '@array.min', -9, "basic method form of min works", :todo;
eval_is 'min @array', -9, "basic subroutine form of min works", :todo;
eval_is '@array.min:{ abs $^a <=> abs $^b }', 0,
  "method form of min taking a comparision block works", :todo;

# Tests for C<max>:
eval_is '@array.max',  7, "basic method form of max works", :todo;
eval_is 'max @array',  7, "basic subroutine form of max works", :todo;
eval_is '@array.max:{ abs $^a <=> abs $^b }', 9,
  "method form of max taking a comparision block works", :todo;
