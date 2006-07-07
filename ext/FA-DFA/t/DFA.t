use v6;
use Test;
use FA::DFA;

plan 7;

my FA::DFA $dfa .= new;
ok($dfa,"Object created");

my $startstate = $dfa.state;

# The next few tests cause pugs to fall into an infinite loop
# as of 8136.

my FA::DFA::Node $nextnode = $dfa.addarc("test");
ok($nextnode,"Node created");

$dfa.next("test");
is($dfa.state,$nextnode,"Nodes can be stepped through");


$dfa.reset;
is($dfa.state,$startstate,"Nodes can be reset");

my FA::DFA::Node $nextnode2 = $dfa.addarc("test2",$nextnode);
is($nextnode,$nextnode2,"Arcs to defined nodes will be created");


my FA::DFA::Node $node .= new;

$node.final = Bool::True;
ok($node,"Final can be set on blind nodes");

$dfa.final(Bool::True);
ok($dfa.final,"We can set final flags on nodes");
