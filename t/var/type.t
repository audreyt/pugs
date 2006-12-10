use v6-alpha;
use Test;

# L<S02/"Built-In Data Types"/"A variable's type is a constraint indicating what sorts">

plan 8;

ok(try{my Int $foo; 1}, 'compile my Int $foo');
ok(try{my Str $bar; 1}, 'compile my Str $bar');

ok(do{my Int $foo; $foo ~~ Int}, 'Int $foo isa Int');
ok(do{my Str $bar; $bar ~~ Str}, 'Str $bar isa Str');

my Int $foo;
my Str $bar;
is(try{$foo = 'xyz'}, undef, 'Int restricts to integers', :todo);
is(try{$foo = 42},    42,    'Int is an integer');
is(try{$bar = 42},    undef, 'Str restricts to strings', :todo);
is(try{$bar = 'xyz'}, 'xyz', 'Str is a strings');

