use v6-alpha;

use Test;

plan 12;

{
    # Compare with Perl 5:
    #   $ perl -we '
    #     my @array = qw<a b c>;
    #     my $foo = $array[100];
    #     print exists $array[30] ? "exists" : "does not exist"
    #   '
    #   does not exist
    my @array = <a b c d>;
    is +@array, 4, "basic sanity";
    my $foo = @array[20];
    # We've only *accessed* @array[20], but we haven't assigned anything to it, so
    # @array shouldn't change. But currently, @array *is* automatically extended,
    # i.e. @array is ("a", "b", "c", "d", undef, undef, ...). This is wrong.
    is +@array, 4,
      "accessing a not existing array element should not automatically extend the array";
}

{
    my @array = <a b c d>;
    @array[20] = 42;
    # Now, we did assign @array[20], so @array should get automatically extended.
    # @array should be ("a", "b", "c", "d", undef, undef, ..., 42).
    is +@array, 21,
      "creating an array element should automatically extend the array (1)";
    # And, of course, @array.exists(20) has to be true -- we've just assigned
    # @array[20].
    ok @array.exists(20),
      "creating an array element should automatically extend the array (2)";
}

{
    my @array   = <a b c d>;
    my $defined = defined @array[100];

    ok !$defined,
        'defined @array[$index_out_of_bounds] should be false';
    is +@array, 4,
        'defined @array[$index_out_of_bounds] should not have altered @array', :todo<feature>;
}

{
    my @array   = <a b c d>;
    my $defined;
    try { $defined = defined @array[-5]; }

    ok !$defined,
        'defined @array[$negative_index_out_of_bounds] should be false';
    is +@array, 4,
        'defined @array[$negative_index_out_of_bounds] should not have altered @array';
}

{
    my @array  = <a b c d>;
    my $exists = @array.exists(100);

    ok !$exists,
        '@array.exists($index_out_of_bounds) should be false';
    is +@array, 4,
        '@array.exists($index_out_of_bounds) should not have altered @array';
}

{
    my @array  = <a b c d>;
    my $exists = @array.exists(-5);

    ok !$exists,
        '@array.exists($negative_index_out_of_bounds) should be false';
    is +@array, 4,
        '@array.exists($negative_index_out_of_bounds) should not have altered @array';
}
