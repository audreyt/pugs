use v6-alpha;

use Test;

plan 56;

=kwid

This tests the smartmatch operator, defined in L<S03/"Smart matching">

note that ~~ is currently a stub, and is really eq.
the reason it's parsed is so that eval '' won't be around everywhere, not for
emulation.

=cut

{ #L<<S03/"Smart matching" /Any Code:($) scalar sub truth match>>
    sub uhuh { 1 }
    sub nuhuh { undef }

    ok((undef ~~ &uhuh), "scalar sub truth");
    ok(!(undef ~~ &nuhuh), "negated scalar sub false");
};


my %hash1 is context = ( "foo", "Bar", "blah", "ding");
my %hash2 is context = ( "foo", "zzz", "blah", "frbz");
my %hash3 is context = ( "oink", "da", "blah", "zork");
my %hash4 is context = ( "bink", "yum", "gorch", "zorba");
my %hash5 is context = ( "foo", 1, "bar", 1, "gorch", undef, "baz", undef );

#L<<S03/Smart matching/Hash "hash keys identical"
#   if $_.keys.sort »eq« $x.keys.sort>>
{ 
    ok eval('(%+hash1 ~~ %+hash2)'), "hash keys identical", :todo;
    ok eval('!(%+hash1 ~~ %+hash4)'), "hash keys differ";
};

#L<<S03/Smart matching/Hash any(Hash) "hash key intersection" match>>
{ 
    ok((%hash1 ~~ any(%hash3)), "intersecting keys", :todo);
    ok(!(%hash1 ~~ any(%hash4)), "no intersecting keys");
};

#L<<S03/Smart matching/Hash Array "hash value slice truth" "match if">>
{ 
    my @true = (<foo bar>);
    my @sort_of = (<foo gorch>);
    my @false = (<gorch baz>);
    ok((%hash5 ~~ @true), "value slice true", :todo);
    ok((%hash5 ~~ @sort_of), "value slice partly true", :todo);
    ok(!(%hash5 ~~ @false), "value slice false");
};

#L<<S03/Smart matching/Hash any(list) "hash key slice existence" match>>
{ 
    ok((%hash1 ~~ any(<foo bar>)), "any key exists (but where is it?)", :todo);
    ok(!(%hash1 ~~ any(<gorch ding>)), "no listed key exists");
};

#L<<S03/Smart matching/Hash all(list) "hash key slice existence" match>>
{ 
    ok((%hash1 ~~ all(<foo blah>)), "all keys exist", :todo);
    ok(!(%hash1 ~~ all(<foo edward>)), "not all keys exist");
};

#Hash    Rule      hash key grep            match if any($_.keys) ~~ /$x/

#L<<S03/Smart matching/Hash Any "hash entry existence" "match if exists">>
{ 
    ok((%hash5 ~~ "foo"), "foo exists", :todo);
    ok((%hash5 ~~ "gorch"),
       "gorch exists, true although value is false", :todo);
    ok((%hash5 ~~ "wasabi"), "wasabi does not exist", :todo);
};

#L<<S03/Smart matching/Hash .{Any} "hash element truth*">>
{ 
    my $string is context = "foo";
    ok eval('(%+hash5 ~~ .{$+string})'), 'hash.{Any} truth', :todo;
    $string = "gorch";
    ok eval('!(%+hash5 ~~ .{$+string})'), 'hash.{Any} untruth', :todo;
};

#L<<S03/Smart matching/Hash .<string> "hash element truth*">>
{ 
    ok eval('(%+hash5 ~~ .<foo>)'), "hash<string> truth", :todo;
    ok eval('!(%+hash5 ~~ .<gorch>)'), "hash<string> untruth", :todo;
};

#L<<S03/Smart matching/Array Array "arrays are comparable" »~~«>>
{ 
    ok((("blah", "blah") ~~ ("blah", "blah")), "qw/blah blah/ .eq");
    ok(!((1, 2) ~~ (1, 1)), "1 2 !~~ 1 1");
};

#L<<S03/Smart matching/Array any(list) "list intersection" any(@$_) >>
{ 
    ok(((1, 2) ~~ any(2, 3)),
       "there is intersection between (1, 2) and (2, 3)", :todo);
    ok(!((1, 2) ~~ any(3, 4)),
       "but none between (1, 2) and (3, 4)");
};

# Array   Rule      array grep               match if any(@$_) ~~ /$x/

#L<<S03/Smart matching/Array Num "array contains number">>
{ 
    ok(((1, 2) ~~ 1), "(1, 2) contains 1", :todo);
    ok(!((3, 4, 5) ~~ 2), "(3, 4, 5) doesn't contain 2");
};

#L<<S03/Smart matching/Array Str "array contains string">>
{ 
    ok((("foo", "bar", "gorch") ~~ "bar"),
       "bar is in qw/foo bar gorch/", :todo);
    ok(!(("x", "y", "z") ~~ "a"), "a is not in qw/x y z/");
};

#L<<S03/Smart matching/Array .[number] "array element truth*">>
{ 
    ok eval('((undef, 1, undef) ~~ .[1])'),
        "element 1 of (undef, 1, undef) is true", :todo;
    ok eval('!((undef, undef) ~~ .[0])'),
        "element 0 of (undef, undef) is false";
};

#L<<S03/"Smart matching" /Num NumRange "in numeric range">>
{ 
    ok((5 ~~ 1 .. 10), "5 is in 1 .. 10", :todo);
    ok(!(10 ~~ 1 .. 5), "10 is not in 1 .. 5");
    ok(!(1 ~~ 5 .. 10), "1 is not i n 5 .. 10");
    #ok(!(5 ~~ 5 ^..^ 10), "5 is not in 5 .. 10, exclusive"); # phooey
};

#Str     StrRange  in string range          match if $min le $_ le $max

#L<<S03/Smart matching/Any Code:() "simple closure truth*">>
{ 
    ok((1 ~~ { 1 }), "closure truth");
    ok((undef ~~ { 1 }), 'ignores $_');
};

#L<<S03/Smart matching/Any Class "class membership" $_.does($x)>>
{ 
    class Dog {}
    class Cat {}
    class Chihuahua is Dog {} # i'm afraid class Pugs will get in the way ;-)

    ok eval('(Chihuahua ~~ Dog)'), "chihuahua isa dog";
    ok eval('!(Chihuahua ~~ Cat)'), "chihuahua is not a cat";
};

#Any     Role      role playing             match if \$_.does(\$x)

#L<<S03/Smart matching/Any Num "numeric equality" match>>
{ 
    ok((1 ~~ 1), "one is one");
    ok(!(2 ~~ 1), "two is not one");
};

#L<<S03/Smart matching/Any Str "string equality" match>>
{ 
    ok(("foo" ~~ "foo"), "foo eq foo");
    ok(!("bar" ~~ "foo"), "!(bar eq foo)");
};

# no objects, no rules
# ... staring vin diesel and kevin kostner! (blech)
#Any     .method   method truth*            match if $_.method
#Any     Rule      pattern match            match if $_ ~~ /$x/
#Any     subst     substitution match*      match if $_ ~~ subst

# i don't understand this one
#Any     boolean   simple expression truth* match if true given $_

#L<<S03/Smart matching/Any undef undefined "match unless defined $_" >>
{ 
    ok(!("foo" ~~ undef), "foo is not ~~ undef");
    ok((undef ~~ undef), "undef is");
};

# does this imply MMD for $_, $x?
#Any     Any       run-time dispatch        match if infix:<~~>($_, $x)


#L<S03/Smart matching>
{ 
    # representational checks for !~~, rely on ~~ semantics to be correct
    # assume negated results

    ok(!("foo" !~~ "foo"), "!(foo ne foo)");
    ok(("bar" !~~ "foo"), "bar ne foo)");

    ok(!((1, 2) !~~ 1), "(1, 2) contains 1", :todo);
    ok(((3, 4, 5) !~~ 2), "(3, 4, 5) doesn't contain 2");

    ok(!(%hash1 !~~ any(%hash3)), "intersecting keys", :todo);
    ok((%hash1 !~~ any(%hash4)), "no intersecting keys");
};

{
=for Explanation

You may be wondering what the heck is with all these try blocks.
Prior to r12503, this test caused a horrible death of Pugs which
magically went away when used inside an eval.  So the try blocks
caught that case.

=cut

    #L<S09/"Junctions"/grep>
    my @x = 1..20;
    my $code = -> $x { $x % 2 };
    my @result;
    my $parsed = 0;
    try {
        @result = any(@x) ~~ $code;
        $parsed = 1;
    };
    ok $parsed, 'C<my @result = any(@x) ~~ $code> parses';
    my @expected_result = grep $code, @x;
    ok @result ~~ @expected_result,
        'C<any(@x) ~~ {...}> works like C<grep>', :todo<feature>;

    my $result = 0;
    $parsed = 0;
    try {
        $result = all(@x) ~~ { $_ < 21 };
        $parsed = 1;
    };
    ok $parsed, 'C<all(@x) ~~ { ... }> parses';
    ok $result, 'C<all(@x) ~~ { ... } when true for all';

    $result = 0;
    try {
        $result = !(all(@x) ~~ { $_ < 20 });
    };
    ok $result,
        'C<all(@x) ~~ {...} when true for one';

    $result = 0;
    try {
        $result = !(all(@x) ~~ { $_ < 12 });
    };
    ok $result,
        'C<all(@x) ~~ {...} when true for most';

    $result = 0;
    try {
        $result = !(all(@x) ~~ { $_ < 1  });
    };
    ok $result,
        'C<all(@x) ~~ {...} when true for one';
};
