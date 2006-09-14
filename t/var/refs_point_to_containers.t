use v6-alpha;
use Test;

# L<S03/"Changes to Perl 5 operators"/"scalar dereference">
# The link points a  mention of "$$". I couldn't find a better
# one that described about how references point to containers. 

# References point to containers, not cells or even values

plan 12;

{
  my $num = 3;
  my $ref = \$num;
  is $$ref, 3, "basic refs to scalars work";

  $num = 4;
  is $$ref, 4, "refs to scalars point to containers, not cells or even values (1)", :todo<bug>;

  $num := 5;
  is $$ref, 5, "refs to scalars point to containers, not cells or even values (2)", :todo<bug>;
}

{
  my @array = (1,2,3);
  my $ref   = \@array[1];
  is $$ref, 2, "basic refs to arrays work";

  @array[1] = 3;
  is $$ref, 3, "refs to arrays point to containers, not cells or even values (1)", :todo<bug>;

  try { @array[1] := 4 };
  is $$ref, 4, "refs to arrays point to containers, not cells or even values (2)", :todo<bug>;
}

# Automatically created refs (autoreffing)
{
  my @array = (1,2,3);
  my $test  = sub (Array $arrayref) {
    is $arrayref[1], 2, "automatically reffed arrays";

    @array[1] = 3;
    is $arrayref[1], 3, "automatically reffed arrays point to containers (1)";

    try { @array[1] := 4 };
    is $arrayref[1], 4, "automatically reffed arrays point to containers (2)", :todo<bug>;
  };

  $test(@array);
}

# Automatically dereffed arrays
{
  my $arrayref = [1,2,3];
  my $test  = sub (@array) {
    is @array[1], 2, "automatically dereffed arrays", :todo<bug>;

    $arrayref[1] = 3;
    is @array[1], 3, "automatically dereffed arrays point to containers (1)", :todo<bug>;

    try { $arrayref[1] := 4 };
    is @array[1], 4, "automatically dereffed arrays point to containers (2)", :todo<bug>;
  };

  $test($arrayref);
}
