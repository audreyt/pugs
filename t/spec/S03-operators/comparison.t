use v6-alpha;
use Test;

plan 9;

# N.B.:  relational ops are in relational.t

#L<S03/Comparison semantics>

# spaceship comparisons (Num)
is(1 <=> 1, 0,  '1 <=> 1 is same');
is(1 <=> 2, -1, '1 <=> 2 is increase');
is(2 <=> 1, 1,  '2 <=> 1 is decrease');

# leg comparison (Str)
is('a' leg 'a', 0,  'a leg a is same');
is('a' leg 'b', -1, 'a leg b is increase');
is('b' leg 'a', 1,  'b leg a is decrease');

#L<S03/Comparison semantics>

# cmp comparison
is('a' cmp 'a', 0,  'a cmp a is same');
is('a' cmp 'b', -1, 'a cmp b is increase');
is('b' cmp 'a', 1,  'b cmp a is decrease');


