use v6-alpha;

use Test;

plan 26;

=pod

Testing operator overloading subroutines

L<S06/"Operator overloading">

=cut

# This set of tests is very basic for now.

sub prefix:<X> ($thing) { return "ROUGHLY$thing"; };

is(X "fish", "ROUGHLYfish",
   'prefix operator overloading for new operator');

sub prefix:<±> ($thing) { return "AROUND$thing"; };
is ± "fish", "AROUNDfish", 'prefix operator overloading for new operator (unicode)';
sub prefix:<(+-)> ($thing) { return "ABOUT$thing"; };
is (+-) "fish", "ABOUTfish", 'prefix operator overloading for new operator (nasty)';

{
  my sub prefix:<->($thing) { return "CROSS$thing"; };
  is(-"fish", "CROSSfish",
     'prefix operator overloading for existing operator (but only lexically so we don\'t mess up runtime internals (needed at least for PIL2JS, probably for PIL-Run, too)');
}

sub infix:<×> ($a, $b) { $a * $b }
is(5 × 3, 15, "infix Unicode operator");

sub infix:<C> ($text, $owner) { return "$text copyright $owner"; };
is "romeo & juliet" C "Shakespeare", "romeo & juliet copyright Shakespeare",
    'infix operator overloading for new operator';

sub infix:<©> ($text, $owner) { return "$text Copyright $owner"; };
is "romeo & juliet" © "Shakespeare", "romeo & juliet Copyright Shakespeare",
    'infix operator overloading for new operator (unicode)';

sub infix:<(C)> ($text, $owner) { return "$text CopyRight $owner"; };
is "romeo & juliet" (C) "Shakespeare", "romeo & juliet CopyRight Shakespeare",
    'infix operator overloading for new operator (nasty)';

sub infix:«_<_»($one, $two) { return 42 }
is 3 _<_ 5, 42, "frenchquoted infix sub";

sub postfix:<W> ($wobble) { return "ANDANDAND$wobble"; };

is("boop" W, "ANDANDANDboop", 
   'postfix operator overloading for new operator');

sub postfix:<&&&&&> ($wobble) { return "ANDANDANDANDAND$wobble"; };
is("boop"&&&&&, "ANDANDANDANDANDboop",
   "postfix operator overloading for new operator (weird)");

my $var = 0;
eval_ok('macro circumfix:<!--...-->   ($text) { "" }; <!-- $var = 1; -->; $var == 0;', 'circumfix macro', :todo<feature>);

# demonstrate sum prefix

sub prefix:<Σ> ($x) { [+] *$x }
is(Σ [1..10], 55, "sum prefix operator");

# check that the correct overloaded method is called
multi postfix:<!> ($x) { [*] 1..$x }
multi postfix:<!> (Str $x) { return($x.uc ~ "!!!") }

is(10!, 3628800, "factorial postfix operator");
is("boobies"!, "BOOBIES!!!", "correct overloaded method called");

# Overloading by setting the appropriate code variable
{
  my &infix:<plus>;
  BEGIN {
    &infix:<plus> := { $^a + $^b };
  }

  is 3 plus 5, 8, 'overloading an operator using "my &infix:<...>" worked';
}

# Overloading by setting the appropriate code variable using symbolic
# dereferentiation
{
  my &infix:<times>;
  BEGIN {
    &::("infix:<times>") := { $^a * $^b };
  }

  is 3 times 5, 15, 'operator overloading using symbolic dereferentiation';
}

# Accessing an operator using its subroutine name
{
  is &infix:<+>(2, 3), 5, "accessing a builtin operator using its subroutine name";

  my &infix:<z> := { $^a + $^b };
  is &infix:<z>(2, 3), 5, "accessing a userdefined operator using its subroutine name";

  is ~(&infix:<»+«>([1,2,3],[4,5,6])), "5 7 9", "accessing a hyperoperator using its subroutine name";
}

# Overriding infix:<;>
{
    my proto infix:<;> ($a, $b) { $a + $b }
    is (3 ; 2), 5  # XXX correct?
}

# [NOTE]
# pmichaud ruled that prefix:<;> and postfix:<;> shouldn't be defined by
# the synopses:
#   http://colabti.de/irclogger/irclogger_log/perl6?date=2006-07-29,Sat&sel=189#l299
# so we won't test them here.

# Overriding prefix:<if>
# L<S04/"Statement parsing" /since C<< prefix:<if> >> would hide C<< statement_modifier:<if> >>/>
{
    my proto prefix:<if> ($a) { $a*2 }
    is (if 5), 10;
}

# [NOTE]
# pmichaud ruled that infix<if> is incorrect:
#   http://colabti.de/irclogger/irclogger_log/perl6?date=2006-07-29,Sat&sel=183#l292
# so we won't test it here either.

# great.  Now, what about those silent auto-conversion operators a la:
# multi sub prefix:<+> (Str $x) returns Num { ... }
# ?

# I mean, + is all well and good for number classes.  But what about
# defining other conversions that may happen?

# here is one that co-erces a MyClass into a Str and a Num.
# L<A12/"Overloading" /Coercions to other classes can also be defined:/>
{
    class MyClass {
      method prefix:<~> { "hi" }
      method prefix:<+> { 42   }
      method infix:<as>($self, OtherClass $to) {
        my $obj = $to.new;
        $obj.x = 23;
        return $obj;
      }
    }

    class OtherClass {
      has $.x is rw;
    }

  my $obj;
  lives_ok { $obj = MyClass.new }, "instantiation of a prefix:<...> and infix:<as> overloading class worked";
  my $try = lives_ok { ~$obj }, "our object was stringified correctly";
  if ($try) {
   is ~$obj, "hi", "our object was stringified correctly";
  } else {
    skip 1, "Stringification failed";
  };
  is eval('($obj as OtherClass).x'), 23, "our object was coerced correctly", :todo<feature>;
}
