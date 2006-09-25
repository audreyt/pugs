use Test; plan 13;

# L<S12/"Calling Sets of Methods">
# L<S12/"Roles">

# Spec:
# For any method name, there may be some number of candidate methods that could
# handle the request: typically, inherited methods or multi variants. The
# ordinary "dot" operator dispatches to a method in the standard fashion. There
# are also "dot" variants that call some number of methods with the same name:

#      $object.?meth  # calls method if there is one, otherwise undef
class Parent {
    has Int $.cnt is rw;
    does plugin_1;
    does plugin_2;
    method meth {$.cnt++}
}
class Child is Parent {
    method meth {$.cnt++}
    method child_only {'child_only'}
}

role plugin_1 { multi method init_hook { $.cnt += 2 } }
role plugin_2 { multi method init_hook { $.cnt += 3 } }


{
    my $test = q"$object.?meth calls method is there one";
    my $object = Child.new;
    my $result = 1; # default to one to see if value changes to undef
    try { $result = $object.?nope };
    ok($object.?meth, $test);
    is($result,undef, q"                                       ..undef otherwise ");
    # TODO: add test for $object.?$meth (dynamic method) as well
}

{
    my $test = q"$object.*meth(@args)  # calls all methods (0 or more)";
    my $object = Child.new;
    my $result = 1; # default to one to see if value changes to undef
    try { $result = $object.*nope };
    is($result,undef, q"$test: Case 0 returns undef");

    try { $result = $object.*child_only };
    is($result, 'child_only', "$test: Case 1 fines one result"); 

    try { $result = $object.*meth };
    is($object.cnt, 2, "$test: Case 2 visits both Child and Parent");

    my $meth = 'meth';
    $object = Child.new;
    try { $result = $object.*$meth };
    is($object.cnt, 2, "$test: Case 2 visits both Child and Parent (as dynamic method call)");

    my $meth = 'sqrt'; 
    my $ans = 0;
    try { $ans = 4.*$meth };
    is($ans, 2, q"$obj.*$meth works built-in methods like 'sqrt'");

}

{
    # We should not only look in parent classes, but for matching 
    # multi methods in parent classes!
    my $test = q"$object.*meth(@args)  # calls all methods (0 or more) works on multi axis, too";
    my $object = Child.new;
    my $got = 0;
    my $meth = 'init_hook';
    try { $got = $object.*$meth };
    is($got, 5, $test);
}

{
    my $test = q"$object.+meth(@args)  # calls all methods (1 or more)";
    my $object = Child.new;
    my $result = 1; # default to one to see if value changes to undef
    try { $result = $object.+nope };
    ok($!, q"$test: Case 0 dies");

    try { $result = $object.+child_only };
    is($result, 'child_only', "$test: Case 1 fines one result"); 

    try { $result = $object.+meth };
    is($object.cnt, 2, "$test: Case 2 visits both Child and Parent");

    # TODO: add test for $object.+$meth (dynamic method) as well

}

ok(0,q'STUB: $object.*WALK[:breadth:omit($?CLASS)]::meth(@args);', :todo<feature> );

ok(0, "STUB: there is more Calling Sets functionality which needs tests", :todo<feature>);
# vim: ft=perl6
