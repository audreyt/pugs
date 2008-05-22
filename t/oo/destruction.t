use v6;

use Test;

plan 6;

# L<A12/"Object Deconstruction">

my $in_destructor = 0;
my @destructor_order;

class Foo
{
    submethod DESTROY { $in_destructor++ }
}

class Parent
{
    submethod DESTROY { push @destructor_order, 'Parent' }
}

class Child is Parent
{
    submethod DESTROY { push @destructor_order, 'Child' }
}

my $foo = Foo.new();
is( $foo.WHAT,      'Foo', 'basic instantiation of declared class' );
ok( ! $in_destructor,    'destructor should not fire while object is active' );

# -- erratic behaviour; fail+todo for now
flunk("destruction - 1", :todo<bug>);
flunk("destruction - 2", :todo<bug>);
flunk("destruction - 3", :todo<bug>);
flunk("destruction - 4", :todo<bug>);
exit;

my $child = Child.new();
undefine $child;

# no guaranteed timely destruction, so replace $a and try to force some GC here
for 1 .. 100
{
    $foo = Foo.new();
}

ok( $in_destructor, '... only when object goes away everywhere'               );
is(  @destructor_order[0], 'Child',  'Child DESTROY should fire first'        );
is(  @destructor_order[1], 'Parent', '... then parent'                        );
is( +@destructor_order, 2, '... only as many as available DESTROY submethods' );
