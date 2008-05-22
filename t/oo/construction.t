use v6;

use Test;

plan 13;

# L<S12/"Construction and Initialization">

my $in_own = 0;
ok eval('
  class OwnConstructor {
    has $.x = 13;
    method own(Class $class) {
      $in_own++;
      return $class.bless(:x(42));
    }
  }
'), "class definition worked", :todo<feature>;
ok eval('OwnConstr.new ~~ OwnConstr'), "basic class instantiation", :todo<feature>;
is eval('OwnConstr.new.x'), 13,        "basic attribute access", :todo<feature>;
# As usual, is instead of todo_is to suppress unexpected succeedings
is      $in_own, 0,                   "own constructor was not called";
ok eval('OwnConstr.own ~~ OwnConstr'), "own construction instantiated its class", :todo<feature>;
is eval('OwnConstr.own.x'), 42,        "attribute was set from our constructor", :todo<feature>;
is      $in_own, 1,                   "own constructor was actually called", :todo<feature>;


# L<"http://www.mail-archive.com/perl6-language@perl.org/msg20241.html">
# provide constructor for single positional argument

class Foo {
  has $.a;
  
  method new (Class $self: Str $string) {
    $.a = $string;
    return $self.bless(string => $string);
  }
}


ok 'Foo.new("a string") ~~ Foo', '... our Foo instance was created';

is eval('Foo.new("a string").a'), 'a string', "our own 'new' was called", :todo<feature>;


# Using ".=" to create an object
{
  class Bar { has $.attr }
  my Bar $bar .= new(:attr(42));
  is $bar.attr, 42, "instantiating an object using .= worked (1)";
}
# Using ".=()" to create an object
{ 
  class Fooz { has $.x }
  my Fooz $f .=(:x(1));
  is $f.x, 1, "instantiating an object using .=() worked";
}

{
  class Baz { has @.x is rw }
  my Baz $foo .= new(:x(1,2,3));
  lives_ok -> { $foo.x[0] = 3 }, "Array initialized in auto-constructor is not unwritable...";
  is $foo.x[0], 3, "... and keeps its value properly."
}	
