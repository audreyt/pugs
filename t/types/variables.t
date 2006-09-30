use v6-alpha;

use Test;

plan 3;

{   my sub foo (Int $n --> Void) { }
    my sub bar (Int $n --> Int) { $n }
    # use our() to carry $ref to the next test
    # XXX syntax preliminary
    eval_ok q[our (Int --> Void) $ref], "Can declare typed subrefs", :todo<unspecced>;
    # should this be eval_ok? it depends on the previous test not being fatal to get the declaration
    eval_ok q[$ref = &foo], "can assign a sub with a compatible type to a typed subref", :todo<unspecced>;
    # should use throws_ok? 
    dies_ok { $ref = &bar }, "assigment of incompatible sub type dies";
}
