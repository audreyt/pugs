use v6-alpha;

use Test;

plan 8;

=pod

Basic traits tests, see L<S12/"Traits">.

=cut

# L<S12/"Traits">
# Basic definition
my $was_in_any_sub   = 0;
my $was_in_class_sub = 0;
eval_ok 'role cool {
  has $.is_cool = 42;

  multi sub trait_auxiliary:<is>(cool $trait, Any $container:) {
    $was_in_any_sub++;
    $container does cool;
  }

  multi sub trait_auxiliary:<is>(cool $trait, Class $container:) {
    $was_in_class_sub++;
    $container does cool;
  }
', "role definition worked", :todo<feature>;

eval_ok 'my $a is cool',      'mixing in our role into a scalar via "is" worked', :todo<feature>;
is      $was_in_any_sub,  1,  'our trait_auxiliary:is was called', :todo<feature>;
eval_is '$a.is_cool',    42,  'our var "inherited" an attribute', :todo<feature>;

my $b;
eval_ok 'class B is cool {}', 'mixing in our role into a class via "is" worked', :todo<feature>;
eval_ok '$b = B.new()',       'creating an instance worked', :todo<feature>;
eval_is '$b.is_cool',    42,  'our class "inherited" an attribute', :todo<feature>;

is(!eval('class Foo { }; %!P = 1; 1'),undef, 'calling a trait outside of a class should be a syntax error');



