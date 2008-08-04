use v6;

use Test;

plan 16;

# L<S04/The C<repeat> statement/"more Pascal-like repeat loop">

{
  my $x = 0; repeat { $x++ } while $x < 10;
  is($x, 10, 'repeat {} while');
}

{
  my $x = 1; repeat { $x++ } while 0;
  is($x, 2, 'ensure repeat {} while runs at least once');
}

#?rakudo skip 'redo'
{
  my $x = 0;
  repeat { $x++; redo if $x < 10 } while 0;
  is($x, 10, 'redo works in repeat');
}

# L<S04/The C<repeat> statement/"or equivalently">

{
  my $x = 0; repeat { $x++ } until $x >= 10;
  is($x, 10, 'repeat {} until');
}

{
  my $x = 1; repeat { $x++ } until 1;
  is($x, 2, 'ensure repeat {} until runs at least once');
}

#?rakudo todo 'redo'
{
  my $x = 0; try { repeat { $x++; redo if $x < 10 } until 1 };
  is($x, 10, 'redo works in repeat {} until');
}

# L<S04/The C<repeat> statement/"loop conditional" on
#   "repeat block" required>
{
    my $x = 0;
    repeat {
        $x++;
        $x += 2;
    } while $x < 10;

    is $x, 12, 'repeat with "} while"';
}

{
    my $x = 0;
    repeat {
        $x++;
        $x += 2;
    }
    while $x < 10;

    is $x, 12, 'repeat with "}\n while"';
}

# L<S04/The C<repeat> statement/put "loop conditional" "at the front">
{
  my $x = 0; repeat while $x < 10 { $x++ }
  is($x, 10, 'repeat {} while');
}

{
  my $x = 1; repeat while 0 { $x++ }
  is($x, 2, 'ensure repeat {} while runs at least once');
}

#?rakudo todo 'redo'
{
  my $x = 0; try { repeat while 0 { $x++; redo if $x < 10 } };
  is($x, 10, 'redo works in repeat');
}

{
  my $x = 0; repeat until $x >= 10 { $x++ }
  is($x, 10, 'repeat until {}');
}

# L<S04/The C<repeat> statement/"bind the result">
#?rakudo skip 'point block on loop'
{
  my $x = 0; repeat until $x >= 10 -> $another_x {
      pass('repeat until with binding starts undefined') unless $another_x.defined;
      $x++
  }
  is($x, 10, 'repeat until -> {}');
}

{
  my $x = 1; repeat until 1 { $x++ }
  is($x, 2, 'ensure repeat until {} runs at least once');
}

#?rakudo todo 'redo'
{
  my $x = 0; try { repeat until 1 { $x++; redo if $x < 10 } };
  is($x, 10, 'redo works in repeat until {}');
}
