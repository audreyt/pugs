use v6-alpha;

use Test;

plan 91;

my $foo = "FOO";
my $bar = "BAR";

=kwid

Tests quoting constructs as defined in L<S02/Literals>

=todo

* q:t - heredocs
* q:n, q:b, and other interpolation levels
* meaningful quotations (qx, rx, etc)
* review shell quoting semantics of «»
* arrays in «»
* interpolation of scalar, array, hash, function and closure syntaxes
* q : a d verb s // parsing

=cut


{ # backslash interpolation only single quotes L<S02/Literals /:single\s+Interpolate \\\\,/>
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
    # L<S02/Literals /the built-in «...» quoter automatically does interpolation equivalent to qq:ww/.../ />
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

{ # <<:Pair>> L<S02/Literals /"Pair" notation is also recognized inside/>
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
