use v6-alpha;

use Test;

=kwid

loop statement tests

L<S04/"The general loop statement">

=cut

plan 26;

# basic loop

my $i = 0;
is($i, 0, 'verify our starting condition');
loop ($i = 0; $i < 10; $i++) {}
is($i, 10, 'verify our ending condition');

# loop with last()

my $i = 0;
is($i, 0, 'verify our starting condition');
loop ($i = 0; $i < 10; $i++) {
    if ($i == 5) { 
        last(); # should this really need the ()
    }
}
is($i, 5, 'verify our ending condition');

# infinite loop

my $i = 0;
is($i, 0, 'verify our starting condition');
loop (;;) { $i++; last(); }
is($i, 1, 'verify our ending condition');

# declare variable $j inside loop
my $count  = 0;
is($count, 0, 'verify our starting condition');
my $j; loop ($j = 0; $j < 10; $j++) { $count++; };
is($count, 10, 'verify our ending condition');

# Ensure condition is tested on the first iteration
{
    my $never_did_body = 1;
    loop (;0;)
    {
        $never_did_body = 0;
    }
    ok($never_did_body, "loop with an initially-false condition executes 0 times");
}

# Loop with next should still execute the continue expression
{
    my ($i,    $continued);
    loop ($i = 0;; $continued = 1)
    {
        last if $i;
        $i++;
        next;
    }
    ok($continued, "next performs a loop's continue expression");
}

my $loopvar = 0;

loop {
    is($loopvar, $loopvar, "bare loop iterates $loopvar");
    last if ++$loopvar == 3;
}
is($loopvar, 3, "bare loop exited after 3 iterations");
