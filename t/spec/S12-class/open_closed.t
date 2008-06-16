use v6;

use Test;

plan 12;

# syn r14552

# L<S12/"Open vs Closed Classes"/"a pragma for selecting global semantics of the underlying object-oriented engine">

use oo :closed :final;

class Foo {
    method a {'called Foo.a'}
}

eval_dies_ok('class Foo is also {method b {"called Foo.b"}}}', 'adding to closed class dies');

class Bar is open {
    method c {'called Bar.c'}
}
lives_ok({class Bar is also {method d {'called Bar.d'}}}, 'adding to opened class lives (using "is open")');

{
    my $o = Bar.new;
    is($o.c, 'called Bar.c', 'old method is still present');
    is($o.d, 'called Bar.d', 'new method is also present');
}

{
    # S12 gives the example of 'use class :open' as well as 'use oo :closed'
    # this seems weird to me.
    use class :open;
    class Baz {method e {'called Baz.e'}}
    lives_ok({class Baz is also {method f {'called Baz.f'}}}, 'adding to open class lives (lexically scoped pragma)');

    my $o = Baz.new;
    is($o.e, 'called Baz.e', 'old method is still present');
    is($o.f, 'called Baz.f', 'new method is present as well');
}

# L<S12/"Open vs Closed Classes"/"or by lexically scoped pragma around the class definition">
# and just when you thought I ran out of generic identifiers
use class :open<Qux>;
class Qux {method g {'called Qux.g'}}
lives_ok({class Qux is also {method h {'called Qux.i'}}}, 'adding to open class lives (global pragma with class name)');
{
    my $o = Qux.new;
    is($o.g, 'called Qux.g', 'old is still present');
    is($o.h, 'called Qux.h', 'new method is present as well');
}

# L<S12/"Open vs Closed Classes"/"declaring individual classes closed or final">
# try a few things that come to mind to make sure it's not lurking
eval_dies_ok('class ClosedAlpha is closed {}', '"is closed" is not implemented');
eval_dies_ok('class ClosedBeta  is final  {}', '"is final"  is not implemented');
