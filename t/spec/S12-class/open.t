use v6;
use Test;
plan 10;

# L<S12/Open vs Closed Classes>

class Something {
    has $.attribute;
    method in_Something { 'a' ~ $.attribute };
}

my $x = Something.new(attribute => 'b');

is $x.in_Something, 'ab', 'basic OO sanity';

# although we use curlies here to be better fudge-able, remeber
# that 'is also' class extensions are *not* lexically scoped
{
    class Something is also {
        method later_added {
            'later'
        }
        method uses-other-methods {
            'blubb|' ~ self.in_Something;

        }
    }

    my $y = Something.new(attribute => 'c');
    is $y.later_added, 'later', 'can call method that was later added';
    is $y.uses-other-methods, 'blubb|ac', 'can call new method that calls other methods';

    is $x.later_added, 'later', 'can call method on object that was instantiated earlier';
    is $x.uses-other-methods, 'blubb|ab', 'works with other method too';
}

# now try to extend "core" types

{
    class Str is also {
        method mydouble {
            self.uc ~ self.lc;
        }
    }

    #?rakudo eval '"is also" on class Str'
    is 'aBc'.mydouble, 'ABCabc', 'can extend Str';
}

{
    class Int is also {
        method triple { self * 3 }
    }
    is 3.triple, 9, 'can extend Int';
}

{
    class List is also {
        method first-and-last {
            self[0] ~ self[self - 1]
        }
    }

    is <a b c d e f>.first-and-last, 'af', 'can extend class List';
    my @a = 1, 3, 7, 0;
    is @a.first-and-last, '10', 'can call extended methods from child classes';
}

{
    class Array is also {
        method last-and-first {
            self[self - 1] ~ self[0]
        }
    }

    my @a = 1, 3, 7, 0;
    is @a.last-and-first, '01', 'can extend class Array';
}

# vim: ft=perl6
