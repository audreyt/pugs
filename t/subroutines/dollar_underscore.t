use v6-pugs;

# Tests for a bug uncovered when Jesse Vincent was testing 
# functionality for Patrick Michaud


use Test;

plan 3;


my @list = ('a');


# according to A06: L<A06/"Lexical context">    
#
#   Methods, submethods, macros, rules, and pointy subs all  
#   bind their first argument to C<$_>; ordinary subs declare
#   a lexical C<$_> but leave it undefined.   

# Do pointy subs send along a declared param?

for @list -> $letter { is( $letter , 'a') }

# Do pointy subs send along an implicit param? No!
for @list -> { isnt($_, 'a') }
# Hm. PIL2JS currently dies here (&statement_control:<for> passes one argument
# to the block, but the block doesn't expect any arguments). Is PIL2JS correct?


# Do pointy subs send along an implicit param even when a param is declared
# (See the quote from A06 above)
for @list -> $letter { is( $_ ,'a' ) }


