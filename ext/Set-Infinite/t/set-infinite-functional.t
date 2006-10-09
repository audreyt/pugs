use v6-alpha;
use Test;

plan 26;

use Set::Infinite::Functional; pass "(dummy instead of broken use_ok)";

my $span1 = Span::Num.new( 
    start => 1, end => 3, start_is_open => Bool::False, end_is_open => Bool::False );
my $set1 = Set::Infinite::Functional.new( spans => $span1 );

isa_ok( $set1, 'Set::Infinite::Functional', 
    'created a Set::Infinite::Functional' );

my $s = $set1.spans.[0];
is( $s.stringify, '[1,3]', 'spans' );

# XXX - this should be a syntax error
# $set1.spans = ();
# is( $set1.stringify, '[1,3]', 'spans() is read-only' );

my $span2 = Span::Num.new( 
    start => 2, end => 4, start_is_open => Bool::False, end_is_open => Bool::False );
my $set2 = Set::Infinite::Functional.new( spans => $span2 );

my $span3 = Span::Num.new( 
    start => 4, end => 6, start_is_open => Bool::False, end_is_open => Bool::False );
my $set3 = Set::Infinite::Functional.new( spans => $span3 );

is( Set::Infinite::Functional.empty_set.stringify, '', 'empty set' );
is( Set::Infinite::Functional.universal_set.stringify, '(-Inf,Inf)', 'universal set' );

is( Set::Infinite::Functional.empty_set.is_empty, Bool::True, 'is empty' );
is( $set1.is_empty, Bool::False, 'is not empty' );

is( $set1.start, 1, "start" );
is( $set1.end  , 3, "end" );

is( $set1.start_is_open,   Bool::False, "start_is_open" );
is( $set1.end_is_open,     Bool::False, "end_is_open" );

is( $set1.start_is_closed, Bool::True, "start_is_closed" );
is( $set1.end_is_closed,   Bool::True, "end_is_closed" );

is( $set1.size, 2, "real size" );
# XXX is( $set1.size( density => 1 ), 3, "integer size" );

is( $set1.intersects( $set2 ), Bool::True, 'intersects' );

is( $set1.intersects( $set3 ), Bool::False, "doesn't intersect" );

is( $set1.intersection( $set2 ).stringify, '[2,3]', 'intersection' );

is( $set1.union( $set2 ).stringify, '[1,4]', 'union' );
is( $set2.union( $set1 ).stringify, '[1,4]', 'union' );
is( $set1.union( $set3 ).stringify, '[1,3],[4,6]', 'union' );

is( $set1.complement.stringify, '(-Inf,1),(3,Inf)', 'complement' );
is( $set1.union( $set3 ).complement.stringify, '(-Inf,1),(3,4),(6,Inf)', 'complement of union' );
is( Set::Infinite::Functional.empty_set.complement.stringify, '(-Inf,Inf)', 'complement of empty set' );
is( Set::Infinite::Functional.universal_set.complement.stringify, '', 'complement of universal set' );
is( Set::Infinite::Functional.empty_set.complement.complement.stringify, '', 'complement of complement' );

is( $set1.difference( $set2 ).stringify, '[1,2)', 'difference' );

