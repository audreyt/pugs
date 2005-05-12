#!/usr/bin/pugs

use v6;
use Test;

=kwid 

Shift tests

=cut

plan 26;

{

    my @shift = (1, 2, 3, 4);

    is(+@shift, 4, 'we have 4 elements in our array');
    my $a = shift(@shift);
    is($a, 1, 'shift(@shift) works');

    is(+@shift, 3, 'we have 3 elements in our array');
    $a = shift @shift;
    is($a, 2, 'shift @shift works');

    is(+@shift, 2, 'we have 2 elements in our array');
    $a = @shift.shift();
    is($a, 3, '@shift.shift() works');

    is(+@shift, 1, 'we have 1 element in our array');
    $a = @shift.shift;
    is($a, 4, '@shift.shift() works');

    is(+@shift, 0, 'we have no elements in our array');
    ok(!defined(shift(@shift)), 'after the array is exhausted it give undef');

}

{
    my @shift = (1, 2, 3, 4);

    is(+@shift, 4, 'we have 4 elements in our array');
    is(shift(@shift), 1, 'inline shift(@shift) works');

    is(+@shift, 3, 'we have 3 elements in our array');
    is(shift @shift, 2, 'inline shift @shift works');

    is(+@shift, 2, 'we have 2 elements in our array');
    is(@shift.shift(), 3, 'inline @shift.shift() works');

    is(+@shift, 1, 'we have 1 elements in our array');
    is(@shift.shift, 4, 'inline @shift.shift works');

    is(+@shift, 0, 'we have no elements in our array');
    ok(!defined(shift(@shift)), 'again, the array is exhausted and we get undef');
}

# invocant syntax with inline arrays
{
    is([1, 2, 3].shift, 1, 'this will return 1');
    ok(!defined([].shift), 'this will return undef');    
}

# testing some edge cases
{
    my @shift;
    ok(!defined(shift(@shift)), 'shift on an empty array returns undef');
}

# testing some error cases
{
    my @shift = 1 .. 5;
    dies_ok({ shift()           }, 'shift() requires arguments');    
    dies_ok({ shift(@shift, 10) }, 'shift() should not allow extra arguments');            
    dies_ok({ @shift.shift(10)  }, 'shift() should not allow extra arguments');     
}

# Push with Inf arrays (waiting on answers to perl6-compiler email)
#{
#    my @shift = 1 .. Inf;
#    # best not to uncomment this it just go on forever
#    todo_throws_ok { 'shift(@shift)' }, '?? what should this error message be ??', 'cannot shift off of a Inf array';
#}

