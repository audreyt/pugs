use v6;
use Test;

plan 4;

#L<S02/Literals/"Characters indexed by hex numbers">
#?rakudo skip "parse error"
#?DOES 4
{
    my %unicode = (
	    'a'  => "\x61",
	    'æ'  => "\xE6",
	    '喃' => "\x5583",
	    '𨮁' => "\x28B81",
    );

    for %unicode.kv -> $literal, $codepoint {
	    is(
		    $codepoint,
		    $literal,
		    'Does a character codepoint (\x..) evaluate to the same thing as its literal?'
	    );
    }
}

