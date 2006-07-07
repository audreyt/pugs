use v6-alpha;

use Test;

plan 11;

# L<S04/"The Relationship of Blocks and Declarations" /There is also a let function/>
# L<S04/"Definition of Success">
# let() should not restore the variable if the block exited successfully
# (returned a true value).
{
  my $a = 42;
  {
    let $a = 23;
    is $a, 23, "let() changed the variable (1)";
    1;
  }
  is $a, 23, "let() should not restore the variable, as our block exited succesfully (1)", :todo<feature>;
}

# let() should restore the variable if the block failed (returned a false
# value).
{
  my $a = 42;
  {
    let $a = 23;
    is $a, 23, "let() changed the variable (1)";
    0;
  }
  is $a, 42, "let() should restore the variable, as our block failed";
}

# Test that let() restores the variable at scope exit, not at subroutine
# entry.  (This might be a possibly bug.)
{
  my $a     = 42;
  my $get_a = { $a };
  {
    let $a = 23;
    is $a,       23, "let() changed the variable (2-1)";
    is $get_a(), 23, "let() changed the variable (2-2)", :todo<feature>;
    1;
  }
  is $a, 23, "let() should not restore the variable, as our block exited succesfully (2)", :todo<feature>;
}

# Test that let() restores variable even when not exited regularly (using a
# (possibly implicit) call to return()), but when left because of an exception.
{
  my $a = 42;
  try {
    let $a = 23;
    is $a, 23, "let() changed the variable in a try block";
    die 57;
  };
  is $a, 42, "let() restored the variable, the block was exited using an exception";
}

eval('
{
  my @array = (0, 1, 2);
  {
    let @array[1] = 42;
    is @array[1], 42, "let() changed our array element";
    0;
  }
  is @array[1], 1, "let() restored our array element";
}
"1 - delete this line when the parsefail eval() is removed";
') or skip(2, "parsefail: let \@array[1]");
