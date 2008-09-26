use v6;

use Test;

plan 18;

=begin description

Basic role tests from L<S12/Roles>

=end description

# L<S12/Roles>
# Basic definition
role Foo {}
class Bar does Foo;

# Smartmatch and .HOW.does and .^does
my $bar = Bar.new();
ok ($bar ~~ Bar),               '... smartmatch our $bar to the Bar class';
#?rakudo skip '.HOW'
ok ($bar.HOW.does($bar, Foo)),  '.HOW.does said our $bar does Foo';
#?rakudo skip '.^does'
ok ($bar.^does(Foo)),           '.^does said our $bar does Foo';
ok ($bar ~~ Foo),               'smartmatch said our $bar does Foo';

# Mixing a Role into an Object using imperative C<does>
my $baz = 3;
ok defined($baz does Foo),      'mixing in our Foo role into $baz worked';
#?pugs skip 3 'feature'
#?rakudo 3 skip 'role testing'
ok $baz.HOW.does($baz, Foo),    '.HOW.does said our $baz now does Foo';
ok $baz.^does(Foo),             '.^does said our $baz now does Foo';
ok $baz ~~ Baz,                 'smartmatch said our $baz now does Foo';

# L<S12/Roles/but with a role keyword:>
# Roles may have methods
#?pugs skip "todo"
{
    role A { method say_hello(Str $to) { "Hello, $to" } }
    my Foo $a .= new();
    ok(defined($a does A), 'mixing A into $a worked');
    is $a.say_hello("Ingo"), "Hello, Ingo", 
        '$a "inherited" the .say_hello method of A';
}

# L<S12/Roles/Roles may have attributes:>
#?rakudo skip 'role parse failure'
{
    role B { has $.attr = 42 is rw }
    my Foo $b does B .= new();
    ok defined($b),        'mixing B into $b worked';
    is $b.attr, 42,        '$b "inherited" the $.attr attribute of B (1)';
    is ($b.attr = 23), 23, '$b "inherited" the $.attr attribute of B (2)';

    # L<S12/Roles/operator creates a copy and works on that.>
    # As usual, ok instead of todo_ok to avoid unexpected succeedings.
    my Foo $c .= new(),
    ok defined($c),             'creating a Foo worked';
    ok !($c ~~ B),              '$c does not B';
    ok (my $d = $c but B),      'mixing in a Role via but worked';
    ok !($c ~~ B),              '$c still does not B...';
    ok $d ~~ B,                 '...but $d does B';
}

# vim: ft=perl6
