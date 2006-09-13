use v6-alpha;

use Test;

plan 15;

# L<S03/"Changes to Perl 5 operators"/"-> becomes .">

class Foo {
    has $.num;
    
    method bar ($self: $num) returns Foo {
        $.num = $num; 
        return $self;
    }
    
    method baz ($self: $num) returns Foo {
        $.num += $num;
        return $self;
    }
}

my $foo = Foo.new(:num<10>);
isa_ok($foo, 'Foo');

# do some sanity checking to make sure it does 
# all that we expect it too first.

is($foo.num(), 10, '... got the right num value');

my $_foo1 = $foo.bar(20);
isa_ok($_foo1, 'Foo');
ok($_foo1 === $foo, '... $_foo1 and $foo are the same instances');

is($foo.num(), 20, '... got the right num value');

my $_foo2 = $foo.baz(20);
isa_ok($_foo2, 'Foo');
ok( ([===] ($foo, $_foo2, $_foo1)), '... $_foo1, $_foo2 and $foo are the same instances');

is($foo.num(), 40, '... got the right num value');

# now lets try it with chained methods ...

my $_foo3;
lives_ok {
    $_foo3 = $foo.bar(10).baz(5);
}, '... method chaining works';

isa_ok($_foo3, 'Foo');
ok( ([===] ($_foo3, $_foo2, $_foo1, $foo)),
    '... $_foo3, $_foo1, $_foo2 and $foo are the same instances');

is($foo.num(), 15, '... got the right num value');

# test attribute accessors, too
is($foo.baz(7).baz(6).num, 28, 'chained an auto-generated accessor');

# L<S03/"Changes to Perl 5 operators"/"-> becomes .">
# L<S12/"Open vs Closed Classes"/"though you have to be explicit">
{
class Pair is also {
    our      method car () { self.key; }
    our Pair method cdr () { self.value; }
}

# (A => (B => undef)) => (C => undef))
# ((A B) C)

my $cons = [=>] ( [=>] <A B>, undef ), <C>, undef;

## Hmm.  Works with the latest release of Pugs (6.2.12 (r13256))
## Leaving this in as something that once didn't work (6.2.12 CPAN)

my $p = $cons.car;
ok( $cons.key.key =:= $p.car, 'chaining through temp variable' );
ok( $cons.key.key =:= $cons.car.car, 'chaining through Any return');
}
