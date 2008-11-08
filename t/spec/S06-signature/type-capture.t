use v6;
use Test;

plan 7;

# Check it captures built-in types.
sub basic_capture(::T $x) { ~T }
is(basic_capture(42),  'Int', 'captured built-in type');
is(basic_capture(4.2), 'Num', 'captured built-in type');

# User defined ones too.
class Foo { }
is(basic_capture(Foo.new), 'Foo', 'captured user defined type');

# Check you can use captured type later in the signature.
sub two_the_same(::T $x, T $y) { 1 }
ok(two_the_same(42, 42), 'used captured type later in the sig');
my $ok = 1;
try {
    two_the_same(42, 4.2);
    $ok = 0;
}
ok($ok, 'used captured type later in the sig');

# Check you can use them to declare variables.
sub declare_cap_type(::T $x) {
    my T $y = 4.2;
    1
}
ok(declare_cap_type(3.3), 'can use captured type in declaration');
$ok = 1;
try {
    declare_cap_type(42);
    $ok = 0;
}
ok($ok, 'can use captured type in declaration');
