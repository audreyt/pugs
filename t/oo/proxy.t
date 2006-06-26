#!/usr/bin/pugs

use v6;
use Test;

# Tests for the Proxy class

# Return value of assignments of Proxy objects is decided now.
# See thread "Assigning Proxy objects" on p6l,
# L<"http://www.nntp.perl.org/group/perl.perl6.language/21838">.
# Quoting Larry:
#   The intention is that lvalue subs behave in all respects as if they
#   were variables.  So consider what
#   
#       say $nonproxy = 40;
#   
#   should do.

plan 18;

flunk 'XXX - Proxy not implemented', :todo<feature>;
skip_rest; exit;

my $foo        = 42;
my $was_inside = 0;

sub lvalue_test1() is rw {
  $was_inside++;
  return new Proxy:
    FETCH => { 100 + $foo },
    STORE => { $foo = $^new - 100 };
};

{
    is $foo, 42,       "basic sanity (1)";
    is $was_inside, 0, "basic sanity (2)";

    eval_is 'lvalue_test1()',       142, "getting var through Proxy (1)", :todo<feature>;
    # No todo_is here to avoid unexpected succeeds (? - elaborate?)
    is      $was_inside,              1, "lvalue_test1() was called (1)";

    eval_is 'lvalue_test1() = 123', 123, "setting var through Proxy",     :todo<feature>;
    is      $was_inside,              2, "lvalue_test1() was called (2)";
    is      $foo,                    23, "var was correctly set (1)",     :todo<feature>;

    eval_is 'lvalue_test1()',       123, "getting var through Proxy (2)", :todo<feature>;
    is      $was_inside,              3, "lvalue_test1() was called (3)";
}

$foo        = 4;
$was_inside = 0;

sub lvalue_test2() is rw {
  $was_inside++;
  return new Proxy:
    FETCH => { 10 + $foo },
    STORE => { $foo = $^new - 100 };
};

{
    is $foo, 4,        "basic sanity (3)";
    is $was_inside, 0, "basic sanity (4)";

    skip_rest 'XXX - lvalue vars not available - incoherent test results';
    exit;

    eval_is 'lvalue_test2()',        14, "getting var through Proxy (4)", :todo<feature>;
    # No todo_is here to avoid unexpected succeeds
    is      $was_inside,              1, "lvalue_test2() was called (4)";

    eval_is 'lvalue_test2() = 106', 166, "setting var through Proxy returns new value of the var", :todo<feature>;
    is      $was_inside,              2, "lvalue_test2() was called (5)";
    is      $foo,                     6, "var was correctly set (2)",     :todo<feature>;

    eval_is 'lvalue_test2()',        16, "getting var through Proxy (5)", :todo<feature>;
    is      $was_inside,              3, "lvalue_test2() was called (5)";
}
