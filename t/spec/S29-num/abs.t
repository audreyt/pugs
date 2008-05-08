use v6;
use Test;
plan 40;

# L<S29/Num/"=item abs">

=begin pod

Basic tests for the abs() builtin

=end pod

for(0, 0.0, 1, 50, 60.0, 99.99) {
    is(abs($_), $_, "got the right absolute value for $_");
#?rakudo skip 'parsefail'
    is(WHAT abs($_), WHAT $_, "got the right data type("~WHAT($_)~") of absolute value for $_");
}
for(-1, -50, -60.0, -99.99) {
    is(abs($_), -$_, "got the right absolute value for $_");
#?rakudo skip 'parsefail'
    is(WHAT abs($_), WHAT $_, "got the right data type("~WHAT($_)~") of absolute value for $_");
}

for (0, 0.0, 1, 50, 60.0, 99.99) {
#?rakudo skip 'parsefail'
    is(.abs, $_, 'got the right absolute value for $_='~$_);
#?rakudo skip 'parsefail'
    is(WHAT .abs, WHAT $_, 'got the right data type('~WHAT($_)~') of absolute value for $_='~$_);
}
for (-1, -50, -60.0, -99.99) {
#?rakudo skip 'parsefail'
    is(.abs, -$_, 'got the right absolute value for $_='~$_);
#?rakudo skip 'parsefail'
    is(WHAT .abs, WHAT $_, 'got the right data type('~WHAT($_)~') of absolute value for $_='~$_);
}
