use v6-alpha;

use Test;

plan 10;

=begin description

Basic C<pairs> tests, see S29.

=end description

# L<S29/"Array"/=item pairs>

{
  my @array = <a b c>;
  my @pairs;
  ok((@pairs = @array.pairs), "basic pairs on arrays");
  is +@pairs, 3,            "pairs on arrays returned the correct number of elems";
  if +@pairs != 3 {
    skip 6, "skipped tests which depend on a test which failed";
  } else {
    is @pairs[0].key,     0,  "key of pair returned by array.pairs was correct (1)";
    is @pairs[1].key,     1,  "key of pair returned by array.pairs was correct (2)";
    is @pairs[2].key,     2,  "key of pair returned by array.pairs was correct (3)";
    is @pairs[0].value, "a",  "value of pair returned by array.pairs was correct (1)";
    is @pairs[1].value, "b",  "value of pair returned by array.pairs was correct (2)";
    is @pairs[2].value, "c",  "value of pair returned by array.pairs was correct (3)";
  }
}

#?pugs todo 'bug'
{
    my @array = (17, 23, 42);

    lives_ok { for @array.pairs -> $pair {
        $pair.value += 100;
    } }, 'aliases returned by @array.pairs should be rw (1)';

    is @array[1], 123, 'aliases returned by @array.pairs should be rw (2)';
}

