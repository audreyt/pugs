use v6-alpha;

use Test;

plan 4;

# L<A12/"Class|object Invocant">

class Foo {
    method bar (Class|Foo $class: $arg) { return 100 + $arg }
}

{
    my $val;
    lives_ok {
        $val = Foo.bar(42);
    }, '... class|instance methods work for class';
    is($val, 142, '... basic class method access worked');
}

{
    my $foo = Foo.new();
    my $val;
    lives_ok {
        $val = $foo.bar(42);
    }, '... class|instance methods work for instance';
    is($val, 142, '... basic instance method access worked');
}
