use v6-alpha;

class Main {
    
    say '1..1';

    sub subr( $a, $b ) { $a + $b };

    my $x := 0;
    $x := subr( 1, 2 );
    if $x != 3 {
        print 'not '
    };
    say 'ok 1 - ', $x;


# TODO
#
#    sub subr2( $a, [ $b, $c ] ) { $a + $b + $c };
#
#    my $x := 0;
#    $x := subr2( 1, [ 2, 4 ] );
#    if $x != 7 {
#        print 'not '
#    };
#    say 'ok 2 - ', $x;

}
