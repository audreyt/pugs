#!/usr/bin/pugs

use v6;
use Test;

=kwid

Array .end tests

=cut

plan 13;

# basic array .end tests

{ # invocant style
    my @array = ();
    is(@array.end, -1, 'we have an empty array');

    @array = (1..43);
    is(@array.end, 42, 'index of last element is 42 after assignment');

    pop @array;
    is(@array.end, 41, 'index of last element is 41 after pop');

    shift @array;
    is(@array.end, 40, 'index of last element is 40 after shift');

    unshift @array, 'foo';
    is(@array.end, 41, 'index of last element is 41 after unshift');

    push @array, 'bar';
    is(@array.end, 42, 'index of last element is 42 after push');
}

{ # non-invocant style
    my @array = ();
    is(end(@array), -1, 'we have an empty array');

    @array = (1..43);
    is(end(@array), 42, 'index of last element is 42 after assignment');

    pop @array;
    is((end @array), 41, 'index of last element is 41 after pop');

    shift @array;
    is((end @array), 40, 'index of last element is 40 after shift');

    unshift @array, 'foo';
    is(end(@array), 41, 'index of last element is 41 after unshift');

    push @array, 'bar';
    is(end(@array), 42, 'index of last element is 42 after push');
}

# test some errors
{
    dies_ok { end() }, '... end() dies without an argument';
}
