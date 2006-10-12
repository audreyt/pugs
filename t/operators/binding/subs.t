use v6-alpha;

use Test;

# L<S03/"Binding">

# Tests for binding the return value of subroutines (both as RHS and LHS).

plan 8;

{
    my sub foo { 42 }

    my $var := foo();
    is $var, 42,
        "binding a var to the return value of a sub (a constant) works (1)";

    dies_ok { $var = 23 },
        "binding a var to the return value of a sub (a constant) works (2)";
}

=begin unspecced

{
    my sub foo { 42 }

    dies_ok { foo() := 23 },
        "using the constant return value of a sub as the LHS in a binding operation dies";
}

There're two ways one can argue:
* 42 is constant, and rebinding constants doesn't work, so foo() := 23 should
  die.
* 42 is constant, but the implicit return() packs the constant 42 into a
  readonly 42, and readonly may be rebound.
  To clear the terminology,
    42                  # 42 is a constant
    sub foo ($a) {...}  # $a is a readonly

=end unspecced

=cut

{
    my sub foo { my $var = 42; $var }

    my $var := foo();
    is $var, 42,
        "binding a var to the return value of a sub (a variable) works (1)";

    dies_ok { $var = 23 },
        "binding a var to the return value of a sub (a variable) works (2)", :todo<bug>;
}

{
    my sub foo is rw { my $var = 42; $var }

    my $var := foo();
    is $var, 42,
        "binding a var to the return value of an 'is rw' sub (a variable) works (1)";

    lives_ok { $var = 23 },
        "binding a var to the return value of an 'is rw' sub (a variable) works (2)";
    is $var, 23,
        "binding a var to the return value of an 'is rw' sub (a variable) works (3)";
}

{
    my sub foo is rw { my $var = 42; $var }

    lives_ok { foo() := 23 },
        "using the variable return value of an 'is rw' sub as the LHS in a binding operation works", :todo<bug>;
}

=begin discussion

Should the constant return value be autopromoted to a var? Or should it stay a
constant?

{
    my sub foo is rw { 42 }

    dies_ok/lives_ok { foo() := 23 },
        "using the constant return value of an 'is rw' sub as the LHS in a binding operation behaves correctly";
}
