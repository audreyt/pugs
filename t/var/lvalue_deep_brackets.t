use v6-alpha;

use Test;

plan 7;


# works
{
  my $foo = 0;
  $foo++;
  is $foo, 1, 'lvalue $var works';
}

# works
{
  my $foo = [0];
  $foo[0]++;
  is $foo[0], 1, 'lvalue $var[] works';
}

# broken
{
  my $foo = [[0]];
  $foo[0][0]++;
  is $foo[0][0], 1, 'lvalue $var[][] works';
}

# broken
{
  my @foo = [0];
  @foo[0][0]++;
  is @foo[0][0], 1, 'lvalue @var[][] works';
}

# broken
{
  is ++[[0]][0][0], 1, 'lvalue [[]][][] works';
}

# broken
{
  my $foo = {a => [0]};
  $foo<a>[0]++;
  is $foo<a>[0], 1, 'lvalue $var<>[] works';
}

# broken
{
  my %foo = (a => [0]);
  %foo<a>[0]++;
  is %foo<a>[0], 1, 'lvalue %var<>[] works';
}
