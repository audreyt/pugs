use v6;

use Test;

plan 4;

# L<S04/"Conditional statements"/Conditional statement modifiers work as in Perl 5>

# test the ``given'' statement modifier
{
    my $a = $_ given 2 * 3;
    is($a, 6, "post given");
}

{
    my $a = $_ given 'a';
    is($a, 'a', "post given");
}

# L<S04/The C<for> statement/"given" "use a private instance of" $_>
{
    my $i;
    $_ = 10;
    $i += $_ given $_+3;
    is $_, 10, 'outer $_ did not get updated in lhs of given';
    is $i, 13, 'postfix given worked';
}
