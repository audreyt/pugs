use v6;

use Test;

plan 3;

=begin pod

Roles with names containing double colons and doing of them.

=end pod

role A::B {
    method foo { "Foo" }
};

is(A::B.WHAT, 'Role', 'A::B is a Role');

class X does A::B {
}
class X::Y does A::B {
}

is(X.new.foo,    'Foo', 'Composing namespaced role to non-namespaced class');
is(X::Y.new.foo, 'Foo', 'Composing namespaced role to namespaced class');
