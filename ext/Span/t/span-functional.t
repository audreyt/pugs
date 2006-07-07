use v6;
use Test;

plan 12;

use Span::Num; pass "(dummy instead of broken use_ok)";
use Span::Num;   # XXX should not need this

my $span = Span::Num.new( 
    start => 1, end => 3, start_is_open => Bool::False, end_is_open => Bool::False );

isa_ok( $span, 'Span::Num', 
    'created a Span::Num' );

is( $span.start, 1, "start" );
is( $span.end  , 3, "end" );

# XXX - doesn't work
# $span.start = 5;
# is( $span.start, 1, "start is read-only" );

is( $span.start_is_open,   Bool::False, "start_is_open" );
is( $span.end_is_open,     Bool::False, "end_is_open" );

is( $span.start_is_closed, Bool::True, "start_is_closed" );
is( $span.end_is_closed,   Bool::True, "end_is_closed" );

is( $span.size, 2, "real size" );
# is( $span.size( density => 1 ), 3, "integer size" );

my $span2 = Span::Num.new( 
    start => 2, end => 4, start_is_open => Bool::False, end_is_open => Bool::False );

my $span3 = Span::Num.new( 
    start => 4, end => 6, start_is_open => Bool::False, end_is_open => Bool::False );

is( $span.intersects( $span2 ), Bool::True, 'intersects' );

is( $span.intersects( $span3 ), Bool::False, 'doesn\'t intersect' );

{
    my @a = $span.complement;
    # XXX inconsistent stringification of -Inf
    is( @a[0].stringify ~ ' ' ~ @a[1].stringify, '(-Inf,1) (3,Inf)', 'complement' );
}

# XXX - These two tests attempt to stringify a List of Span,
#       but there is no such thing defined.

#is( $span.intersection( $span2 ).stringify, '[2,3]', 'intersection' );
#is( $span.union( $span2 ).stringify, '[1,4]', 'union' );

