use v6;
use Test;

plan 71;

=kwid

This file /exhaustivily/ tests the Test module. 

I try every variant of each Test function here
because we are using this module to test Pugs itself, 
so I want to be sure that the error is not coming from 
within this module.

=cut

## ok

ok(2 + 2 == 4, '2 and 2 make 4');
ok(2 + 2 == 4, desc => '2 and 2 make 4');
ok(2 + 2 == 4, :desc('2 and 2 make 4'));

ok(2 + 2 == 5, desc => '2 and 2 doesnt make 5', todo => <bug>);
ok(2 + 2 == 5, :desc('2 and 2 doesnt make 5'), :todo(1));

## is

is(2 + 2, 4, '2 and 2 make 4');
is(2 + 2, 4, desc => '2 and 2 make 4');
is(2 + 2, 4, :desc('2 and 2 make 4'));

is(2 + 2, 5, todo => 1, desc => '2 and 2 doesnt make 5');
is(2 + 2, 5, :todo<feature>, :desc('2 and 2 doesnt make 5'));

## isnt

isnt(2 + 2, 5, '2 and 2 does not make 5');
isnt(2 + 2, 5, desc => '2 and 2 does not make 5');
isnt(2 + 2, 5, :desc('2 and 2 does not make 5'));

isnt(2 + 2, 4, '2 and 2 does make 4', :todo(1));
isnt(2 + 2, 4, desc => '2 and 2 does make 4', todo => 1);
isnt(2 + 2, 4, :desc('2 and 2 does make 4'), todo => 1);

## is_deeply

is_deeply([ 1..4 ], [ 1..4 ],
          "is_deeply (simple)");

is_deeply({ a => "b", c => "d", nums => [<1 2 3 4 5 6>] },
          { nums => ['1'..'6'], <a b c d> },
          "is_deeply (more complex)");

my @a = "a" .. "z";
my @b = @a.reverse;
@b = @b.map(sub($a, $b) { $b, $a });
my %a = @a;
my %b = @b;
is_deeply(%a, %b, "is_deeply (test hash key ordering)");

## isa_ok

my @list = ( 1, 2, 3 );

isa_ok(@list, 'List');
isa_ok({ 'one' => 1 }, 'Hash');

isa_ok(@list, 'Hash', 'this is a description', todo => 1);
isa_ok(@list, 'Hash', desc => 'this is a description', :todo<bug>);
isa_ok(@list, 'Array', :desc('this is a description'));

class Foo {};
my $foo = Foo.new();
isa_ok($foo, 'Foo');
isa_ok(Foo.new(), 'Foo');

## like

like("Hello World", rx:perl5{\s}, '... testing like()');
like("Hello World", rx:perl5{\s}, desc => '... testing like()');
like("Hello World", rx:perl5{\s}, :desc('... testing like()'));

like("HelloWorld", rx:perl5{\s}, desc => '... testing like()', todo => 1);
like("HelloWorld", rx:perl5{\s}, :todo(1), :desc('... testing like()'));

## unlike

unlike("HelloWorld", rx:perl5{\s}, '... testing unlike()');
unlike("HelloWorld", rx:perl5{\s}, desc => '... testing unlike()');
unlike("HelloWorld", rx:perl5{\s}, :desc('... testing unlike()'));

unlike("Hello World", rx:perl5{\s}, todo => 1, desc => '... testing unlike()');
unlike("Hello World", rx:perl5{\s}, :desc('... testing unlike()'), :todo(1));

## cmp_ok

cmp_ok('test', sub ($a, $b) { ?($a gt $b) }, 'me', '... testing gt on two strings');
cmp_ok('test', sub ($a, $b) { ?($a gt $b) }, 'me', desc => '... testing gt on two strings');
cmp_ok('test', sub ($a, $b) { ?($a gt $b) }, 'me', :desc('... testing gt on two strings'));

cmp_ok('test', sub ($a, $b) { ?($a gt $b) }, 'you', :todo(1), desc => '... testing gt on two strings');
cmp_ok('test', sub ($a, $b) { ?($a gt $b) }, 'you', :desc('... testing gt on two strings'), todo => 1);

## eval_ok

eval_ok('my $a = 1; $a', "eval_ok");
$! = undef; # clear $!
eval_ok('my $a = 1; $a', desc => "eval_ok");
$! = undef; # clear $!
eval_ok('my $a = 1; $a', :desc("eval_ok"));
$! = undef; # clear $!

eval_ok('my my my $a = 1; $a', desc => "eval_ok", :todo(1));
$! = undef; # clear $!
eval_ok('my my my $a = 1; $a', :desc("eval_ok"), todo => 1);
$! = undef; # clear $!

## eval_is

eval_is('my $a = 1; $a', 1, "eval_is");
$! = undef; # clear $!
eval_is('my $a = 1; $a', 1, desc => "eval_is");
$! = undef; # clear $!
eval_is('my $a = 1; $a', 1, :desc("eval_is"));
$! = undef; # clear $!

eval_is('my $$$$$a = 1; $a', 1, "eval_is", :todo(1));
$! = undef; # clear $!
eval_is('my $$$$$$a = 1; $a', 1, desc => "eval_is", todo => 1);
$! = undef; # clear $!
eval_is('my $$$$$a = 1; $a', 1, :desc("eval_is"), :todo(1));
$! = undef; # clear $!

## use_ok

use lib <ext/Test>; # Hack if we're run from make smoke
use_ok('t::use_ok_test');

# Need to do a test loading a package that is not there,
# and see that the load fails. Gracefully. :)
#use_ok('Non::Existent::Package', :todo(1));

## dies_ok

dies_ok -> { die "Testing dies_ok" }, '... it dies_ok';
dies_ok -> { die "Testing dies_ok" }, desc => '... it dies_ok';
dies_ok -> { die "Testing dies_ok" }, :desc('... it dies_ok');

dies_ok -> { "Testing dies_ok" }, desc => '... it dies_ok', todo => 1;
dies_ok -> { "Testing dies_ok" }, :desc('... it dies_ok'), :todo(1);

## lives_ok

lives_ok -> { return "test" }, '... it lives_ok';
lives_ok -> { return "test" }, desc => '... it lives_ok';
lives_ok -> { return "test" }, :desc('... it lives_ok');

lives_ok -> { die "test" }, desc => '... it lives_ok', todo => 1;
lives_ok -> { die "test" }, :desc('... it lives_ok'), :todo(1);


## throws_ok

#throws_ok -> { die "Testing throws_ok" }, 'Testing throws_ok', '... it throws_ok with a Str';
#throws_ok -> { die "Testing throws_ok" }, rx:perl5:i/testing throws_ok/, '... it throws_ok with a Rule';

## diag

diag('some misc comments and documentation');

## pass

pass('This test passed');

## flunk

flunk('This test failed', todo => 1);
flunk('This test failed', :todo(1));

## skip

skip('skip this test for now');
skip(3, 'skip 3 more tests for now');
skip_rest('skipping the rest');

1;

