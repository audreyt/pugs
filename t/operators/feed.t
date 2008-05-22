use v6;

use Test;

=pod

Tests for the feed operators 

    ==> and <== 
    
L<S06/"Feed operators">
L<S03/"Feed operators">

=cut

plan 7;

{
    my @a = (1, 2);
    my (@b, @c);
    
    eval '@a ==> @b';
    #eval '@c <== @a'; # this yields the error:
    #Fail: cannot cast into a handle: VList [VInt 1,VInt 2]

    is(~@b, ~@a, "ltr feed as simple assignment", :todo);
    is(~@c, ~@a, "rtl feed as simple assignment", :todo);
};

{
    my @a = (1 .. 5);
    my @e = (2, 4);

    my (@b, @c);
    eval '@a ==> grep { ($_ % 2) == 0 } ==> @b';
    #eval '@c <== grep { ($_ % 2) == 0 } <== @a';

    is(~@b, ~@e, "array ==> grep ==> result", :todo);
    is(~@c, ~@e, "result <== grep <== array", :todo);
};

{
    my ($got_x, $got_y, @got_z);
    sub foo ($x, $y?, *@z) {
        $got_x = $x;
        $got_y = $y;
        @got_z = @z;
    }

    my @a = (1 .. 5);

    eval '@a ==> foo "x"';

    is($got_x, "x", "x was passed as explicit param", :todo);
    is($got_y, undef, "optional param y was not bound to fed list");
    is(~@got_z, ~@a, '...slurpy array *@z got it', :todo);
};
