use v6-alpha;

use Test;
plan 11;

# L<S29/Hash/=item delete>

=begin pod

Test delete method of Spec Functions.

  our List  multi method Hash::delete ( *@keys )
  our Scalar multi method Hash::delete ( $key ) is default

  Deletes the elements specified by C<$key> or C<$keys> from the invocant.
  returns the value(s) that were associated to those keys.

=end pod

sub gen_hash {
    my %h;
    my $i;
    for 'a'..'z' { %h{$_} = ++$i; }
    return %h;
}

{
    my %h1 = gen_hash;
    my %h2 = gen_hash;

    my $b = %h1<b>;
    is delete(%h1, <b>), $b, "Test for delete single key. (Indirect notation)";
    is %h2.delete(<b>), $b, "Test for delete single key. (Method call)";

    my @cde = %h1<c d e>;
    is delete(%h1, <c d e>), @cde, "test for delete multiple keys. (Indirect notation)";
    is %h2.delete(<c d e>), @cde, "test for delete multiple keys. (method call)";
}


my %hash = (a => 1, b => 2, c => 3, d => 4);

is +%hash, 4, "basic sanity (2)";
is ~%hash.delete("a"), "1",
  "deletion of a hash element returned the right value";
is +%hash, 3, "deletion of a hash element";
is ~%hash.delete("c", "d"), "3 4",
  "deletion of hash elements returned the right values";
is +%hash, 1, "deletion of hash elements";
ok !defined(%hash{"a"}), "deleted hash elements are really deleted";

{
    my $a = 1;
    try { delete $a; };
    like($!, rx:P5/Argument is not a Hash or Array element or slice/, "expected message for mis-use of delete");
}

