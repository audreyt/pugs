use v6-alpha;

use Test;

=pod

This tests the &?BLOCK magical from Synoposis 6

L<S06/"The C<&?BLOCK> object">

=cut

plan 1;

# L<S06/"The C<&?BLOCK> object" /tail-recursion on an anonymous block:$/>
my $anonfactorial = -> Int $n { $n < 2 ?? 1 !! $n * &?BLOCK($n-1) };

my $result = $anonfactorial(3);
is($result, 6, 'the $?BLOCK magical worked');
