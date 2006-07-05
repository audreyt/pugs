use v6-pugs;

use Test;

=head1 DESCRIPTION

This test tests the C<type> builtin.

Reference:
L<"http://groups.google.com/groups?selm=420DB295.3000902%40conway.org">

=cut

# This test is much certainly hopelessly outdated.
# C<type> as a subroutine/method is in no current Synopsis.
# The notion of types and classes is changed currently.

plan 7;

skip_rest "test outdated";

=begin end

# Basic subroutine/method form tests for C<type>.
{
  my $a = 3;
  eval_ok 'type $a =:= Int', "subroutine form of type", :todo<feature>;
  eval_ok '$a.type =:= Int', "method form of type", :todo<feature>;
}

# Now testing basic correct inheritance.
{
  my $a = 3;
  eval_ok '$a.type ~~ Num',    "an Int isa Num", :todo<feature>;
  eval_ok '$a.type ~~ Object', "an Int isa Object", :todo<feature>;
}

# And a quick test for Code:
{
  my $a = sub ($x) { 100 + $x };
  eval_ok '$a.type =:= Sub',    "a sub's type is Sub", :todo<feature>;
  eval_ok '$a.type ~~ Routine', "a sub isa Routine", :todo<feature>;
  eval_ok '$a.type ~~ Code',    "a sub isa Code", :todo<feature>;
}
