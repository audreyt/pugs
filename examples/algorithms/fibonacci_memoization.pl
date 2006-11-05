use v6;

my $n = @*ARGS[0] // 42;
say fib($n);

sub fib (Int $n) {
    return 0 if $n < 0;
    return 1 if $n < 3;
    state @seen[$n] //= fib($n-1) + fib($n-2);
}
