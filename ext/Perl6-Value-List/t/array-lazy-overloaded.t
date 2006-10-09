use v6-alpha;
use Test;

plan 11;
 
use Perl6::Value::List;

my sub infix:<..> ( Int $a, Int $b ) {
    Perl6::Value::List.from_range( start => $a, end => $b, step => 1 )
}

multi pop ( Array @a ) { 
    return unless @a;
    return @a[0].pop if @a[0].isa( 'Perl6::Value::List' );
    return @a.pop;
}

{
  # end of stream
  my $a = 1 .. 2;
  is( $a.shift, 1, 'iter 0' );
  is( $a.shift, 2, 'iter 1' );
  is( $a.shift, undef, 'end' );
}

{
  # 'Iter' object
  my $span = 0 .. Inf;
  is( $span.shift, 0, 'iter 0' );
  is( $span.shift, 1, 'iter 1' );
  
  is( $span.pop, Inf, 'pop' );
  is( $span.pop, Inf, 'pop' );
  
  # reverse
  my $rev = $span.reverse;

  isa_ok( $rev, Perl6::Value::List, 'reversed' );

  is( $rev.shift, Inf, 'shift reverse' );
  is( $rev.pop,   2,   'pop reverse' );
}

{
    my @a = 1..Inf;
    is( @a.pop, Inf, 'pop infinite array', :todo<feature> );
}
