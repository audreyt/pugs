use v6-alpha;

use Test;

=begin pod

The zip() builtin and operator tests

L<S03/"Traversing arrays in parallel">
L<S29/Container/"=item zip">

=end pod

plan 9;

{
    my @a = (0, 2, 4);
    my @b = (1, 3, 5);

    my @e = (0 .. 5);

    my @z; @z = zip(@a; @b);
    my @x; @x = (@a Z @b);

    is(~@z, ~@e, "simple zip");
    is(~@x, ~@e, "also with Z char");
};

{
    my @a = (0, 3);
    my @b = (1, 4);
    my @c = (2, 5);

    my @e = (0 .. 5);

    my @z; @z = zip(@a; @b; @c);
    my @x; @x = (@a Z @b Z @c);

    is(~@z, ~@e, "zip of 3 arrays");
    is(~@x, ~@e, "also with Z char");
};

{
    my @a = (0, 4);
    my @b = (2, 6);
    my @c = (1, 3, 5, 7);

    # [((0, 2), 1), ((4, 6), 3), (undef, 5), (undef, 7)]
    my $todo = 'Seq(Seq(0,2),1), Seq(Seq(0,2),1), Seq(undef,5), Seq(undef,7)';
    my @e = eval $todo;

    my @z; @z = zip(zip(@a; @b); @c);
    my @x; @x = ((@a Z @b) Z @c);

    is(~@z, ~@e, "zip of zipped arrays with other array", :todo<feature>,
        :depends<Seq>);
    is(~@x, ~@e, "also as Z", :todo<feature>, :depends<Seq>);
};

{
    my @a = (0, 2);
    my @b = (1, 3, 5);
    my @e = (0, 1, 2, 3);

    my @z = (@a Z @b);
    is(@z, @e, "zip uses length of shortest");
}

{
    my @a;
    my @b;

    (@a Z @b) = (1, 2, 3, 4);
    # XXX - The arrays below are most likely Seq's
    is(@a, [1, 3], "first half of two zipped arrays as lvalues", :todo);
    is(@b, [2, 4], "second half of the lvalue zip", :todo);
}
