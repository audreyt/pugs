class Main {
    say '1..2';

    my sub ab_2_ ($a,$b) {
        say 'ok 2';
    };

    my sub ab_1_ ($a) {
        say 'not ok 2';
    };

    my sub ab_3_ ($a,$b,$c) {
        say 'ok 3';
    };

    my &multi := Multi.new;
    &multi.long_names = [
        &ab_2_,
        &ab_1_,
        &ab_3_,
    ];
    say '# long_names: ', &multi.long_names;

    my $capture = \( 1, 2 );

    say 'ok 1 - survived so far';

    say '# Signature: ', &ab_2_.signature;
    say '# Capture:   ', $capture;
    
    multi( $capture );
    
    # TODO
    # multi( 1, 2, 3 );
    
}
