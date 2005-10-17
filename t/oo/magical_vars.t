#!/usr/bin/pugs

use v6;
use Test;

plan 16;

class Foo {
  method get_self_normal()    { $?SELF }
  method get_class_normal()   { $?CLASS }
  method get_package_normal() { $?PACKAGE }

  method get_class_pvar()   { ::?CLASS }
  method get_package_pvar() { ::?PACKAGE }

  method dummy()     { 42 }
}

role Bar {
  method get_self_normal()    { $?SELF }
  method get_class_normal()   { $?CLASS }
  method get_role_normal()    { $?ROLE }
  method get_package_normal() { $?PACKAGE }

  method get_class_pvar()   { ::?CLASS }
  method get_role_pvar()    { ::?ROLE }
  method get_package_pvar() { ::?PACKAGE }

  method dummy()     { 42 }
}

class SimpleClass does Bar {}

{
  my $foo_obj = Foo.new;
  my $class   = $foo_obj.get_class_normal;
  my $package = $foo_obj.get_package_normal;
  is( $package, 'Foo', '$?PACKAGE should be the package name' );

  ok( $class ~~ 'Foo', 'the thing returned by $?CLASS in our class smartmatches against our class' );
  my $forty_two;
  lives_ok { my $obj = $class.new; $forty_two = $obj.dummy },
    'the class returned by $?CLASS in our class was really our class (1)';
  is $forty_two, 42, 'the class returned by $?CLASS in our class way really our class (2)';
}

{
  my $foo1 = Foo.new;
  my $foo2 = $foo1.get_self_normal;

  ok $foo1 =:= $foo2, '$?SELF in classes works';
}

{
  my $bar   = SimpleClass.new;
  my $class = $bar.get_class_normal;
  my $package = $bar.get_package_normal;

  is( $package, SimpleClass, '$?PACKAGE should be the package name', :todo<bug> );

  is $class ~~ ::SimpleClass, 'the thing returned by $?CLASS in our role smartmatches against our class', :todo<bug>;
  my $forty_two;
  lives_ok { my $obj = $class.new; $forty_two = $obj.dummy },
    'the class returned by $?CLASS in our role way really our class (1)';
  is $forty_two, 42, 'the class returned by $?CLASS in our role way really our class (2)';
}

{
  my $bar1 = SimpleClass.new;
  my $bar2 = $bar1.get_self_normal;

  ok $bar1 =:= $bar2, '$?SELF in roles works';
}

{
  my $bar  = SimpleClass.new;
  my $role = $bar.get_role_normal;

  ok $role ~~ 'Bar', 'the returned by $?ROLE smartmatches against our role';
}

# Now the same with type vars
{
  cmp_ok Foo.new.get_class_pvar, &infix:<=:=>, ::Foo,
    "::?CLASS in classes works", :todo<bug>;
  cmp_ok SimpleClass.new.get_class_pvar, &infix:<=:=>, ::SimpleClass,
    "::?CLASS in roles works", :todo<bug>;
  cmp_ok SimpleClass.new.get_role_pvar, &infix:<=:=>, ::Bar,
    "::?ROLE in roles works", :todo<bug>;
}

# Per http://www.nntp.perl.org/group/perl.perl6.language/23541:
#     On Sat, Oct 15, 2005 at 07:39:36PM +0300, wolverian wrote:
#     : On Sat, Oct 15, 2005 at 08:25:15AM -0700, Larry Wall wrote:
#     : > [snip]
#     : >
#     : > Of course, there's never been any controversy here about what to call
#     : > "self", oh no... :-)
#     : 
#     : IMHO just call it "self" (by default) and be done with it. :) 
#
#     Let it be so.
#
#     Larry
{
  class Grtz {
    method get_self1 { self }
    method get_self2 { $?SELF }
    method foo       { 42 }
    method run_foo   { self.foo }
  }
  my $grtz = Grtz.new;

  cmp_ok $grtz.get_self1, &infix:<eqv>, $grtz.get_self2,
    'self is an alias for $?SELF (1)';
  is $grtz.run_foo, 42,
    'self is an alias for $?SELF (2)';
}
