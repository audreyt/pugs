#!/usr/bin/pugs

use v6;
use Test;

plan 11;

# This is first attempt at rationalizing the := form into a Siglist method call.
# The :() form constructs signatures similar to how \() constructs arguments.
# A subroutine's .signature is a Siglist object.

# Basic siglist binding --
#   $x    := 42;  # is sugar for
#   :($x) := 42;  # which in turn is sugar for
#   :($x).infix:<:=>(42);
{
    my $x;

    my $siglist = eval ':($x)';
    try { $siglist.infix:<:=>(42) };

    is($x, 42, "basic siglist binding works", :todo<feature>);
    dies_ok { $x++ }, "binding was really a binding, not an assignment", :todo<feature>;
}

{
    my ($x, $y, $z);
    my $siglist = eval ':($x,$y,$z)';
    try { $siglist.infix:<:=>(1,2,3) };
    is("$x $y $z", "1 2 3", "siglist bindings works", :todo<feature>);
}

# Same, but more complex 
{
    my ($x, @y, @rest);
    my $siglist = eval ':($x,@y,*@rest)';
    try { $siglist.infix:<:=>(42,[13,17],5,6,7) };
    is("$x!@y[]!@rest[]", "42!13 17!5 6 7", "complex siglist bindings works (1)", :todo<feature>);
}

{
    my ($x);
    my $siglist = eval ':($x?)';
    try { $siglist.infix:<:=>() };
    ok(try { !exists $x }, "complex siglist bindings works (2)", :todo<feature>);
}

# &sub.signature should return a Siglist object
{
    my sub foo ($a, $b) {}
    my $siglist = eval ':($a, $b)';

    ok $siglist,
        "a subroutine's siglist can be accessed via .signature (1-1)", :todo<feature>;
    cmp_ok $siglist, &infix:<eqv>, try { &foo.signature },
        "a subroutine's siglist can be accessed via .signature (1-2)";
}

# Same as above, but more complex
{
    my sub foo (Num $a, $b?, *@rest) {}
    my $siglist = eval ':(Num $a, $b?, *@rest)';

    cmp_ok $siglist, &infix:<eqv>, try { &foo.signature },
        "a subroutine's siglist can be accessed via .signature (2)";
}

{
    my sub foo ($a, $b) {}
    my $siglist = eval ':($a)';

    ok !($siglist eqv try { &foo.signature }),
        "a subroutine's siglist can be accessed via .signature (3)", :todo<feature>;
}

# User-customized binding
{
    my $x = 42;
    my $siglist = eval '(:($x)) but role {
        method infix:<:=> {
            # do nothing
        }
    }';

    try { $siglist.infix:<:=>(23) };
    is $x, 42,        "user-defined binding worked as expected (1)";
    lives_ok { $x++}, "user-defined binding worked as expected (2)";
}
