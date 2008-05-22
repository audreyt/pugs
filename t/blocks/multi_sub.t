use v6;
use Test;
plan 22;

# type based dispatching
#
#L<S06/"Longname parameters">
#L<S12/"Multisubs and Multimethods">

multi foo (Int $bar)   { "Int "  ~ $bar  }
multi foo (Str $bar)   { "Str "  ~ $bar  }
multi foo (Num $bar)   { "Num "  ~ $bar  }
multi foo (Rat $bar)   { "Rat "  ~ $bar  }
multi foo (Bool $bar)  { "Bool " ~ $bar  }
multi foo (Rule $bar)  { "Rule " ~ WHAT( $bar ) } # since Rule's don't stringify
multi foo (Sub $bar)   { "Sub " ~ $bar() }
multi foo (Array @bar) { "Array " ~ join(', ', @bar) }
multi foo (Hash %bar)  { "Hash " ~ join(', ', %bar.keys.sort) }
multi foo (IO $fh)     { "IO" }

is(foo('test'), 'Str test', 'dispatched to the Str sub');
is(foo(2), 'Int 2', 'dispatched to the Int sub');

my $num = '4';
is(foo(+$num), 'Num 4', 'dispatched to the Num sub');
is(foo(1.5), 'Rat 1.5', 'dispatched to the Rat sub');
is(foo(1 == 1), 'Bool 1', 'dispatched to the Bool sub');
is(foo(rx:P5/a/),'Rule Rule','dispatched to the Rule sub', :todo<bug>);
is(foo(sub { 'baz' }), 'Sub baz', 'dispatched to the Sub sub');

my @array = ('foo', 'bar', 'baz');
is(foo(@array), 'Array foo, bar, baz', 'dispatched to the Array sub');

my %hash = ('foo' => 1, 'bar' => 2, 'baz' => 3);
is(foo(%hash), 'Hash bar, baz, foo', 'dispatched to the Hash sub');

is(foo($*ERR), 'IO', 'dispatched to the IO sub');

ok(eval('multi sub foo( (Int, Str) $tuple: ) '
    ~ '{ "Tuple(2) " ~ $tuple.join(",") }'),
    "declare sub with tuple argument", :todo<feature>);

ok(eval('multi sub foo( (Int, Str, Str) $tuple: ) '
    ~ '{ "Tuple(3) " ~ $tuple.join(",") }'),
    "declare multi sub with tuple argument", :todo<feature>);

is(foo([3, "Four"]), "Tuple(2) 3,Four", "call tuple multi sub", :todo<feature>);
is(foo([3, "Four", "Five"]), "Tuple(3) 3,Four,Five", "call tuple multi sub", :todo<feature>);

# You're allowed to omit the "sub" when declaring a multi sub.
# L<S06/"Routine modifiers">

multi declared_wo_sub (Int $x) { 1 }
multi declared_wo_sub (Str $x) { 2 }
is declared_wo_sub(42),   1, "omitting 'sub' when declaring 'multi sub's works (1)";
is declared_wo_sub("42"), 2, "omitting 'sub' when declaring 'multi sub's works (2)";

# Test for slurpy MMDs

proto mmd {}  # L<S06/"Routine modifiers">
multi mmd () { 1 }
multi mmd (*$x, *@xs) { 2 }

is(mmd(), 1, 'Slurpy MMD to nullary');
is(mmd(1,2,3), 2, 'Slurpy MMD to listop via args');
is(mmd(1..3), 2, 'Slurpy MMD to listop via list');

# Test for proto definitions

# L<S03/"Reduction operators">

proto prefix:<[+]> (*@args) {
    my $accum = 0;
    $accum += $_ for @args;
    return $accum * 2; # * 2 is intentional here
}

is ([+] 1,2,3), 12, "[+] overloaded by proto definition";

# more similar tests

proto prefix:<moose> ($arg) { $arg + 1 }
is (moose 3), 4, "proto definition of prefix:<moose> works";

proto prefix:<elk> ($arg) {...}
multi prefix:<elk> ($arg) { $arg + 1 }
is (elk 3), 4, "multi definition of prefix:<elk> works";
