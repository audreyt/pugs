use v6-pugs;

use Test;

# Test primarily aimed at PIL2JS

plan 8;

# sanity tests
{
  my $res;

  for <a b c> { $res ~= $_ }
  is $res, "abc", "for works with an <...> array literal";
}

{
  my $res;

  for (<a b c>) { $res ~= $_ }
  is $res, "abc", "for works with an (<...>) array literal";
}

# for with only one item, a constant
{
  my $res;

  for ("a",) { $res ~= $_ }
  is $res, "a", "for works with an (a_single_constant,) array literal";
}

{
  my $res;

  for ("a") { $res ~= $_ }
  is $res, "a", "for works with (a_single_constant)";
}

{
  my $res;

  for "a" { $res ~= $_ }
  is $res, "a", "for works with \"a_single_constant\"";
}

# for with only one item, an arrayref
# See thread "for $arrayref {...}" on p6l started by Ingo Blechschmidt,
# L<"http://www.nntp.perl.org/group/perl.perl6.language/22970">
{
  my $arrayref = [1,2,3];

  my $count;
  for ($arrayref,) { $count++ }

  is $count, 1, 'for ($arrayref,) {...} executes the loop body only once';
}

{
  my $arrayref = [1,2,3];

  my $count;
  for ($arrayref) { $count++ }

  is $count, 1, 'for ($arrayref) {...} executes the loop body only once', :todo<feature>;
}

{
  my $arrayref = [1,2,3];

  my $count;
  for $arrayref { $count++ }

  is $count, 1, 'for $arrayref {...} executes the loop body only once', :todo<feature>;
}
