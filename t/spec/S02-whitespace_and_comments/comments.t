use v6;

# Test various forms of comments

use Test;

plan 45;

# L<S02/"Whitespace and Comments"/"Embedded comments"
#  "#" plus any bracket>
{

#?rakudo skip 'multiline comments not working'
    ok #[
        Multiline
        comments
        is fine
    ] 1, 'multiline embedded comment with #[]';

#?rakudo skip 'multiline comments not working'
    ok #(
        Parens works also
    ) 1, 'multiline embedded comment with #()';

#?rakudo skip 'multiline comments not working'
    ok eval("2 * 3\n #<<<\n comment>>>"), "multiline comment with <<<";

    my $var = #{ foo bar } 32;
    is $var, 32, 'embedded comment with #{}';

    $var = 3 + #「 this is a comment 」 56;
    is $var, 59, 'embedded comment with LEFT/RIGHT CORNER BRACKET';

#?rakudo skip 'unicode bracket comments not working'
    is 2 #『 blah blah blah 』 * 3, 6, 'embedded comment with LEFT/RIGHT WHITE CORNER BRACKET';

    my @list = 'a'..'c';

#?rakudo skip 'unicode bracket comments not working'
    is @list[ #（注释）2 ], 'c', 'embedded comment with FULLWIDTH LEFT/RIGHT PARENTHESIS';

#?rakudo skip 'unicode bracket comments not working'
    is @list[ 0 #《注释》], 'a', 'embedded comment with LEFT/RIGHT DOUBLE ANGLE BRACKET';

#?rakudo skip 'unicode bracket comments not working'
    is @list[#〈注释〉1], 'b', 'embedded comment with LEFT/RIGHT ANGLE BRACKET';

    # Note that 'LEFT/RIGHT SINGLE QUOTATION MARK' (i.e. ‘’) and
    # LEFT/RIGHT DOUBLE QUOTATION MARK (i.e. “”) are not valid delimiter
    # characters.

    #test some 13 more lucky unicode bracketing pairs
#?rakudo skip 'unicode bracket comments not working'
    is(1 #᚛ pa ᚜ +1, 2, 'embedded comment with #᚛᚜');
#?rakudo skip 'unicode bracket comments not working'
    is(1 #⁅ re ⁆ +2, 3, 'embedded comment with #⁅⁆');
#?rakudo skip 'unicode bracket comments not working'
    is(2 #⁽ ci ⁾ +3, 5, 'embedded comment with #⁽⁾');
#?rakudo skip 'unicode bracket comments not working'
    is(3 #❨ vo ❩ +5, 8, 'embedded comment with #❨ vo ❩');
#?rakudo skip 'unicode bracket comments not working mu'
    is(5 #❮ mu ❯   +8, 13, 'embedded comment with #❮❯');
#?rakudo skip 'unicode bracket comments not working'
    is(8 #❰ xa ❱   +13, 21, 'embedded comment with #❰❱');
#?rakudo skip 'unicode bracket comments not working'
    is(13 #❲ ze ❳   +21, 34, 'embedded comment with #❲❳');
#?rakudo skip 'unicode bracket comments not working'
    is(21 #⟦ bi ⟧   +34, 55, 'embedded comment with #⟦⟧');
#?rakudo skip 'unicode bracket comments not working'
    is(34 #⦅ so ⦆ +55, 89, 'embedded comment with #⦅⦆');
#?rakudo skip 'unicode bracket comments not working'
    is(55 #⦓ pano ⦔   +89, 144, 'embedded comment with #⦓⦔');
#?rakudo skip 'unicode bracket comments not working'
    is(144 #⦕ papa ⦖   +233, 377, 'embedded comment with #⦕⦖');
#?rakudo skip 'unicode bracket comments not working'
    is(377 #『 pare 』   +610, 987, 'embedded comment with #『』');
#?rakudo skip 'unicode bracket comments not working paci'
    is(610 #﴾ paci ﴿   +987, 1597, 'embedded comment with #﴾﴿');
}

# L<S02/"Whitespace and Comments"/"no space" between "#" and bracket>
{

#?rakudo skip 'bad eval caues runtime crash'
    ok !eval("3 * # (invalid comment) 2"), "no space allowed between '#' and '('";
#?rakudo skip 'bad eval caues runtime crash'
    ok !eval("3 * #\t[invalid comment] 2"), "no tab allowed between '#' and '['";
#?rakudo skip 'bad eval caues runtime crash'
    ok !eval("3 * #  \{invalid comment\} 2"), "no spaces allowed between '#' and '\{'";
#?rakudo skip 'bad eval caues runtime crash'
    ok !eval("3 * #\n<invalid comment> 2"), "no spaces allowed between '#' and '<'";

}

# L<S02/"Whitespace and Comments"/"closed by" "same number of"
#   "closing brackets">
{

#?rakudo skip '#<<< >>>'
    ok #<<<
        Or this <also> works...
    >>> 1, '#<<<...>>>';

#?rakudo 2 skip '#((( )))'
    my $var = \#((( comment ))) 12;
    is $var, 12, '#(((...)))';

#?rakudo skip '#<< >>'
    is(5 * #<< < >> 5, 25, '#<< < >>');

#?rakudo skip 'runtime error'
    is(6 * #<< > >> 6, 36, '#<< > >>');
}

# L<S02/"Whitespace and Comments"/"Brackets may be nested">
{
#?rakudo skip 'multiline comments broken'
    is 3, #(
        (Nested parens) works also
    ) 3, 'nested parens #(...(...)...)';

#?rakudo skip 'multiline comments broken'
    is 3, #{
        {Nested braces} works also {}
    } 3, 'nested braces #{...{...}...}';
}

# I am not sure if this is speced somewhere:
# comments can be nested
{
#?rakudo skip 'multiline comments broken'
    is 3, #(
            comment
            #{
              internal comment
            }
            more comment
        ) 3, 'comments can be nested with different brackets';
#?rakudo skip 'multiline comments broken'
    is 3, #(
            comment
            #(
                internal comment
            )
            more
            ) 3, 'comments can be nested with same brackets';

    # TODO:
    # ok eval(" #{ comment }") failes with an error as it tries to execute
    # comment() before seeing that I meant #{ comment within this string.

#?pugs todo 
#?rakudo skip 'runtime eval error'
    ok eval(" #<<\n comment\n # >>\n >> 3"), 
        'single line comment cannot correctly nested within multiline', :todo<bug>;
}

# L<S02/"Whitespace and Comments"/"Counting of nested brackets"
#   "applies only to" "pairs of brackets of the same length">
{
#?rakudo skip 'nested brackets in embedded comment'
    is -1 #<<<
        Even <this> <<< also >>> works...
    >>>, -1, 'nested brackets in embedded comment';

#?rakudo skip 'embedded comments with nested/unmatched bracket chars'
    is 'cat', #{{
        This comment contains unmatched } and { { { {   (ignored)
        Plus a nested {{ ... }} pair                    (counted)
    }} 'cat', 'embedded comments with nested/unmatched bracket chars';
}

# L<S02/"Literals"/"# at beginning of line is illegal">
{
#?rakudo skip 'runtime eval error'
    ok !eval(" #<this is invalid"),
        'embedded comment not on the left margin';

#?rakudo skip 'runtime eval error'
    ok !eval("2 * 3\n#<\n comment>"), "multiline comment starting on newline is invalid";
}

# L<S02/Whitespace and Comments/"comment may not contain an unspace">
{
    my $a;
#?rakudo skip 'runtime eval error'
    ok !eval '$a = #\  (comment) 32', "comments can't contain unspace";
    is $a, undef, '$a remains undef';
}

# L<S02/Whitespace and Comments/"# may not be used as" 
#   delimiter quoting>
{
    my $a;
#?rakudo skip 'runtime eval error'
    ok eval '$a = q{ 32 }', 'sanity check';
    is $a, ' 32 ', 'sanity check';

    $a = undef;
#?rakudo skip 'runtime eval error'
    ok !eval '$a = q# 32 #;', 'misuse of # as quote delimiters';
    is $a, undef, "``#'' can't be used as quote delimiters";
}

# L<S02/"Whitespace and Comments"/POD sections may be>
=begin oppsFIXME
{
#?rakudo skip 'pod section without cut not working'
# needs to be wrapped in eval so it can be properly isolated
    my $a = eval q{
        my $var = 1;

=begin comment

This is a comment without
a "=cut".

=end comment

        "bar";
    };
    is $a, 'bar', '=begin comment without =cut works';
}

# L<S02/Whitespace and Comments/"single paragraph comments"
#   =for comment>

{
    is eval(q{
        my $var = 1;

=for comment TimToady is here!

        32;
    }), 32, '=for comment works';
}

{
    is eval(q{
        my $var = 1;

=for comment TimToady and audreyt
are both here, yay!

        17;
    }), 17, '=for comment works';
}

=end oppsFIXME
