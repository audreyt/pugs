use v6-alpha;

use Test;

plan 3;

=pod

Test for rules as references

=cut

unless "a" ~~ rx:P5/a/ {
  skip_rest "skipped tests - P5 regex support appears to be missing";
  exit;
}

my $rule = rx:perl5{\s+};
isa_ok($rule, 'Pugs::Internals::VRule');

ok("hello world" ~~ $rule, '... applying rule ref returns true');
ok(!("helloworld" ~~ $rule), '... applying rule ref returns false (correctly)');
