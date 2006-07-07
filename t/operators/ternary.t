use v6-alpha;

use Test;

=pod

Ternary operator ?? !!

=cut

plan 13;

my $str1 = "aaa";
my $str2 = "aaa";
my $str3 = "bbb";

{
    my $foo = "";
    $str1 eq $str2 ?? ($foo = 1) !! ($foo = 2);
    is($foo, 1, "?? !!");

    $str1 eq $str3 ?? ($foo = 3) !! ($foo = 4);
    is($foo, 4, "?? !!");
}

is(($str2 eq $str1 ?? 8 * 8 !! 9 * 9), 64, "?? !! in parenthesis");
is(($str2 eq $str3 ?? 8 + 8 !! 9 / 9), 1, "?? !! in parenthesis");

is(1 ?? 2 ?? 3 !! 4 !! 5 ?? 6 !! 7, 3, "nested ?? !!");
is(1 ?? 0 ?? 3 !! 4 !! 5 ?? 6 !! 7, 4, "nested ?? !!");
is(0 ?? 2 ?? 3 !! 4 !! 5 ?? 6 !! 7, 6, "nested ?? !!");
is(0 ?? 2 ?? 3 !! 4 !! 0 ?? 6 !! 7, 7, "nested ?? !!");

{
    my @a = (1 ?? 2 !! 3, 4 ?? 5 !! 6);
    is(@a, [2, 5], "?? !! in array");

}

is((0 and 1 ?? 2 !! 3), 0, "operator priority");
is((4 or 5 ?? 6 !! 7), 4, "operator priority");

{
    my $foo = 8;

    $foo = 9 ?? 10 !! 11;
    is($foo, 10, "operator priority");

    $foo = 0 ?? 12 !! 13;
    is($foo, 13, "operator priority");
}
