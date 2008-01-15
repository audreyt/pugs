use v6-alpha;
use Test;

plan 11;

=head1 DESCRIPTION

Basic C<exists> tests on hashes, see S29.

=cut

# L<S29/"Hash"/=item exists>
my %hash = (a => 1, b => 2, c => 3, d => 4);
ok %hash.exists("a"),   "exists on hashes (1)";
ok !%hash.exists("42"), "exists on hashes (2)";

# This next group added by Darren Duncan following discovery while debugging ext/Locale-KeyedText:
# Not an exists() test per se, but asserts that elements shouldn't be added to 
# (exist in) a hash just because there was an attempt to read nonexistent elements.
{
  sub foo( $any ) {}
  sub bar( $any is copy ) {}

  my $empty_hash = hash();
  is( $empty_hash.pairs.sort.join( ',' ), '', "empty hash stays same when read from (1)" );
  $empty_hash{'z'};
  is( $empty_hash.pairs.sort.join( ',' ), '', "empty hash stays same when read from (2)" );
  bar( $empty_hash{'y'} );
  is( $empty_hash.pairs.sort.join( ',' ), '', "empty hash stays same when read from (3)" );
  my $ref = \( $empty_hash{'z'} );
  is( $empty_hash.pairs.sort.join( ',' ), '', "taking a reference to a hash element does not auto-vivify the element");
  foo( $empty_hash{'x'} );
  is( $empty_hash.pairs.sort.join( ',' ), '', "empty hash stays same when read from (4)", :todo<bug> );

  my $popul_hash = hash(('a'=>'b'),('c'=>'d'));
  my sub popul_hash_contents () {
    $popul_hash.pairs.sort.map:{ $_.key ~ ":" ~ $_.value }.join( ',' );
  }

  is( popul_hash_contents, "a:b,c:d", "populated hash stays same when read from (1)" );
  $popul_hash{'z'};
  is( popul_hash_contents, "a:b,c:d", "populated hash stays same when read from (2)" );
  bar( $popul_hash{'y'} );
  is( popul_hash_contents, "a:b,c:d", "populated hash stays same when read from (3)" );
  foo( $popul_hash{'x'} );
  is( popul_hash_contents, "a:b,c:d", "populated hash stays same when read from (4)", :todo<bug> );
}
