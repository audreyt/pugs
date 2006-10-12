use v6-alpha;
use Test;

plan 13;

use Span; pass "(dummy instead of broken use_ok)";

my $span = Span.new( :start(1), :end(3) );

isa_ok( $span, 'Span', 'created a Span' );

# TODO
# is( ~$span, '[1,3]', 'stringify' );

{
    my $a = Span.new();
    # TODO
    # is( ~$a, '', 'empty Span stringify' );
}

my $span2 = Span.new( start => 2, end => 4 );
my $span3 = Span.new( start => 4, end => 6 );

# TODO
# is( $span <=> 10 , -1, 'compare' );


is( $span.intersects( 2 ), Bool::True, 'intersects object' );
is( $span.intersects( $span2 ), Bool::True, 'intersects span' );
is( $span.intersects( $span3 ), Bool::False, 'doesn\'t intersect span' );

is( $span.contains( 2 ), Bool::True, 'contains object' );
is( $span.contains( 9 ), Bool::False, 'doesn\'t contain object' );

{
    my @a = $span ∩ $span2;
    is( @a.elems, 1, 'intersection' );
    is( @a[0].stringify, '[2,3]', 'intersection 0' );
}

{
    my @a = $span ∪ $span2;
    is( @a.elems, 1, 'union' );
    is( @a[0].stringify, '[1,4]', 'union 0' );
}

{
    my @a = $span ∖ $span2;
    is( @a.elems, 1, 'difference span' );
    is( @a[0].stringify, '[1,2)', 'difference 0' );
}

=begin TODO

{
    my @a = $span ∖ 2 );
    is( @a.elems, 2, 'difference value' );
    is( @a[0].stringify, '[1,2)', 'difference 0' );
    is( @a[1].stringify, '(2,3]', 'difference 1' );
}

=cut
