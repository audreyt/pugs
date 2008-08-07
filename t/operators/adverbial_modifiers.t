use v6;

use Test;

plan 54;
# L<A03/"Binary :">
is eval('infix:<..>(1, 10, by => 2)'), <1 3 5 7 9>, 'range operator, :by parameter, long name', :todo<feature>;
is eval('1..10 :by(2)'), <1 3 5 7 9>, 'range operator, :by adverb, space', :todo<feature>;
is eval('1..10:by(2)'), <1 3 5 7 9>, 'range operator, :by adverb, without space', :todo<feature>;

is eval('infix:<..>(1, *, by => 2)[0..4]'), <1 3 5 7 9>, 'infinite range operator, long name', :todo<feature>;
is eval('1..(*) :by(2)[0..4]'), <1 3 5 7 9>, 'infinite range operator, :by adverb, space', :todo<feature>;
is eval('1..(*):by(2)[0..4]'), <1 3 5 7 9>, 'infinite range operator, :by adverb, without space', :todo<feature>;

# XXX need to test prefix:<=> on $handle with :prompt adverb

sub prefix:<blub> (Str $foo, Int :$times = 1) {
  ("BLUB" x $times) ~ $foo;
}

is prefix:<blub>("bar"), 'BLUBbar', 'user-defined prefix operator, long name';
is prefix:<blub>("bar", times => 2), 'BLUBBLUBbar', 'user-defined prefix operator, long name, optional parameter';
is prefix:<blub>(:times(2), "bar"), 'BLUBBLUBbar', 'user-defined prefix operator, long name, :times adverb, leading';
is prefix:<blub>("bar", :times(2)), 'BLUBBLUBbar', 'user-defined prefix operator, long name, :times adverb, trailing';
is eval('blub "bar"'), 'BLUBbar', 'user-defined prefix operator, basic call', :todo<feature>;
is eval('blub "bar" :times(2)'), 'BLUBBLUBbar', 'user-defined prefix operator, :times adverb, space', :todo<feature>;
is eval('blub "bar":times(2)'), 'BLUBBLUBbar', 'user-defined prefix operator, :times adverb, no space', :todo<feature>;

{
  # These basic adverb tests are copied from a table in A12.
  my $bar = 123;
  my @many = (4,5);
  sub dostuff(){"stuff"}
  my($v,$e);
  $e = (foo => $bar);
  $v = :foo($bar);
  is ~$v, ~$e, ':foo($bar)';

  $e = (foo => [1,2,3,@many]);
  $v = :foo[1,2,3,@many];
  is ~$v, ~$e, ':foo[1,2,3,@many]';

  $e = (foo => «alice bob charles»);
  $v = :foo«alice bob charles»;
  is ~$v, ~$e, ':foo«alice bob charles»';

  $e = (foo => 'alice');
  $v = :foo«alice»;
  is ~$v, ~$e, ':foo«alice»';

  flunk("FIXME parsefail", :todo<bug>);
  #$e = (foo => { a => 1, b => 2 });
  $v = eval ':foo{ a => 1, b => 2 }';
  #is ~$v, ~$e, ':foo{ a => 1, b => 2 }', :todo;

  flunk("FIXME parsefail", :todo<bug>);
  #$e = (foo => { dostuff() });
  $v = eval ':foo{ dostuff() }';
  #is ~$v, ~$e, ':foo{ dostuff() }', :todo;

  $e = (foo => 0);
  $v = :foo(0);
  is ~$v, ~$e, ':foo(0)';

  $e = (foo => 1);
  $v = :foo;
  is ~$v, ~$e, ':foo';
}

{
  # Exercise various mixes of "f", parens "()",
  # and adverbs with "X' and without "x" an argument.

  my sub f(:$x,:$y){$x~$y}
  my $v;

  # f(XY) f(YX) f(xY) f(Xy)

  $v = f(:x("a"):y("b"));
  is $v, "ab", 'f(:x("a"):y("b"))';

  $v = f(:y("b"):x("a"));
  is $v, "ab", 'f(:y("b"):x("a"))';

  $v = f(:x:y("b"));
  is $v, "1b", 'f(:x:y("b"))';

  $v = f(:x("a"):y);
  is $v, "a1", 'f(:x("a"):y)';

  # fXY() fxY() fXy()

#  $v = f:x("a"):y("b")();
#  is $v, "ab", 'f:x("a"):y("b")()';

#  $v = f:x:y("b")();
#  is $v, "1b", 'f:x:y("b")()';

#  $v = f:x("a"):y ();
#  is $v, "a1", 'f:x("a"):y ()';

  # fX(Y) fY(X) fx(Y) fX(y)

#  $v = f:x("a")(:y("b"));
#  is $v, "ab", 'f:x("a")(:y("b"))';

#  $v = f:y("b")(:x("a"));
#  is $v, "ab", 'f:y("b")(:x("a"))';

#  $v = f:x (:y("b"));
#  is $v, "1b", 'f:x (:y("b"))';

#  $v = f:x("a")(:y);
#  is $v, "a1", 'f:x("a")(:y)';

  # fXY fxY fXy

  $v = f:x("a"):y("b");
  is $v, "ab", 'f:x("a"):y("b")';

  $v = f:x:y("b");
  is $v, "1b", 'f:x:y("b")';

  $v = f:x("a"):y;
  is $v, "a1", 'f:x("a"):y';

  # f(X)Y f(Y)X f(x)Y f(X)y f(x)y

  $v = f(:x("a")):y("b");
  is $v, "ab", 'f(:x("a")):y("b")';

  $v = f(:y("b")):x("a");
  is $v, "ab", 'f(:y("b")):x("a")';

  $v = f(:x):y("b");
  is $v, "1b", 'f(:x("a")):y("b")';

  $v = f(:x("a")):y;
  is $v, "a1", 'f(:x("a")):y';

  $v = f(:x):y;
  is $v, "11", 'f(:x):y';

  # f()XY f()YX f()xY f()Xy  f()xy

  $v = f():x("a"):y("b");
  is $v, "ab", 'f():x("a"):y("b")';

  $v = f():y("b"):x("a");
  is $v, "ab", 'f():y("b"):x("a")';

  $v = f():x:y("b");
  is $v, "1b", 'f():x:y("b")';

  $v = f():x("a"):y;
  is $v, "a1", 'f():x("a"):y';

  $v = f():x:y;
  is $v, "11", 'f():x:y';

  # fX()Y fY()X fx()y

#  $v = f:x("a")():y("b");
#  is $v, "ab", 'f:x("a")():y("b")';

#  $v = f:y("b")():x("a");
#  is $v, "ab", 'f:y("b")():x("a")';

#  $v = f:x ():y;
#  is $v, "11", 'f:x ():y';

  # f_X(Y) f_X_Y() f_X_Y_() f_XY_() f_XY() fXY ()

  # $v = f :x("a")(:y("b"));
  # is $v, "ab", 'f :x("a")(:y("b"))';
  # Since the demagicalizing of pairs, this test shouldn't and doesn't work any
  # longer.

#  $v = 'eval failed';
#  eval '$v = f :x("a") :y("b")()';
#  is $v, "ab", 'f :x("a") :y("b")()', :todo<bug>;

#  $v = 'eval failed';
#  eval '$v = f :x("a") :y("b") ()';
#  is $v, "ab", 'f :x("a") :y("b") ()', :todo<bug>;

#  $v = 'eval failed';
#  eval '$v = f :x("a"):y("b") ()';
#  is $v, "ab", 'f :x("a"):y("b") ()', :todo<bug>;

#  $v = 'eval failed';
#  eval '$v = f :x("a"):y("b")()';
#  is $v, "ab", 'f :x("a"):y("b")()', :todo<bug>;

#  $v = f:x("a"):y("b") ();
#  is $v, "ab", 'f:x("a"):y("b") ()';

  # 

  # more tests....

}

{
  # Exercise mixes of adverbs and positional arguments.

  my $v;
  my sub f($s,:$x) {$x~$s}
  my sub g($s1,$s2,:$x) {$s1~$x~$s2}
  my sub h(*@a) {@a.perl}
  my sub i(*%h) {%h.perl}
  my sub j($s1,$s2,*%h) {$s1~%h.perl~$s2}

  # f(X s) f(Xs) f(s X) f(sX) f(xs) f(sx)

  $v = f(:x("a"), "b");
  is $v, "ab", 'f(:x("a") "b")';

  $v = f(:x("a"),"b");
  is $v, "ab", 'f(:x("a")"b")';

  $v = f("b", :x("a"));
  is $v, "ab", 'f("b" :x("a"))';

  $v = f("b",:x("a"));
  is $v, "ab", 'f("b":x("a"))';

  $v = f(:x, "b");
  is $v, "1b", 'f(:x "b")';

  $v = f("b", :x);
  is $v, "1b", 'f("b" :x)';

  # fX(s) f(s)X

#  $v = f:x("a")("b");
#  is $v, "ab", 'f:x("a")("b")';

  $v = f("b"):x("a");
  is $v, "ab", 'f("b"):x("a")';

  # fX s  fXs  fx s

  $v = 'eval failed';
  eval '$v = f:x("a") "b"';
  is $v, "ab", 'f:x("a") "b"', :todo<bug>;

  $v = 'eval failed';
  eval '$v = f:x("a")"b"';
  is $v, "ab", 'f:x("a")"b"', :todo<bug>;

  $v = 'eval failed';
  eval '$v = f:x "b"';
  is $v, "1b", 'f:x "b"', :todo<bug>;

  # fs X  fsX  fs x  fsx

#  $v = f "b" :x("a");
#  is $v, "ab", 'f "b" :x("a")';

#  $v = f "b":x("a");
#  is $v, "ab", 'f "b":x("a")';

#  $v = f "b" :x;
#  is $v, "1b", 'f "b" :x';

#  $v = f "b":x;
#  is $v, "1b", 'f "b":x';

  { # adverbs as pairs

    my sub f1($s,:$x){$s.perl~$x}

    $v = f1(\:bar :x("b"));
    is $v, '("bar" => Bool::True)b', 'f1(\:bar :x("b"))';

    my sub f2(Pair $p){$p.perl}

    $v = f2((:bar));
    is $v, '("bar" => Bool::True)', 'f2((:bar))';

    my sub f3(Pair $p1, Pair $p2){$p1.perl~" - "~$p2.perl}

    $v = f3((:bar),(:hee(3)));
    is $v, '("bar" => Bool::True) - ("hee" => 3)', 'f3((:bar),(:hee(3)))';
  
  }

  # add more tests...

}

{
  # Exercise adverbs on operators.

  sub prefix:<zpre>($a,:$x){join(",",$a,$x)}

  is eval('(zpre 4 :x(5))'), '4,5', '(zpre 4 :x(5))', :todo<feature>;

  sub postfix:<zpost>($a,:$x){join(",",$a,$x)}

  is eval('(4 zpost :x(5))'), '4,5', '(4 zpost :x(5))', :todo<feature>;

  sub infix:<zin>($a,$b,:$x){join(",",$a,$b,$x)}

  is eval('(3 zin 4 :x(5))'), '3,4,5', '(3 zin 4 :x(5))', :todo<feature>;

}
