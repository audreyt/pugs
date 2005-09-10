#!/usr/bin/pugs

use v6;
use Test;

plan 12;

=pod

Testing parameter traits for subroutines

L<S06/"Parameter traits">

=cut

my $foo=1;
sub mods_param ($x) { $x++; }
dies_ok  { mods_param($foo) }, 'can\'t modify parameter, constant by default';

# is readonly
sub mods_param_constant ($x is readonly) { $x++; }
dies_ok  { mods_param_constant($foo) }, 'can\'t modify constant parameter, constant by default';

sub mods_param_rw ($x is rw) { $x++; }
dies_ok  { mods_param_rw(1) }, 'can\'t modify constant even if we claim it\'s rw';
sub mods_param_rw_does_nothing ($x is rw) { $x; }
lives_ok { mods_param_rw_does_nothing(1) }, 'is rw with non-lvalue should autovivify';

lives_ok  { mods_param_rw($foo) }, 'pass by reference doesn\'t die';
is($foo, 2, 'pass by reference works');

#icopy
$foo=1;
sub mods_param_copy ($x is copy) {$x++;}
lives_ok { mods_param_copy($foo) }, 'is copy';
is($foo, 1, 'pass by value works');

# is ref
$foo=1;
sub mods_param_ref ($x is ref) { $x++;  }
dies_ok { mods_param_ref(1); }, 'is ref with non-lvalue';
lives_ok { mods_param_ref($foo); }, 'is ref with non-lvalue', :todo;
is($foo, 2, 'is ref works', :todo);

# is context
# Doesn't even compile, which is lucky, because I don't understand it well
# enough to write an actual test...
eval_ok('sub my_format (*@data is context(Item)) { }; 1', "is context - compile check");

# To do - check that is context actually works
