use v6-alpha;

use Test;

plan 29;

# basic my() lexicals

my $a = 1;
ok($a, '$a is available in this scope');

if (1) { # create a new lexical scope
    ok($a, '$a is available in this scope');
    my $b = 1;
    ok($b, '$b is available in this scope');
}
ok(!(eval '$b'), '$b is not available in this scope');

# changing a lexical within a block retains the changed value

my $c = 1;
if (1) { # create a new lexical scope
    is($c, 1, '$c is still the same outer value');
    $c = 2;
}
is($c, 2, '$c is available, and the outer value has been changed');

# This next test is inconsistent with the spirit of S04 (5 May 2006).
# L<S04/The Relationship of Blocks and Declarations/prior to the first declaration>
# "If you've referred to $x prior to the first declaration, and the
#  compiler tentatively bound it to $OUTER::x, then it's an error to
#  declare it, and the compiler is allowed to complain at that point."
# A fully conformant compiler will fail this test.  At best,
#   is($d, 1, '$d is still the outer $d');
# passes "tentatively", and the subsequent my is an uncomplained error.

# shadowing a lexical with a new lexical of the same name
# and that lexical does not leak out into the outer scope

my $d = 1;
{ # create a new lexical scope
    is($d, 1, '$d is still the outer $d');
    { # create another new lexical scope
        my $d = 2;
        is($d, 2, '$d is now the lexical (inner) $d');    
    }
}
is(eval('$d'), 1, 'eval(\'$d\') has not changed');

is( eval('
my $d = 1;
{ 
    my $d = 3 
}
$d;
'), 1, '$d is available, and the outer value has not changed' );

# check closures with functions

my $func;
my $func2;
if (1) { # create a new lexical scope
    my $e = 0;
    $func = sub { $e++ }; # one to inc
    $func2 = sub { $e };  # one to access it
}

ok(!(eval '$e'), '$e is the not available in this scope');
is($func2(), 0, '$func2() just returns the $e lexical which is held by the closure');
$func();
is($func2(), 1, '$func() increments the $e lexical which is held by the closure');
$func();
is($func2(), 2, '... and one more time just to be sure');

# check my as simultaneous lvalue and rvalue

is(eval('my $e1 = my $e2 = 42'), 42, 'can parse squinting my value');
is(eval('my $e1 = my $e2 = 42; $e1'), 42, 'can capture squinting my value');
is(eval('my $e1 = my $e2 = 42; $e2'), 42, 'can set squinting my variable');

is(eval('my $x = 1, my $y = 2; $y'), 2, 'precedence of my wrt = and ,');

# check proper scoping of my in while condition

my $result;
my $x = 0;
is(eval('while my $x = 1 { $result = $x; last }; $result'), 1, 'my in while cond seen from body');
is(eval('while my $x = 1 { last }; $x'), 1, 'my in while cond seen after');

# check proper scoping of my in if condition

is(eval('if my $x = 1 { $x } else { 0 }'), 1, 'my in if cond seen from then');
is(eval('if not my $x = 1 { 0 } else { $x }'), 1, 'my in if cond seen from else');
is(eval('if my $x = 1 { 0 } else { 0 }; $x'), 1, 'my in if cond seen after');

# check proper scoping of my in loop initializer

is(eval('loop (my $x = 1, my $y = 2; $x > 0; $x--) { $result = $x; last }; $result'), 1, '1st my in loop cond seen from body');
is(eval('loop (my $x = 1, my $y = 2; $x > 0; $x--) { $result = $y; last }; $result'), 2, '2nd my in loop cond seen from body');
is(eval('loop (my $x = 1, my $y = 2; $x > 0; $x--) { last }; $x'), 1, '1st my in loop cond seen after');
is(eval('loop (my $x = 1, my $y = 2; $x > 0; $x--) { last }; $y'), 2, '2nd my in loop cond seen after');

# check that can declaring lexical twice is noop
{
    my $f;
    $f = 5;
    my $f;
    is($f, 5, "two lexicals declared in scope is noop");
}

my $x = 42;
{
    my $x = $x;
    is( $x, undef, 'my $x = $x; can not see the value of the outer $x');
}
