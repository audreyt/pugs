use v6-alpha;

use Test;

plan 12;

# L<S04/The gather statement/"A variant of do is gather">

# Standard gather
{
    my @a;
    my $i;
    
    @a = gather {
        $i = 1;
        for (1 .. 5) -> $j {
            take $j;
        }
    };

    ok(!$i, "not yet gathered", :todo<unspecced>);
    is(+@a, 5, "5 elements gathered");
    ok($i, "gather code executed");
    is(@a[0], 1, "first elem taken");
    is(@a[-1], 5, "last elem taken");
};

# Nested gathers, two levels
{
  my @outer = gather {
    for 1..3 -> $i {
      my @inner = gather {
         take "$i,$_" for 1..3;
      };

      take ~@inner;
    }
  };

  is ~@outer, "1,1 1,2 1,3 2,1 2,2 2,3 3,1 3,2 3,3", "nested gather works (two levels)";
}

# Nested gathers, three levels
{
  my @outer = gather {
    for 1..2 -> $i {
      my @inner = gather {
        for 1..2 -> $j {
          my @inner_inner = gather {
            take "$i,$j,$_" for 1..2;
          };
          take ~@inner_inner;
        }
      };
      take ~@inner;
    }
  };

  is ~@outer, "1,1,1 1,1,2 1,2,1 1,2,2 2,1,1 2,1,2 2,2,1 2,2,2", "nested gather works (three levels)";
}

# take on lists, multiple takes per loop
{
  my @outer = gather {
    my @l = (1, 2, 3);
    take 5;
    take @l;
    take 5;
  };

  is ~@outer, "5 1 2 3 5", "take on lists and multiple takes work";
}

# gather scopes dynamiclly, not lexically
{
    my $dynamic_take = sub { take 7 };
    my @outer = gather {
        $dynamic_take();
        take 1;
    };

    is ~@outer, "7 1", "gather scopes dynamically, not lexically";
}

# take on array-ref
{
  my @list  = gather { take [1,2,3]; take [4,5,6];};
  my @list2 = ([1,2,3],[4,5,6]);
  is @list.perl, @list2.perl , "gather array-refs";
}

# gather statement prefix
{
    my @out = gather for 1..5 {
        take $_;
    };

    is ~@out, "1 2 3 4 5", "gather as a statement_prefix";
}

# lazy gather
{
    my $count = 0;
    my @list = gather {
        for 1 .. 10 -> $a {
            take $a;
            $count++
        }
    };
    my $result = @list[2];
    is($count, 2, "gather is lazy", :todo<unspecced>);	
}
