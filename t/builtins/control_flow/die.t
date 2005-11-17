#!/usr/bin/pugs

use v6;
use Test;

=pod

Tests for the die() builtin

=cut

plan 14;

ok(!try { die "foo"; 1 });
my $error = $!;
is($error, 'foo', 'got $! correctly');

my $foo = "-foo-";
try { $foo = die "bar" };
$foo; # this is testing for a bug where an error is stored into $foo in
      # the above eval; unfortunately the if below doesn't detect this on it's
      # own, so this lone $foo will die if the bug is present
ok($foo eq "-foo-");

sub recurse {
  my $level=@_[0];
  $level>0 or die "Only this\n";
  recurse(--$level);
}
try { recurse(1) };
is($!, "Only this\n");

# die in if,map,grep etc.
is ({ try { map    { die } 1,2,3 }; 42 }()), 42, "die in map";
is ({ try { grep   { die } 1,2,3 }; 42 }()), 42, "die in grep";
is ({ try { sort   { die } 1,2,3 }; 42 }()), 42, "die in sort";
is ({ try { reduce { die } 1,2,3 }; 42 }()), 42, "die in reduce";
is ({ try { min    { die } 1,2,3 }; 42 }()), 42, "die in min";
is ({ try { max    { die } 1,2,3 }; 42 }()), 42, "die in max";

is ({ try { for 1,2,3 { die } };         42 }()), 42, "die in for";
is ({ try { if 1 { die } else { die } }; 42 }()), 42, "die in if";

my sub die_in_return () { return die };
is ({ try { die_in_return(); 23 }; 42 }()), 42, "die in return";

# If one of the above tests caused weird continuation bugs, the following line
# will be executed multiple times, resulting in a "too many tests run" error
# (which is what we want). (Test primarily aimed at PIL2JS)
is 42-19, 23, "basic sanity";
