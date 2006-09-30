use v6-alpha;

use Test;

=kwid
L<S04/"Loop statements" /work as in Perl 5/>
last
last if <condition>;
<condition> and last;
last <label>;
last in nested loops
last <label> in nested loops

=cut

plan 8;

# test for loops with last

{
    eval_is(
        'sub mylast { last; }; my $tracker = 0; for 1 .. 5 { $tracker = $_; mylast(); } $tracker',
        1,
        "tracker is 1 because mylast exits loop",
        :todo(1)
    );
}

{
    my $tracker = 0;
    for 1 .. 5 {
        $tracker = $_;
        last;  
    }
    is($tracker, 1, '... our loop only got to 1 (last)');
}

{
    my $tracker = 0;
    for 1 .. 5 {
        $tracker = $_;
        last if $_ == 3;  
    }
    is($tracker, 3, '... our loop only got to 3 (last if <cond>)');
}

{
    my $tracker = 0;
    for 1 .. 5 {
        $tracker = $_;
        $_ == 3 && last;  
    }
    is($tracker, 3, '... our loop only got to 3 (<cond> && last)');
}

{
    my $tracker = 0;
    for 1 .. 5 {
        $tracker = $_;
        $_ == 3 and last;  
    }
    is($tracker, 3, '... our loop only got to 3 (<cond> and last)');
}

{
    eval_is(
        'my $var=0; DONE: for (1..2) { last DONE; $var++;} $var',
        0,
        "var is 0 because last before increment",
        :todo(1)
    );
}

{
    my $tracker = 0;
    for (1 .. 5) -> $out {
        for (10 .. 11) -> $in {
            $tracker = $in + $out;
            last;
        }
    }
    is($tracker, 15, 'our inner loop only runs once per (last inside nested loops)');
}

{
    eval_is(
        'my $var=0; OUT: for (1..2) { IN: for (1..2) { last OUT } $var++;} $var',
        0,
        "var is 0 because last before increment in nested loop",
        :todo(1)
    );
}
