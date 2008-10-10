use v6;

use Test;
plan 9;

# L<S02/Names and Variables/:delete>

sub gen_hash {
    my %h;
    my $i = 0;
    for 'a'..'z' { %h{$_} = ++$i; }
    return %h;
}

{
    my %h1 = gen_hash;

    my $b = %h1<b>;
    is %h1<b>:delete, $b, "Test for delete single key.";
}

#?rakudo todo 'Slices'
{
    my %h1 = gen_hash;
    my @cde = %h1<c d e>;
    is %h1<c d e>:delete, @cde, "test for delete multiple keys.";
}


my %hash = (a => 1, b => 2, c => 3, d => 4);

is +%hash, 4, "basic sanity (2)";
is ~(%hash<a>:delete), "1",
  "deletion of a hash element returned the right value";
is +%hash, 3, "deletion of a hash element";
{
    is ~(%hash{"c", "d"}:delete), "3 4",
    "deletion of hash elements returned the right values";
    is +%hash, 1, "deletion of hash elements";
}
ok !defined(%hash{"a"}), "deleted hash elements are really deleted";

{
    my $a = 1;
    try { $a :delete; };
    # XXX do we really want to test against a specific error message?
    #?rakudo 1 skip "no rx:P5"
    like($!, rx:P5/Argument is not a Hash or Array element or slice/, "expected message for mis-use of delete");
}

