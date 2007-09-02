use v6-alpha;

use Test;

=kwid

Array initialization in subs exported from a module
=cut

plan 1;

{
    use lib 't/builtins/arrays/';
    use ArrayInit;

    my $first_call = array_init();
    is( array_init(),
        $first_call,
        "an array init'd during subsequent calls to an exported sub should "
        ~ "contain no elements, rather than those from the first call" );
}
