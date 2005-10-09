#!/usr/bin/pugs

use v6;
use Test;

plan 25;

{
    # simple try
    my $lived = undef;
    try { die "foo" };
    is($!, "foo", "error var was set");
};

# try should work when returning an array or hash
{
    my @array = try { 42 };
    is +@array,    1, '@array = try {...} worked (1)';
    is ~@array, "42", '@array = try {...} worked (2)';
}

{
    my @array = try { (42,) };
    is +@array,    1, '@array = try {...} worked (3)';
    is ~@array, "42", '@array = try {...} worked (4)';
}

{
    my %hash = try { "a" };
    is +%hash,        1, '%hash = try {...} worked (1)';
    is ~%hash.keys, "a", '%hash = try {...} worked (2)';
}

{
    my %hash = try { ("a",) };
    is +%hash,        1, '%hash = try {...} worked (3)';
    is ~%hash.keys, "a", '%hash = try {...} worked (4)';
}

{
    warn "Please ignore the next warning about odd number of elements,\n";
    warn "it's expected.\n";
    my %hash = try { hash("a",) };
    is +%hash,        1, '%hash = try {...} worked (5)';
    is ~%hash.keys, "a", '%hash = try {...} worked (6)';
}

{
    my %hash;
    # Extra try necessary because current Pugs dies without it.
    try { %hash = try { a => 3 } };
    is +%hash,        1, '%hash = try {...} worked (7)', :todo<bug>;
    is ~%hash.keys, "a", '%hash = try {...} worked (8)', :todo<bug>;
    is ~%hash<a>,     3, '%hash = try {...} worked (9)', :todo<bug>;
}

{
    # try with a catch
    my $caught;
    eval 'try {
        die "blah"

        CATCH /la/ { $caught = 1 }
    }';

    ok($caught, "exception caught", :todo);
};


{
    # exception classes
    eval 'class Naughty is Exception {}';

    my ($not_died, $caught);
    eval 'try {
        die Naughty "error"

        $not_died = 1;

        CATCH Naughty {
            $caught = 1;
        }
    }';

    ok(!$not_died, "did not live after death");
    ok($caught, "caught exception of class Naughty", :todo);
};

{
    # exception superclass
    eval 'class Naughty::Specific is Naughty {}';
    eval 'class Naughty::Other is Naughty {}';

    my ($other, $naughty);
    eval 'try {
        die Naughty::Specific "error";

        CATCH Naughty::Other {
            $other = 1;
        }
    
        CATCH Naughty {
            $naughty = 1;
        }
    }';

    ok(!$other, "did not catch sibling error class");
    ok($naughty, "caught superclass", :todo);
};

{
    # uncaught class
    eval 'class Dandy is Exception {}';

    my ($naughty, $lived);
    eval 'try {
            die Dandy "error";
        
            CATCH Naughty {
                $naughty = 1;
            }
        };

        $lived = 1;
    ';

    ok(!$lived, "did not live past uncaught throw in try", :todo);
    ok(ref($!), '$! is an object');
    is(eval('ref($!)'), "Dandy", ".. of the right class", :todo);
};

# return inside try{}-blocks
# PIL2JS *seems* to work, but it does not, actually:
# The "return 42" works without problems, and the caller actually sees the
# return value 42. But when the end of the test is reached, &try will
# **resume after the return**, effectively running the tests twice.
# (Therefore I moved the tests to the end, so not all tests are rerun).
{
    my $was_in_foo;
    sub foo {
        $was_in_foo++;
        try { return 42 };
        $was_in_foo++;
        return 23;
    }
    is foo(), 42,      'return() inside try{}-blocks works (1)', :todo<bug>;
    is $was_in_foo, 1, 'return() inside try{}-blocks works (2)', :todo<bug>;
}

{
    my sub test1 {
        try { return 42 };
        return 23;
    }

    my sub test2 {
        test1();
        die 42;
    }

    dies_ok { test2() },
        "return() inside a try{}-block should cause following exceptions to really die";
}
