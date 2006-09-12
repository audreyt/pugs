use v6-alpha;
use Test;
plan 8;

# L<S02/"Built-In Data Types" /Perl 6 should by default make standard IEEE floating point concepts visible/>

{
    my $x = Inf;
    
    cmp_ok( $x, &infix:<==>, Inf,   'numeric equal' );
    cmp_ok( $x, &infix:<eq>, 'Inf', 'string equal'  );
}

{
    my $x = -Inf;
    cmp_ok( $x, &infix:<==>, -Inf,   'negative numeric equal' );
    cmp_ok( $x, &infix:<eq>, '-Inf', 'negative string equal'  );
}

{
    my $x = int( Inf );
    cmp_ok( $x, &infix:<==>,  Inf,  'int numeric equal' );
    cmp_ok( $x, &infix:<eq>, 'Inf', 'int string equal', :todo<bug> );
}

{
    my $x = int( -Inf );
    cmp_ok( $x, &infix:<==>,  -Inf,   'int negative numeric equal');
    cmp_ok( $x, &infix:<eq>, '-Inf',  'int negative string equal', :todo<bug> );
}

# Inf should == Inf. Additionally, Inf's stringification (~Inf), "Inf", should
# eq to the stringification of other Infs.
# Thus:
#     Inf == Inf     # true
# and:
#     Inf  eq  Inf   # same as
#     ~Inf eq ~Inf   # true
