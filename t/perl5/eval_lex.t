use v6-alpha;
use Test;
plan 1;

my $self = "some text";

is ~eval(q/"self is $self"/,:lang<perl5>),"self is some text","lexical inside an eval";
