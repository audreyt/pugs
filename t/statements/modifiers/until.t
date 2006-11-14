use v6-alpha;

use Test;

plan 3;

# L<S04/"Conditional statements"/Conditional statement modifiers work as in Perl 5>

# test the ``until'' statement modifier
{
    my ($a, $b);
    $a += $b += 1 until $b >= 10;
    is($a, 55, "post until");
}

{
    my @a = ('a', 'b', 'a');
    my $a = 'b';
    $a ~= ', ' ~ shift @a until !+@a;
    is($a, "b, a, b, a", "post until");
}

{
    my @a = 'a'..'e';
    my $a;
    $a ++ until shift(@a) eq 'c';
    is($a, 2, "post until");
}
