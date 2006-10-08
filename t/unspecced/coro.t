use v6-alpha;

use Test;

plan 13;

# Standard function of fp
sub grab (Int $n, Code &f) { (1..$n).map:{ f() } }

# Anonymous coroutines
{
  my $coro  = coro { yield 42; yield 23 };
  my @elems = grab 5, $coro;
  is ~@elems, "42 23 42 23 42", "anonymous coroutines work";
}

# Named coroutines
{
  coro foo { yield 42; yield 23 };
  is ~grab(5, &foo), "42 23 42 23 42", "named coroutines work";
}

# return() resets the entrypoint
{
  my $coro  = coro { yield 42; yield 23; return 13; yield 19 };
  my @elems = grab 7, $coro;
  is ~@elems, "42 23 13 42 23 13 42", "return() resets the entrypoint";
}

# Coroutines stored in an array
{
  my @array = grab 5, {
    coro {
      my $num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
    };
  };

  is ~grab(5, @array[0]), "1 2 3 4 5",  "coroutines stored in arrays work (1)";
  is ~grab(5, @array[1]), "1 2 3 4 5",  "coroutines stored in arrays work (2)";
  is ~grab(5, @array[0]), "6 7 8 9 10", "coroutines stored in arrays work (3)";
  is ~grab(5, @array[2]), "1 2 3 4 5",  "coroutines stored in arrays work (4)";
  is ~grab(5, @array[1]), "6 7 8 9 10", "coroutines stored in arrays work (5)";
}

# Test that there's still only one instance of each state() variable
{
  my @array = grab 5, {
    coro {
      state $num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
      yield ++$num;
    };
  };

  is ~grab(5, @array[0]),      "1 2 3 4 5", "state() in coroutines work (1)";
  is ~grab(5, @array[1]),     "6 7 8 9 10", "state() in coroutines work (2)";
  is ~grab(5, @array[0]), "11 12 13 14 15", "state() in coroutines work (3)";
}

# Test that there's still only one instance of each state() variable
try {
  my @array = grab 5, {
    coro {
        (sub {
          state $num;
          while 1 {
            yield ++$num;
          }
        })();
    };
  };

  is ~grab(5, @array[0]),      "1 2 3 4 5", "yield from inside closure";
};

# I've marked this failure as unspecced, should a yield be able to
# jump up many scopes like that?
ok $!, "yield() should work from inside a closure (unspecced!)";

# Test that yield() works with loop blocks
{
    my $coro = coro { loop { yield 1 } };
    is ~grab(2, $coro), '1 1', 'yield() works inside loop{} blocks', :todo<bug>;
}

