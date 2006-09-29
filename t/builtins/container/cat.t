use v6-alpha;

use Test;

plan 6;

# L<S29/Container/"=item cat">

=pod

Tests of

  our Lazy multi Container::cat( *@@list );

=cut

ok(cat() eqv (), 'cat null identity');

ok(cat(1) eqv (1,), 'cat scalar identity');

ok(cat(1..3) eqv 1..3, 'cat list identity');

ok(cat([1..3]) eqv 1..3, 'cat array identity');

# These below work.  Just waiting on eqv.

ok(cat({'a'=>1,'b'=>2,'c'=>3}) eqv ('a'=>1, 'b'=>2, 'c'=>3),
    'cat hash identity', :todo<feature>, :depends<eqv>);

ok(cat((); 1; 2..4; [5..7], {'a'=>1,'b'=>2}) eqv (1..7, 'a'=>1, 'b'=>2),
    'basic cat', :todo<feature>, :depends<eqv>);
