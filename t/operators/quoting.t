#!/usr/bin/pugs

use v6;
use Test;

plan 68;

my $foo = "FOO";
my $bar = "BAR";

=kwid

Tests quoting constructs as defined in L<S02/Literals>

=todo

* q:t - heredocs
* q:0, q:b, and other interpolation levels
* meaningful quotations (qx, rx, etc)
* review shell quoting semantics of «»
* arrays in «»
* interpolation of scalar, array, hash, function and closure syntaxes
* q : a d verb s // parsing

=cut


{ # backslash interpolation only single quotes L<S02/Literals /:single\s+Interpolate \\\\,/>
	my @q = ();
	eval '@q = (q/$foo $bar/)';
	is(+@q, 1, 'q// is singular');
	is(@q[0], '$foo $bar', 'single quotes are non interpolating');
};

{ # and it's complement ;-)
	my @q = ();
	eval "\@q = '\$foo \$bar'";
	is(+@q, 1, "'' is singular");
	is(@q[0], '$foo $bar', 'and did not interpolate either');
};

{ # non interpolating single quotes with nested parens L<S02/Literals /That is.*?\(\).*?have no special significance/>
	my @q = ();
	eval '@q = (q: (($foo $bar)))';
	is(+@q, 1, 'q: () is singular', :todo);
	is(@q[0], '($foo $bar)', 'and nests parens appropriately', :todo);
};

{ # q() is bad L<S02/Literals /Which is mandatory for parens/>
	my @q = ();
	eval '@q = (q(($foo $bar)))';
	is(+@q, 0, 'nothing in @q, q() is not allowed', :todo);
};

{ # adverb variation L<S02/Literals /:1/>
	my @q = ();
	eval '@q = (q:1/$foo $bar/)';
	is(+@q, 1, "q:1// is singular");
	is(@q[0], '$foo $bar', "and again, non interpolating");
};

{ # nested parens
	my @q = ();
	eval '@q = (q[[$foo $bar]])';
	is(+@q, 1, 'q[] is singular');
	is(@q[0], '[$foo $bar]', 'and nests parens appropriately');
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

{ # adverb variation L<S02/Literals /:2/>
	my @q = ();
	eval '@q = q:2/$foo $bar/';
	is(+@q, 1, "q:2// is singular");
	is(@q[0], "FOO BAR", "blah blah interp");
};

{ # \qq[] constructs interpolate in q[] L<S02/Literals /using the \\qq/>
	my( @q1, @q2, @q3, @q4 ) = ();
	eval '@q1 = q[$foo \\qq[$bar]]';
	is(+@q1, 1, "q[...\\qq[...]...] is singular");
	is(@q1[0], '$foo BAR', "and interpolates correctly");

	eval "\@q2 = '\$foo \\qq[\$bar]'";
	is(+@q2, 1, "'...\\qq[...]...' is singular");
	is(@q2[0], '$foo BAR', "and interpolates correctly");

	eval '@q3 = q[$foo \\q:s{$bar}]';
	is(+@q3, 1, 'q[...\\q:s{...}...] is singular');
	is(@q3[0], '$foo BAR', "and interpolates correctly");

	eval '@q4 = q{$foo \\q/$bar/}';
	is(+@q4, 1, 'q{...\\q/.../...} is singular');
	is(@q4[0], '$foo $bar', "and interpolates correctly");
}

{ # quote with \0 as delimiters L<news:20050101220112.GF25432@plum.flirble.org>
	my @q = ();
	eval "\@q = (q\0foo bar\0)";
	is(+@q, 1, "single quote with \\0 delims are parsed ok");
	is(@q[0], "foo bar", "and return correct value");
};


{ # traditional quote word
	my @q = ();
	eval '@q = (qw/$foo $bar/)';
	is(+@q, 2, "qw// is plural");
	is(@q[0], '$foo', "and non interpolating");
	is(@q[1], '$bar', "...");
};

{ # angle brackets L<S02/Literals /the qw.*?quote operator.*?bracketed form/>
	my @q = ();
	eval '@q = <$foo $bar>';
	is(+@q, 2, "<> behaves the same way");
	is(@q[0], '$foo', 'for interpolation too');
	is(@q[1], '$bar', '...');
};

{ # angle brackets L<S02/Literals /the qw.*?quote operator.*?bracketed form/>
	my @q = ();
	eval '@q = < $foo $bar >';
	is(+@q, 2, "<> behaves the same way, with leading (and trailing) whitespace");
	is(@q[0], '$foo', 'for interpolation too');
	is(@q[1], '$bar', '...');
};

{ # adverb variation
	my @q = ();
	eval '@q = (q:w/$foo $bar/)';
	is(+@q, 2, "q:w// is like <>");
	is(@q[0], '$foo', "...");
	is(@q[1], '$bar', "...");
};

{ # whitespace sep aration does not break quote constructor 
  # L<S02/Literals /Whitespace is allowed between the "q" and its adverb: q :w /..././>
	my @q = ();
	eval '@q = (q :w /$foo $bar/)';
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
  # L<S02/Literals /Split result on words (with quote protection)/>
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
	# L<S02/Literals /the built-in «...» quoter automatically does interpolation equivalent to qq:ww/.../ />;
	is(~@q3, 'FOO gorch BAR', ", texas quotes",:todo<bug>);
	is(~@q4, 'FOO gorch BAR', ", and long form",:todo<bug>);
};

{ # qw, interpolating, shell quoting L<S02/Literals /respects quotes in a shell-like fashion/>
	my (@q1, @q2) = ();
	my $gorch = "foo bar";

	eval '@q1 = «$foo $gorch $bar»';
	is(+@q1, 4, "4 elements in unquoted «» list");
	is(@q1[2], "bar", '$gorch was exploded');
	is(@q1[3], "BAR", '$bar was interpolated');

	eval '@q2 = «$foo "$gorch" \'$bar\'»';
	is(+@q2, 3, "3 elementes in sub quoted «» list", :todo);
	is(@q2[1], $gorch, 'second element is both parts of $gorch, interpolated', :todo);
	is(@q2[2], '$bar', 'single quoted $bar was not interpolated', :todo);
};

{ # qq:t L<S02/Literals /Heredocs are no longer written/>
	my @q = ();

	eval '@q = qq:t/FOO/;
blah
$bar
blah
$foo
FOO
	';

	is(+@q, 1, "q:t// is singular", :todo);
	is(@q[0], "blah\nBAR\nblah\nFOO\n", "here doc interpolated", :todo);
};

{ # q:t indented L<S02/Literals /Here docs allow optional whitespace/>
	my @q = ();

	eval '@q = q:t/FOO/;
		blah blah
		$foo
		FOO
	';

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

{ # q:0 L<S02/Literals /No escapes at all/>
	my @q = ();
	
	my $backslash = "\\";

	eval '@q = (q:0/foo' ~ $backslash ~ $backslash ~ 'bar$foo/)';

	is(+@q, 1, "q:0// is singular");
	is(@q[0], "foo\\\\bar\$foo", "special chars are meaningless"); # double quoting is to be more explicit
};
