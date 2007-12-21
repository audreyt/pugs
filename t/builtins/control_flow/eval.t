use v6-alpha;
use Test;
plan 8;

# L<S29/Context/"=item eval">

=pod

Tests for the eval() builtin

=cut


if $?PUGS_BACKEND ne "BACKEND_PUGS" {
  skip_rest "PIL2JS and PIL-Run do not support eval() yet.";
  exit;
}

# eval should evaluate the code in the lexical scope of eval's caller
sub make_eval_closure { my $a = 5; sub ($s) { eval $s } };
is(make_eval_closure()('$a'), 5);

is(eval('5'), 5);
my $foo = 1234;
is(eval('$foo'), $foo);

# traps die?
ok(!eval('die; 1'), "eval can trap die");

ok(!eval('my @a = (1); @a<0>'), "eval returns undef on syntax error");

ok(!eval('use Poison; 1'), "eval can trap a fatal use statement");

sub v { 123 }
ok(v() == 123, "a plain subroutine");
eval 'sub v { 456 }';
ok(v() == 456, "eval can overwrite a subroutine");

