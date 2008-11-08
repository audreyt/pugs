use v6;

use Test;

plan 15;

# Implicit $_
for 1, 2 {
    my $inside = '';
    for 1 .. 3 { $inside ~= $_; }
    is($inside, "123", "lexical scalar properly initialized, round $_");
}

for 1, 2 {
    my @inside;
    for 1 .. 3 { push @inside, $_; }
    is(@inside.join(""), "123", "lexical array properly initialized, round $_");
}

# Explicit $_
for 1, 2 {
    my $inside = '';
    for 1 .. 3 -> $_ { $inside ~= $_; }
    is($inside, "123", "lexical scalar properly initialized, round $_, explicit \$_");
}

for 1, 2 {
    my @inside;
    for 1 .. 3 -> $_ { push @inside, $_; }
    is(@inside.join(""), "123", "lexical array properly initialized, round $_, explicit \$_");
}

# Explicit $_
for 1, 2 -> $_ {
    my $inside = '';
    for 1 .. 3 -> $_ { $inside ~= $_; }
    is($inside, "123", "lexical scalar properly initialized, round $_, two explicit \$_s");
}

for 1, 2 -> $_ {
    my @inside;
    for 1 .. 3 -> $_ { push @inside, $_; }
    is(@inside.join(""), "123", "lexical array properly initialized, round $_, two explicit \$_s");
}

sub respect(*@a) {
    my @b = ();
    push @b for @a;
    return @b.elems;
}

is respect(1,2,3), 3, 'a for loop inside a sub loops over each of the elements';
is respect([1,2,3]), 3, '...even if they are sent as an array ref'; # is this right?
is respect( my @a = 1, 2, 3 ), 3, '...and when the array is declared in the argument list';
