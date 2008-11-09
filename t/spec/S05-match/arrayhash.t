use v6;
use Test;

=begin pod

Matching against an array or a hash.

=end pod

plan 8;

if !eval('("a" ~~ /a/)') {
    skip_rest "skipped tests - rules support appears to be missing";
} else {
    # Matching against an array should be true if any of the values match.
    my @a = ('a', 'b' );
    ok(@a ~~ / 'b' /);
    ok(@a ~~ / ^ 'b' /);
    ok(@a ~~ / ^ 'a' /);
    ok(@a ~~ / ^ 'a' $ /);

    # Matching against a hash should be true if any of the keys match.
    my %a = ('a' => 1, 'b' => 2);
    ok(%a ~~ / 'b' /);
    ok(%a ~~ / ^ 'b' /);
    ok(%a ~~ / ^ 'a' /);
    ok(%a ~~ / ^ 'a' $ /);
}
