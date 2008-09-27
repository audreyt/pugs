use v6;

use Test;

plan 135;

my $foo = "FOO";
my $bar = "BAR";

=begin description

Tests quoting constructs as defined in L<S02/Literals>

Note that non-ASCII tests are kept in quoting-unicode.t

=todo

* q:b and other interpolation levels (half-done)
* meaningful quotations (qx, rx, etc)
* interpolation of scalar, array, hash, function and closure syntaxes
* q : a d verb s // parsing

=end description

# L<S02/Lexical Conventions/"bidirectional mirrorings" or "Ps/Pe properties">
{
    my $s = q{ foo bar };
    is $s, ' foo bar ', 'string using q{}';
}

#?rakudo skip 'Quoting with q{{ ... }}'
{
    is q{ { foo } }, ' { foo } ',   'Can nest curlies in q{ .. }';
    is q{{ab}},      'ab',          'Unnested single curlies in q{{...}}';
    is q{{ fo} }},   ' fo} ',       'Unnested single curlies in q{{...}}';
    is q{{ {{ } }} }}, ' {{ } }} ', 'Can nest double curlies in q{{...}}';
}

{
    is q{\n},        '\n',          'q{..} do not interpolate \n';
    ok q{\n}.chars == 2,            'q{..} do not interpolate \n';
    is q{$x},        '$x',          'q{..} do not interpolate scalars';
    ok q{$x}.chars == 2,            'q{..} do not interpolate scalars';
}

#?rakudo skip 'Q quoting'
{
    is Q{\n},        '\n',          'Q{..} do not interpolate \n';
    ok Q{\n}.chars == 2,            'Q{..} do not interpolate \n';
    is Q{$x},        '$x',          'Q{..} do not interpolate scalars';
    ok Q{$x}.chars == 2,            'Q{..} do not interpolate scalars';
    is Q {\\},       '\\\\',        'Q {..} quoting';
}

#?rakudo skip 'Q quoting'
{
    ok Q{\\}.chars == 2,            'Q{..} do not interpolate backslashes';
}

# L<S02/Literals/":q" ":single" "Interpolate \\, \q and \'">
{
    my @q = ();
    @q = (q/$foo $bar/);
    is(+@q, 1, 'q// is singular');
    is(@q[0], '$foo $bar', 'single quotes are non interpolating');
};

{ # and its complement ;-)
    my @q = ();
    @q = '$foo $bar';
    is(+@q, 1, "'' is singular");
    is(@q[0], '$foo $bar', 'and did not interpolate either');
};

# L<S02/Literals/That is () have no special significance>
# non interpolating single quotes with nested parens
#?rakudo skip 'quoting with double delimiters'
{
    my @q = ();
    @q = (q (($foo $bar)));
    is(+@q, 1, 'q (()) is singular');
    is(@q[0], '$foo $bar', 'and nests parens appropriately');
};

# L<S02/Literals/That is () have no special significance>
#?rakudo skip 'quoting with q (..)'
{ # non interpolating single quotes with nested parens
    my @q = ();
    @q = (q ( ($foo $bar)));
    is(+@q, 1, 'q () is singular');
    is(@q[0], ' ($foo $bar)', 'and nests parens appropriately');
};

# L<S02/Literals/Which is mandatory for parens>
#?rakudo todo 'q() is a sub call'
{ # q() is bad
    my @q;
    sub q { @_ }
    @q = q($foo,$bar);
    is(+@q, 2, 'q() is always sub call');
};

# L<S02/Literals/:q>
#?rakudo skip 'quoting with adverbs'
{ # adverb variation
    my @q = ();
    @q = (Q:q/$foo $bar/);
    is(+@q, 1, "Q:q// is singular");
    is(@q[0], '$foo $bar', "and again, non interpolating");
};

#?rakudo skip 'nested bracket quotes'
{ # nested brackets
    my @q = ();
    @q = (q[ [$foo $bar]]);
    is(+@q, 1, 'q[] is singular');
    is(@q[0], ' [$foo $bar]', 'and nests brackets appropriately');
};

#?rakudo skip 'nested bracket quotes'
{ # nested brackets
    my @q = ();
    @q = (q[[$foo $bar]]);
    is(+@q, 1, 'q[[]] is singular');
    is(@q[0], '$foo $bar', 'and nests brackets appropriately');
};

# L<S02/Literals/qq:>
{ # interpolating quotes
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

# L<S02/Literals/:qq>
#?rakudo skip 'quoting with adverbs'
{ # adverb variation
    my @q = ();
    @q = Q:qq/$foo $bar/;
    is(+@q, 1, "Q:qq// is singular");
    is(@q[0], "FOO BAR", "blah blah interp");
};

# L<S02/Literals/using the \qq>
#?rakudo skip 'q[..] with variations'
{ # \qq[] constructs interpolate in q[]
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

#?rakudo todo '\0 as delimiters'
{ # quote with \0 as delimiters L<news:20050101220112.GF25432@plum.flirble.org>
    my @q = ();
    eval "\@q = (q\0foo bar\0)";
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

# L<S02/Literals/quote operator now has a bracketed form>
{ # angle brackets
    my @q = ();
    @q = <$foo $bar>;
    is(+@q, 2, "<> behaves the same way");
    is(@q[0], '$foo', 'for interpolation too');
    is(@q[1], '$bar', '...');
};

{ # angle brackets
    my @q = ();
    @q = < $foo $bar >;
    is(+@q, 2, "<> behaves the same way, with leading (and trailing) whitespace");
    is(@q[0], '$foo', 'for interpolation too');
    is(@q[1], '$bar', '...');
};

#?rakudo skip 'quoting with adverbs'
{ # adverb variation
    my @q = ();
    @q = (q:w/$foo $bar/);
    is(+@q, 2, "q:w// is like <>");
    is(@q[0], '$foo', "...");
    is(@q[1], '$bar', "...");
};

#?rakudo skip 'quoting with adverbs'
{ # whitespace sep aration does not break quote constructor 
  # L<S02/Literals/Whitespace is allowed between the "q" and its adverb: q :w /.../.>
    my @q = ();
    @q = (q :w /$foo $bar/);
    is(+@q, 2, "q :w // is the same as q:w//");
    is(@q[0], '$foo', "...");
    is(@q[1], '$bar', "...");
};


#?rakudo skip 'quoting with adverbs'
{ # qq:w,Interpolating quote constructor with words adverb 
  # L<S02/Literals/"Split result on words (no quote protection)">
    my (@q1, @q2) = ();
    @q1 = qq:w/$foo "gorch $bar"/;
    @q2 = qq:words/$foo "gorch $bar"/;

    is(+@q1, 3, 'qq:w// correct number of elements');
    is(+@q2, 3, 'qq:words correct number of elements');

    is(~@q1, 'FOO "gorch BAR"', "explicit quote word interpolates");
    is(~@q2, 'FOO "gorch BAR"', "long form output is the same as the short");
};

#?rakudo skip 'quoting with adverbs'
{ # qq:ww, interpolating L<S02/Literals/double angles do interpolate>
  # L<S02/Literals/"implicit split" "shell-like fashion">
    my (@q1, @q2, @q3, @q4) = ();
    @q1 = qq:ww/$foo "gorch $bar"/;
    @q2 = «$foo "gorch $bar"»; # french
    @q3 = <<$foo "gorch $bar">>; # texas
    @q4 = qq:quotewords/$foo "gorch $bar"/; # long

    is(+@q1, 2, 'qq:ww// correct number of elements');
    is(+@q2, 2, 'french double angle');
    is(+@q3, 2, 'texas double angle');
    is(+@q4, 2, 'long form');

    is(~@q1, 'FOO gorch BAR', "explicit quote word interpolates");
    is(~@q2, 'FOO gorch BAR', "output is the same as french");

    # L<S02/Literals/"the built-in «...» quoter automatically does interpolation equivalent to qq:ww/.../">
    is(~@q3, 'FOO gorch BAR', ", texas quotes");
    is(~@q4, 'FOO gorch BAR', ", and long form");
};

#?rakudo skip '«...»'
{
    #L<S02/Literals/"relationship" "single quotes" "double angles">
    # Pugs was having trouble with this.  Fixed in r12785.
    my ($x, $y) = <a b>;
    ok(«$x $y» === <a b>, "«$x $y» interpolation works correctly");
};


# L<S02/Literals/respects quotes in a shell-like fashion>
#?rakudo skip '«...»'
{ # qw, interpolating, shell quoting
    my (@q1, @q2) = ();
    my $gorch = "foo bar";

    @q1 = «$foo $gorch $bar»;
    is(+@q1, 4, "4 elements in unquoted «» list");
    is(@q1[2], "bar", '$gorch was exploded');
    is(@q1[3], "BAR", '$bar was interpolated');

    @q2 = «$foo "$gorch" '$bar'»;
    is(+@q2, 3, "3 elementes in sub quoted «» list");
    is(@q2[1], $gorch, 'second element is both parts of $gorch, interpolated');
    is(@q2[2], '$bar', 'single quoted $bar was not interpolated');
};

# L<S02/Literals/Heredocs are no longer written>
#?rakudo skip 'quoting with adverbs'
{ # qq:to
    my @q = ();

    @q = qq:to/FOO/;
blah
$bar
blah
$foo
FOO

    is(+@q, 1, "q:to// is singular");
    is(@q[0], "blah\nBAR\nblah\nFOO\n", "here doc interpolated");
};

# L<S02/Literals/Heredocs allow optional whitespace>
#?rakudo skip 'quoting with adverbs'
{ # q:to indented
    my @q = ();

    @q = q:to/FOO/;
        blah blah
        $foo
        FOO

    is(+@q, 1, "q:to// is singular, also when indented");
    is(@q[0], "blah blah\n\$foo\n", "indentation stripped");
};

#?rakudo skip 'heredocs'
{ # q:heredoc backslash bug
        my @q = q:heredoc/FOO/
yoink\n
splort\\n
FOO
;
        is(+@q, 1, "q:heredoc// is singular");
        is(@q[0], "yoink\\n\nsplort\\n\n", "backslashes");
}

#?rakudo skip 'Quoting with Q'
{ # Q L<S02/Literals/No escapes at all>
    my @q = ();
    
    my $backslash = "\\";

    @q = (Q/foo\\bar$foo/);

    is(+@q, 1, "Q// is singular");
    is(@q[0], "foo\\\\bar\$foo", "special chars are meaningless"); # double quoting is to be more explicit
};

# L<S02/Literals/"Pair" notation is also recognized inside>
#?rakudo skip '<< :pair(1) >>'
{
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

#?rakudo skip  'escape sequences'
{ # weird char escape sequences
    is("\c97", "a", '\c97 is "a"');
    is("\c102oo", "foo", '\c102 is "f", works next to other letters');
    is("\c123", chr 123, '"\cXXX" and chr XXX are equivalent');
    is("\c[12]3", chr(12) ~ "3", '\c[12]3 is the same as chr(12) concatenated with "3"');
    is("\c[12] 3", chr(12) ~ " 3", 'respects spaces when interpolating a space character');
    is("\c[13,10]", chr(13) ~ chr(10), 'allows multiple chars');

    is("\x41", "A", 'hex interpolation - \x41 is "A"');
    is("\o101", "A", 'octal interpolation - \o101 is also "A"' );

    is("\c@", "\0", 'Unicode code point "@" converts correctly to "\0"');
    is("\cA", chr 1, 'Unicode "A" is #1!');
    is("\cZ", chr 26, 'Unicode "Z" is chr 26 (or \c26)');
}

#?rakudo skip 'nested quoting'
{ # simple test for nested-bracket quoting, per S02
    my $hi = q<<hi>>;
    is($hi, "hi", 'q<<hi>> is "hi"');
}


# L<S02/Literals/"for user-defined quotes">
# q:to
#?rakudo skip 'quoting with adverbs'
{
    my $t;
    $t = q:to /STREAM/;
Hello, World
STREAM

    is $t, "Hello, World\n", "Testing for q:to operator.";

$t = q:to /结束/;
Hello, World
结束

    is $t, "Hello, World\n", "Testing for q:to operator. (utf8)";
}

# Q
#?rakudo skip 'Q'
{
    my $s1 = "hello";
    my $t1 = Q /$s1, world/;
    is $t1, '$s1, world', "Testing for Q operator.";

    my $s2 = "你好";
    my $t2 = Q /$s2, 世界/;
    is $t2, '$s2, 世界', "Testing for Q operator. (utf8)";
}

# q:b
#?rakudo skip 'quoting adverbs'
{
    my $t = q:b /\n\n\n/;
    is $t, "\n\n\n", "Testing for q:b operator.";
    is q:b'\n\n', "\n\n", "Testing q:b'\\n'";
    ok qb"\n\t".chars == 2, 'qb';
    is Qb{a\nb},  "a\nb", 'Qb';
    is Q:b{a\nb}, "a\nb", 'Q:b';
    is Qs:b{\n},  "\n",   'Qs:b';
}

# q:x
#?rakudo skip 'quoting adverbs'
{
    is q:x/echo hello/, "hello\n", "Testing for q:x operator.";
}
# utf8
#?rakudo skip 'quoting adverbs'
{
    # 一 means "One" in Chinese.
    is q:x/echo 一/, "一\n", "Testing for q:x operator. (utf8)";
}

# L<S02/Literals/"Interpolate % vars">
# q:h
#?rakudo skip 'quoting adverbs'
{
    # Pugs can't parse q:h currently.
    my %t = (a => "perl", b => "rocks");
    my $s;
    $s = q:h /%t<>/;
    is $s, ~%t, "Testing for q:h operator.";
}

# q:f
#?rakudo skip 'quoting adverbs'
{
    sub f { "hello" };
    my $t = q:f /&f(), world/;
    is $t, f() ~ ", world", "Testing for q:f operator.";

    sub f_utf8 { "你好" };
    $t = q:f /&f_utf8(), 世界/;
    is $t, f_utf8() ~ ", 世界", "Testing for q:f operator. (utf8)";
}

# q:c
#?rakudo skip 'quoting adverbs'
{
    sub f { "hello" };
    my $t = q:c /{f}, world/;
    is $t, f() ~ ", world", "Testing for q:c operator.";
}

# q:a
#?rakudo skip 'quoting adverbs'
{
    my @t = qw/a b c/;
    my $s = q:a /@t[]/;
    is $s, ~@t, "Testing for q:a operator.";
}

# q:s
#?rakudo skip 'quoting adverbs'
{
    my $s = "someone is laughing";
    my $t = q:s /$s/;
    is $t, $s, "Testing for q:s operator.";

    my $s = "有人在笑";
    my $t = q:s /$s/;
    is $t, $s, "Testing for q:s operator. (utf8)";
}

# multiple quoting modes
#?rakudo skip 'quoting adverbs'
{
    my $s = 'string';
    my @a = <arr1 arr2>;
    my %h = (foo => 'bar');
    is(q:s:a'$s@a[]%h', $s ~ @a ~ '%h', 'multiple modifiers interpolate only what is expected');
}

# shorthands:
#?rakudo skip 'quoting adverbs'
{
    my $alpha = 'foo';
    my $beta  = 'bar';
    my @delta = <baz qux>;
    my %gamma = (abc => 123);
    sub zeta {42};

    is(qw[a b], <a b>, 'qw');
    is(qww[$alpha $beta], <foo bar>, 'qww');
    is(qq[$alpha $beta], 'foo bar', 'qq');
    is(Qs[$alpha @delta[] %gamma<>], 'foo @delta %gamma', 'Qs');
    is(Qa[$alpha @delta[] %gamma<>], '$alpha ' ~ @delta ~ ' %gamma', 'Qa');
    is(Qh[$alpha @delta[] %gamma<>], '$alpha @delta ' ~ %gamma, 'Qh');
    is(Qf[$alpha &zeta()], '$alpha 42', 'Qf');
    is(Qb[$alpha\t$beta], '$alpha	$beta', 'Qb');
    is(Qc[{1+1}], 2, 'Qc');
}

# L<S02/Literals/All other quoting forms (including standard single quotes)>
{
    is('test\\', "test\\", "backslashes at end of single quoted string");
}
