use v6-alpha;

use Test;

plan 114;

my $foo = "FOO";
my $bar = "BAR";

=kwid

Tests quoting constructs as defined in L<S02/Literals>

=todo

* q:t - heredocs (done)
* q:n, q:b, and other interpolation levels (half-done)
* meaningful quotations (qx, rx, etc)
* review shell quoting semantics of «»
* arrays in «»
* interpolation of scalar, array, hash, function and closure syntaxes
* q : a d verb s // parsing

=cut

# L<S02/Lexical Conventions/"bidirectional mirrorings" or "Ps/Pe properties">
{
    my $s = q{ foo bar };
    is $s, ' foo bar ', 'string using q{}';
}

{
    my $s = q「this is a string」;
    is $s, 'this is a string',
        'q-style string with LEFT/RIGHT CORNER BRACKET';
}

{
    my $s = q『blah blah blah』;
    is $s, 'blah blah blah',
        'q-style string with LEFT/RIGHT WHITE CORNER BRACKET';
}

{
    my @list = 'a'..'c';

    my $var = @list[ q（2） ];
    is $var, 'c',
        'q-style string with FULLWIDTH LEFT/RIGHT PARENTHESIS';

    $var = @list[ q《0》];
    is $var, 'a',
        'q-style string with LEFT/RIGHT DOUBLE ANGLE BRACKET';

    $var = @list[q〈1〉];
    is $var, 'b', 'q-style string with LEFT/RIGHT ANGLE BRACKET';
}

# L<S02/Literals/":q" ":single" "Interpolate \\, \q and \'">
{
    my @q = ();
    @q = (q/$foo $bar/);
    is(+@q, 1, 'q// is singular');
    is(@q[0], '$foo $bar', 'single quotes are non interpolating');
};

{ # and it's complement ;-)
    my @q = ();
    @q = '$foo $bar';
    is(+@q, 1, "'' is singular");
    is(@q[0], '$foo $bar', 'and did not interpolate either');
};

{ # non interpolating single quotes with nested parens L<S02/Literals /That is.*?\(\).*?have no special significance/>
    my @q = ();
    try { eval '@q = (q (($foo $bar)))' };
    is(+@q, 1, 'q (()) is singular');
    is(@q[0], '$foo $bar', 'and nests parens appropriately');
};

{ # non interpolating single quotes with nested parens L<S02/Literals /That is.*?\(\).*?have no special significance/>
    my @q = ();
    try { eval '@q = (q ( ($foo $bar)))' };
    is(+@q, 1, 'q () is singular');
    is(@q[0], ' ($foo $bar)', 'and nests parens appropriately');
};

{ # q() is bad L<S02/Literals /Which is mandatory for parens/>
    my @q;
    sub q { @_ }
    @q = q($foo,$bar);
    is(+@q, 2, 'q() is always sub call', :todo);
};

{ # adverb variation L<S02/Literals /:q/>
    my @q = ();
    @q = (q:q/$foo $bar/);
    is(+@q, 1, "q:q// is singular");
    is(@q[0], '$foo $bar', "and again, non interpolating");
};

{ # nested brackets
    my @q = ();
    @q = (q[ [$foo $bar]]);
    is(+@q, 1, 'q[] is singular');
    is(@q[0], ' [$foo $bar]', 'and nests brackets appropriately');
};

{ # nested brackets
    my @q = ();
    @q = (q[[$foo $bar]]);
    is(+@q, 1, 'q[[]] is singular');
    is(@q[0], '$foo $bar', 'and nests brackets appropriately');
};

{ # interpolating quotes L<S02/Literals /same as qq/>
    my @q = ();
        @q = qq/$foo $bar/;
    is(+@q, 1, 'qq// is singular');
    is(@q[0], 'FOO BAR', 'variables were interpolated');
};

{ # "" variation
    my @q = ();
        @q = "$foo $bar";
    is(+@q, 1, '"" is singular');
    is(@q[0], "FOO BAR", '"" interpolates');
};

{ # adverb variation L<S02/Literals /:qq/>
    my @q = ();
    @q = q:qq/$foo $bar/;
    is(+@q, 1, "q:qq// is singular");
    is(@q[0], "FOO BAR", "blah blah interp");
};

{ # \qq[] constructs interpolate in q[] L<S02/Literals /using the \\qq/>
    my( @q1, @q2, @q3, @q4 ) = ();
    @q1 = q[$foo \qq[$bar]];
    is(+@q1, 1, "q[...\\qq[...]...] is singular");
    is(@q1[0], '$foo BAR', "and interpolates correctly");

    @q2 = '$foo \qq[$bar]';
    is(+@q2, 1, "'...\\qq[...]...' is singular");
    is(@q2[0], '$foo BAR', "and interpolates correctly");

    @q3 = q[$foo \q:s{$bar}];
    is(+@q3, 1, 'q[...\\q:s{...}...] is singular');
    is(@q3[0], '$foo BAR', "and interpolates correctly");

    @q4 = q{$foo \q/$bar/};
    is(+@q4, 1, 'q{...\\q/.../...} is singular');
    is(@q4[0], '$foo $bar', "and interpolates correctly");
}

{ # quote with \0 as delimiters L<news:20050101220112.GF25432@plum.flirble.org>
    my @q = ();
    try { eval "\@q = (q\0foo bar\0)" };
    is(+@q, 1, "single quote with \\0 delims are parsed ok");
    is(@q[0], "foo bar", "and return correct value");
};


{ # traditional quote word
    my @q = ();
    @q = (qw/$foo $bar/);
    is(+@q, 2, "qw// is plural");
    is(@q[0], '$foo', "and non interpolating");
    is(@q[1], '$bar', "...");
};

{ # angle brackets L<S02/Literals /the qw.*?quote operator.*?bracketed form/>
    my @q = ();
    @q = <$foo $bar>;
    is(+@q, 2, "<> behaves the same way");
    is(@q[0], '$foo', 'for interpolation too');
    is(@q[1], '$bar', '...');
};

{ # angle brackets L<S02/Literals /the qw.*?quote operator.*?bracketed form/>
    my @q = ();
    @q = < $foo $bar >;
    is(+@q, 2, "<> behaves the same way, with leading (and trailing) whitespace");
    is(@q[0], '$foo', 'for interpolation too');
    is(@q[1], '$bar', '...');
};

{ # adverb variation
    my @q = ();
    @q = (q:w/$foo $bar/);
    is(+@q, 2, "q:w// is like <>");
    is(@q[0], '$foo', "...");
    is(@q[1], '$bar', "...");
};

{ # whitespace sep aration does not break quote constructor 
  # L<S02/Literals /Whitespace is allowed between the "q" and its adverb: q :w /..././>
    my @q = ();
    try { eval '@q = (q :w /$foo $bar/)' };
    is(+@q, 2, "q :w // is the same as q:w//",:todo<bug>);
    is(@q[0], '$foo', "...",:todo<bug>);
    is(@q[1], '$bar', "...",:todo<bug>);
};


{ # qq:w,Interpolating quote constructor with words adverb 
  # L<S02/Literals /Split result on words (no quote protection)/>
    my (@q1, @q2) = ();
    @q1 = qq:w/$foo "gorch $bar"/;
    @q2 = qq:words/$foo "gorch $bar"/;

    is(+@q1, 3, 'qq:w// correct number of elements');
    is(+@q2, 3, 'qq:words correct number of elements');

    is(~@q1, 'FOO "gorch BAR"', "explicit quote word interpolates");
    is(~@q2, 'FOO "gorch BAR"', "long form output is the same as the short");
};

{ # qq:ww, interpolating L<S02/Literals /double angles do interpolate/>
  # L<S02/Literals/"implicit split" "shell-like fashion">
    my (@q1, @q2, @q3, @q4) = ();
    @q1 = qq:ww/$foo "gorch $bar"/;
    @q2 = «$foo "gorch $bar"»; # french
    @q3 = <<$foo "gorch $bar">>; # texas
    @q4 = qq:quotewords/$foo "gorch $bar"/; # long

    is(+@q1, 2, 'qq:ww// correct number of elements',:todo<bug>);
    is(+@q2, 2, 'french double angle',:todo<bug>);
    is(+@q3, 2, 'texas double angle',:todo<bug>);
    is(+@q4, 2, 'long form',:todo<bug>);

    is(~@q1, 'FOO gorch BAR', "explicit quote word interpolates", :todo<bug>);
    is(~@q2, 'FOO gorch BAR', "output is the same as french",:todo<bug>);
    # L<S02/Literals/the built-in «...» quoter automatically does interpolation equivalent to qq:ww/.../ />
    is(~@q3, 'FOO gorch BAR', ", texas quotes",:todo<bug>);
    is(~@q4, 'FOO gorch BAR', ", and long form",:todo<bug>);
};

{
    #L<S02/Literals/"relationship" "single quotes" "double angles">
    # Pugs was having trouble with this.  Fixed in r12785.
    my ($x, $y) = <a b>;
    ok(«$x $y» === <a b>, "«$x $y» interpolation works correctly");
};

{ # qw, interpolating, shell quoting L<S02/Literals /respects quotes in a shell-like fashion/>
    my (@q1, @q2) = ();
    my $gorch = "foo bar";

    @q1 = «$foo $gorch $bar»;
    is(+@q1, 4, "4 elements in unquoted «» list");
    is(@q1[2], "bar", '$gorch was exploded');
    is(@q1[3], "BAR", '$bar was interpolated');

    @q2 = «$foo "$gorch" '$bar'»;
    is(+@q2, 3, "3 elementes in sub quoted «» list", :todo);
    is(@q2[1], $gorch, 'second element is both parts of $gorch, interpolated', :todo);
    is(@q2[2], '$bar', 'single quoted $bar was not interpolated', :todo);
};

{ # qq:t L<S02/Literals /Heredocs are no longer written/>
    my @q = ();

    try { eval '@q = qq:t/FOO/;
blah
$bar
blah
$foo
FOO
    ' };

    is(+@q, 1, "q:t// is singular", :todo);
    is(@q[0], "blah\nBAR\nblah\nFOO\n", "here doc interpolated", :todo);
};

{ # q:t indented L<S02/Literals /Here docs allow optional whitespace/>
    my @q = ();

    try { eval '@q = q:t/FOO/;
        blah blah
        $foo
        FOO
    ' };

    is(+@q, 1, "q:t// is singular, also when indented", :todo);
    is(@q[0], "blah blah\n\$foo\n", "indentation stripped", :todo);
};

{ # q:to backslash bug
        my @q = q:to/FOO/
yoink\n
splort\\n
FOO
;
        is(+@q, 1, "q:to// is singular");
        is(@q[0], "yoink\\n\nsplort\\n\n", "backslashes");
}

{ # q:n L<S02/Literals /No escapes at all/>
    my @q = ();
    
    my $backslash = "\\";

    @q = (q:n/foo\\bar$foo/);

    is(+@q, 1, "q:n// is singular");
    is(@q[0], "foo\\\\bar\$foo", "special chars are meaningless"); # double quoting is to be more explicit
};

{ # q:n L<S02/Literals /No escapes at all/>
    my @q = ();
    
    my $backslash = "\\";

    @q = (qn/foo\\bar$foo/);

    is(+@q, 1, "qn// is singular");
    is(@q[0], "foo\\\\bar\$foo", "special chars are meaningless"); # double quoting is to be more explicit
};

{ # L<S02/Literals/"Pair" notation is also recognized inside>
  # <<:Pair>>
    diag "XXX: pair.perl is broken atm so these tests may be unreliable";

    my @q = <<:p(1)>>;
    is(@q[0].perl, (:p(1)).perl, "pair inside <<>>-quotes - simple", :todo<bug>);

    @q = <<:p(1) junk>>;
    is(@q[0].perl, (:p(1)).perl, "pair inside <<>>-quotes - with some junk", :todo<bug>);
    is(@q[1], 'junk', "pair inside <<>>-quotes - junk preserved");

    @q = <<:def>>;
    is(@q[0].perl, (def => 1).perl, ":pair in <<>>-quotes with no explicit value", :todo<bug>);

    @q = "(eval failed)";
    try { eval '@q = <<:p<moose>>>;' };
    is(@q[0].perl, (p => "moose").perl, ":pair<anglequoted>", :todo<bug>);
};

{ # weird char escape sequences
    is("\d97", "a", '\d97 is "a"');
    is("\d102oo", "foo", '\d102 is "f", works next to other letters');
    is("\d123", chr 123, '"\dXXX" and chr XXX are equivalent');
    is("\d[12]3", chr(12) ~ "3", '\d[12]3 is the same as chr(12) concatenated with "3"');
    is("\d[12] 3", chr(12) ~ " 3", 'respects spaces when interpolating a space character');

    is("\x41", "A", 'hex interpolation - \x41 is "A"');
    is("\o101", "A", 'octal interpolation - \o101 is also "A"' );

    is("\c@", "\0", 'Unicode code point "@" converts correctly to "\0"');
    is("\cA", chr 1, 'Unicode "A" is #1!');
    is("\cZ", chr 26, 'Unicode "Z" is chr 26 (or \d26)');
}

{ # simple test for nested-bracket quoting, per S02
    my $hi = q<<hi>>;
    is($hi, "hi", 'q<<hi>> is "hi"');
}


# L<S02/"Generalized quotes may now take adverb:" /for user-defined quotes/>
# q:t
{
# XXX
# Pugs has problem for parsing heredoc stream.
# The one works is:
# my $t = q:t /STREAM/
# Hello, world
# STREAM;
# But this one doesn't conform to the Synopsis...

    my $t;
    eval_ok q{$t = q:t /STREAM/;
Hello, world
STREAM
    }, :todo<parsefail>;

    is $t, "Hello, World\n", "Testing for q:t operator.";

    eval_ok qq{
$t = q:t /结束/;
Hello, World
结束
    }, :todo<parsefail>;

    is $t, "Hello, World\n", "Testing for q:t operator. (utf8)";
}

# q:n
{
    my $s1 = "hello";
    my $t1 = q:n /$s1, world/;
    is $t1, '$s1, world', "Testing for q:n operator.";

    my $s2 = "你好";
    my $t2 = q:n /$s2, 世界/;
    is $t2, '$s2, 世界', "Testing for q:n operator. (utf8)";
}

# q:b
{
    my $t = q:b /\n\n\n/;
    is $t, "\n\n\n", "Testing for q:b operator.";
}

# q:x
{
    is q:x/echo hello/, "hello\n", "Testing for q:x operator.";
}
# utf8
{
    # 一 means "One" in Chinese.
    is q:x/echo 一/, "一\n", "Testing for q:x operator. (utf8)";
}

# q:h
{
    # Pugs can't parse q:h currently.
    my %t = (a => "perl", b => "rocks");
    my $s;
    eval_ok "$s = q;h /%t<>/", :todo<parsefail>;
    is $s, ~%t, "Testing for q:h operator.";
}

# q:f
{
    sub f { "hello" };
    my $t = q:f /&f(), world/;
    is $t, f() ~ ", world", "Testing for q:f operator.";

    sub f_utf8 { "你好" };
    $t = q:f /&f_utf8(), 世界/;
    is $t, f_utf8() ~ ", 世界", "Testing for q:f operator. (utf8)";
}

# q:c
{
    sub f { "hello" };
    my $t = q:c /{f}, world/;
    is $t, f() ~ ", world", "Testing for q:c operator.";
}

# q:a
{
    my @t = qw/a b c/;
    my $s = q:a /@t[]/;
    is $s, ~@t, "Testing for q:a operator.";
}

# q:s
{
    my $s = "someone is laughing";
    my $t = q:s /$s/;
    is $t, $s, "Testing for q:s operator.";

    my $s = "有人在笑";
    my $t = q:s /$s/;
    is $t, $s, "Testing for q:s operator. (utf8)";
}
