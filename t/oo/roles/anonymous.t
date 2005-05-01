#!/usr/bin/pugs

use v6;
use Test;

plan 14;

# L<S12/"Roles">
{
  my $a = 3;
  is $a, 3, "basic sanity";
  eval_ok '$a does role { has $.cool = "yeah" }', "anonymous role mixin", :todo;
  is $a, 3, "still basic sanity";
  eval_is '$a.cool', "yeah", "anonymous role gave us an attribute", :todo;
}

# The same, but we story the anonymous role in a variable
{
  my $a = 3;
  is $a, 3, "basic sanity";
  my $role;
  eval_ok 'my $role = role { has $.cool = "yeah" }', "anonymous role definition", :todo;
  eval_ok '$a does $role', "anonymous role variable mixin", :todo;
  is $a, 3, "still basic sanity";
  eval_is '$a.cool', "yeah", "anonymous role variable gave us an attribute", :todo;
}

# Guarantee roles are really first-class-persons:
{
  eval_ok '
    sub role_generator(Str $val) {
      return role {
	has $.cool = $val;
      }
    }
  ', "role generating functions defined", :todo;

  my $a = 3;
  is $a, 3, "basic sanity";
  eval_ok '$a does role_generator("hi")', "role generating function mixin", :todo;
  is $a, 3, "still basic sanity";
  eval_is '$a.cool', "hi", "role generating function gave us an attribute", :todo;
}
