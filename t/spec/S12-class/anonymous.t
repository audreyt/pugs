use v6;

use Test;

plan 6;

# Create and instantiate empty class; check .WHAT works and stringifies to
# empty string.
my $c1 = class { };
my $t1 = $c1.new();
ok(defined($t1),     'instantiated the class');
ok($t1 ~~ $c1,       'isa check works');
is(~$c1.WHAT(), '',  '.WHAT stringifies to empty string');

# Anonymous classes with methods.
my $c2 = class { method foo { 42 }; method bar { 28 } };
my $t2 = $c2.new();
is($t2.foo, 42,      'can call methods on anonymous classes');
is($t2.bar, 28,      'can call methods on anonymous classes');

# Anonymous classes with attributes.
my $c3 = class { has $.x };
my $t3 = $c3.new(x => 42);
is($t3.x, 42,        'anonymous classes can have attributes');
