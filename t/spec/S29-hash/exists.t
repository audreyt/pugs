use v6-alpha;
use Test;

plan 19;

=begin description

Basic C<exists> tests on hashes, see S29.

=end description

# L<S29/"Hash"/=item exists>

sub gen_hash {
    my %h{'a'..'z'} = (1..26);
    return %h;
};

{
    my %h1 = gen_hash;
    my %h2 = gen_hash;

    my $b = %h1<b>;
    is (exists %h1, 'a'), 1, "Test existance for single key. (Indirect notation)";
    is (%h1.exists('a')), 1, "Test existance for single key. (method call)";
};

{
    my %h;
    %h<none> = 0;
    %h<one> = 1;
    %h<nothing> = undef;
    is %h.exists('none'),     1,  "Existance of single key with 0 as value: none";
    is %h.exists('one'),      1,  "Existance of single key: one";
    is %h.exists('nothing'),  1,  "Existance of single key with undef as value: nothing";
    is defined(%h<none>),     1,  "Defined 0 value for key: none";
    is defined(%h<one>),      1,  "Defined 1 value for key: one";
    is defined(%h<nothing>),  '', "NOT Defined value for key: nothing";
}

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
  #?pugs todo 'bug'
  is( $empty_hash.pairs.sort.join( ',' ), '', "empty hash stays same when read from (4)" );

  my $popul_hash = hash(('a'=>'b'),('c'=>'d'));
  my sub popul_hash_contents () {
    $popul_hash.pairs.sort.map: { $_.key ~ ":" ~ $_.value }.join( ',' );
  }

  is( popul_hash_contents, "a:b,c:d", "populated hash stays same when read from (1)" );
  $popul_hash{'z'};
  is( popul_hash_contents, "a:b,c:d", "populated hash stays same when read from (2)" );
  bar( $popul_hash{'y'} );
  is( popul_hash_contents, "a:b,c:d", "populated hash stays same when read from (3)" );
  foo( $popul_hash{'x'} );
  #?pugs todo 'bug'
  is( popul_hash_contents, "a:b,c:d", "populated hash stays same when read from (4)" );
}

