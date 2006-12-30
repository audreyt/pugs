use v6-alpha;

use Test;

plan 18;

{
    my $arglist = \(1,2,3);
    
    # L<S03/Argument List Interpolating/explicitly flatten it in one of/>
    my sub foo ($a, $b, $c) { "$a!$b!$c" }
    is try { &foo.callwith(|$arglist) }, "1!2!3",
        "simply arglist creation with \\( works (1)";
}

{
    my $arglist = \(1,2,3,'too','many','args');
    
    # L<S03/Argument List Interpolating/explicitly flatten it in one of/>
    my sub foo ($a, $b, $c) { "$a!$b!$c" }
    dies_ok { &foo.callwith(|$arglist) },
        "simply arglist creation with \\( works (2)", :todo<feature>;
}

{
    my $arglist = \(1, named => "arg");
    
    # L<S03/Argument List Interpolating/explicitly flatten it in one of/>
    my sub foo ($a, :$named) { "$a!$named" }
    is try { &foo.callwith(|$arglist) }, "1!arg",
        "simply arglist creation with \\( works (3)";
}

{
    my $arglist = try { \(1, 'positional' => "pair") };
    
    # L<S03/Argument List Interpolating/explicitly flatten it in one of/>
    my sub foo ($a, $pair) { "$a!$pair" }
    is try { &foo.callwith(|$arglist) }, "1!positional\tpair",
        "simply arglist creation with \\( works (4)", :todo<feature>;
}

{
    my @array   = <a b c>;
    my $arglist = try { \(@array) };

    # L<S03/Argument List Interpolating/explicitly flatten it in one of/>
    my sub foo (@arr) { ~@arr }
    is try { &foo.callwith(|$arglist) }, "a b c",
        "arglist creation with \\( works", :todo<feature>;
}

# L<S06/"Argument list binding" /single scalar parameter marked/>
{
    my sub bar ($a, $b, $c) { "$a!$b!$c" }
    my sub foo (\$arglist)  { &bar.callwith(|$arglist) }

    is try { foo(1,2,3) }, "1!2!3",
        "arglist creation with \\$ works (1)", :todo<feature>;
    dies_ok { foo(1,2,3,4) },  # too many args
        "arglist creation with \\$ works (2)";
    dies_ok { foo(1,2) },      # too few args
        "arglist creation with \\$ works (3)";
    is try { foo(a => 1, b => 2, c => 3) }, "1!2!3",
        "arglist creation with \\$ works (4)", :todo<feature>;
    is try { foo(1, b => 2, c => 3) }, "1!2!3",
        "arglist creation with \\$ works (5)", :todo<feature>;
}

# Arglists are first-class objects
{
    my $arglist;
    my sub foo (\$args) { $arglist = $args }

    lives_ok { foo(1,2,3,4) }, "arglists are first-class objects (1)", :todo<feature>;
    ok $arglist,               "arglists are first-class objects (2)", :todo<feature>;

    my $old_arglist = $arglist;
    lives_ok { foo(5,6,7,8) }, "arglists are first-class objects (3)", :todo<feature>;
    ok $arglist,               "arglists are first-class objects (4)", :todo<feature>;
    ok !($arglist === $old_arglist), "arglists are first-class objects (5)", :todo<feature>;
}

{
    my $arglist1;
    my sub foo ($args) { $arglist1 = $args }

    my $arglist2 = \(1,2,3);
    try { foo $arglist2 };  # note: no |$args here

    cmp_ok $arglist1, &infix:<===>, $arglist2,
        "unflattened arglists can be passed to subs";
}

# Mixing ordinary args with arglists
{
    my $arglist = \(:foo<bar>, :baz<grtz>);
    my sub foo ($a,$b, :$foo, :$baz) { "$a!$b!$foo!$baz" }

    dies_ok { &foo.callwith(|$arglist) },  # too few args
        "mixing ordinary args with arglists (1)";
    is &foo.callwith(1, 2, |$arglist), "1!2!bar!grtz",
        "mixing ordinary args with arglists (2)";
}

# XXX sub foo (\@arglist)
