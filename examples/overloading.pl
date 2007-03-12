# plays with some fun operator overloading.
#
# Please remember to update t/examples/examples.t and rename
# examples/output/overloading if you rename/move this file.

use v6-alpha;

multi postfix:<!> ($x) { [*] 1..$x };
multi postfix:<!> (@x) { [*] @x };

multi infix:<z> (@x, @y) { each(@x;@y) };
multi infix:<z> (Str $x, Str $y) { $x ~ $y };

my @x = 1..5;
my @y = 6..10;

(@x z @y).perl.say;
my $test = "hello" z "goodbye";
$test.perl.say;

$test = 10!; $test.perl.say;

my @test = (1..5);
$test = @test!;
$test.perl.say;

multi sub postfix:<<%%>> ($_) { $_ / 100 }; #since overloading % breaks it in infix
multi sub infix:<<of>> ($x,$y) {$x * $y};
say 50%% of 100;

sub base (Int $M, Int $N) {
    return $M if ($M < $N);
    my $t = $M % $N;
    return base(int($M/$N),$N) ~ $t;
}

multi sub infix:<<base>> ($x,$y) {base($x,$y)};
say $_ base 2 for (1..5);

# Commented so this file can be used in example.t.
# multi sub infix:<<.?.>> ($low,$high) { int( rand($high - $low) + $low ) + 1; };
# say 1 .?. 5;
# say 10 .?. 20;
