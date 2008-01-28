use v6-alpha;

use Test;

plan 20;

=begin description

Basic C<pairs> tests, see S29.

=end description

# L<S29/"Hash"/=item pairs>

{
  my %hash = (a => 1, b => 2, c => 3);
  my @pairs;
  ok((@pairs = %hash.pairs.sort), "sorted pairs on hashes");
  is +@pairs, 3,                "pairs on hashes returned the correct number of elems";
  if +@pairs != 3 {
    skip 6, "skipped tests which depend on a test which failed";
  } else {
    is @pairs[0].key,   "a",      "value of pair returned by hash.pairs was correct (1)";
    is @pairs[1].key,   "b",      "value of pair returned by hash.pairs was correct (2)";
    is @pairs[2].key,   "c",      "value of pair returned by hash.pairs was correct (3)";
    is @pairs[0].value,   1,      "key of pair returned by hash.pairs was correct (1)";
    is @pairs[1].value,   2,      "key of pair returned by hash.pairs was correct (2)";
    is @pairs[2].value,   3,      "key of pair returned by hash.pairs was correct (3)";
  }
}

# Following stated by Larry on p6l
{
  my $pair  = (a => 1);
  my @pairs;
  ok((@pairs = $pair.pairs), "pairs on a pair");
  is +@pairs, 1,           "pairs on a pair returned one elem";
  if +@pairs != 1 {
    skip 2, "skipped tests which depend on a test which failed";
  } else {
    is @pairs[0].key,   "a", "key of pair returned by pair.pairs";
    is @pairs[0].value,   1, "value of pair returned by pair.pairs";
  }
}

# This next group added by Darren Duncan following discovery while debugging ext/Locale-KeyedText:
{
  my $hash_of_2_pairs = {'a'=>'b','c'=>'d'};
  my $hash_of_1_pair = {'a'=>'b'};
  #?pugs 2 todo 'feature'
  is( $hash_of_2_pairs.pairs.sort.join( ',' ), "a\tb,c\td",
    "pairs() on 2-elem hash, 1-depth joined");
  is( $hash_of_1_pair.pairs.sort.join( ',' ), "a\tb",
    "pairs() on 1-elem hash, 1-depth joined");
  is( $hash_of_2_pairs.pairs.sort.map:{ .key~'='~.value }.join( ',' ), 'a=b,c=d', 
    "pairs() on 2-elem hash, 2-depth joined" );
  is( try { $hash_of_1_pair.pairs.sort.map:{ .key~'='~.value }.join( ',' ) }, 'a=b', 
    "pairs() on 1-elem hash, 2-depth joined" );
}

{
    my %hash = (:a(1), :b(2), :c(3));

    lives_ok { for %hash.pairs -> $pair {
        $pair.value += 100;
    } }, 'aliases returned by %hash.pairs should be rw (1)';

    is %hash<b>, 102, 'aliases returned by %hash.pairs should be rw (2)';
}

#?pugs todo 'bug'
{
    my $pair = (a => 42);

    lives_ok { for $pair.pairs -> $p {
        $p.value += 100;
    } }, 'aliases returned by $pair.value should be rw (1)';

    is $pair.value, 142, 'aliases returned by $pair.kv should be rw (2)';
}
