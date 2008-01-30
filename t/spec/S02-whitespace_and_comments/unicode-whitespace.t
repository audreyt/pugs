use v6-alpha;

use Test;

plan 52;

# L<S02/"Lexical Conventions"/"Unicode horizontal whitespace">

is(eval('
my	@x	=	<a	b	c>;	sub	y	(@z)	{	@z[1]	};	y(@x)
'), "b", "CHARACTER TABULATION");

is(eval('
my
@x
=
<a
b
c>;
sub
y
(@z)
{
@z[1]
};
y(@x)
'), "b", "LINE FEED (LF)");

is(eval('
my@x=<abc>;suby(@z){@z[1]};y(@x)
'), "b", "LINE TABULATION");

is(eval('
my@x=<abc>;suby(@z){@z[1]};y(@x)
'), "b", "FORM FEED (FF)");

is(eval('
my@x=<abc>;suby(@z){@z[1]};y(@x)
'), "b", "CARRIAGE RETURN (CR)");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "SPACE");

is(eval('
my@x=<abc>;suby(@z){@z[1]};y(@x)
'), "b", "NEXT LINE (NEL)");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "NO-BREAK SPACE");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "OGHAM SPACE MARK");

is(eval('
my᠎@x᠎=᠎<a᠎b᠎c>;᠎sub᠎y᠎(@z)᠎{᠎@z[1]᠎};᠎y(@x)
'), "b", "MONGOLIAN VOWEL SEPARATOR");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "EN QUAD");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "EM QUAD");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "EN SPACE");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "EM SPACE");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "THREE-PER-EM SPACE");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "FOUR-PER-EM SPACE");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "SIX-PER-EM SPACE");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "FIGURE SPACE");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "PUNCTUATION SPACE");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "THIN SPACE");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "HAIR SPACE");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "LINE SEPARATOR");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "PARAGRAPH SEPARATOR");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "NARROW NO-BREAK SPACE");

is(eval('
my @x = <a b c>; sub y (@z) { @z[1] }; y(@x)
'), "b", "MEDIUM MATHEMATICAL SPACE");

is(eval('
my　@x　=　<a　b　c>;　sub　y　(@z)　{　@z[1]　};　y(@x)
'), "b", "IDEOGRAPHIC SPACE");

#Long dot whitespace tests
#These currently get different results than the above

class Str is also {
    method id($x:) { $x }
}

#This makes 'foo.id' and 'foo .id' mean different things
multi foo() { 'a' }
multi foo($x) { $x }

$_ = 'b';

# L<S02/"Lexical Conventions"/"Unicode horizontal whitespace">
is(eval('foo\	.id'), 'a', 'long dot with CHARACTER TABULATION');
is(eval('foo\
.id'), 'a', 'long dot with LINE FEED (LF)');
is(eval('foo\.id'), 'a', 'long dot with LINE TABULATION');
is(eval('foo\.id'), 'a', 'long dot with FORM FEED (FF)');
is(eval('foo\.id'), 'a', 'long dot with CARRIAGE RETURN (CR)');
is(eval('foo\ .id'), 'a', 'long dot with SPACE');
is(eval('foo\.id'), 'a', 'long dot with NEXT LINE (NEL)');
is(eval('foo\ .id'), 'a', 'long dot with NO-BREAK SPACE');
is(eval('foo\ .id'), 'a', 'long dot with OGHAM SPACE MARK');
is(eval('foo\᠎.id'), 'a', 'long dot with MONGOLIAN VOWEL SEPARATOR');
is(eval('foo\ .id'), 'a', 'long dot with EN QUAD');
is(eval('foo\ .id'), 'a', 'long dot with EM QUAD');
is(eval('foo\ .id'), 'a', 'long dot with EN SPACE');
is(eval('foo\ .id'), 'a', 'long dot with EM SPACE');
is(eval('foo\ .id'), 'a', 'long dot with THREE-PER-EM SPACE');
is(eval('foo\ .id'), 'a', 'long dot with FOUR-PER-EM SPACE');
is(eval('foo\ .id'), 'a', 'long dot with SIX-PER-EM SPACE');
is(eval('foo\ .id'), 'a', 'long dot with FIGURE SPACE');
is(eval('foo\ .id'), 'a', 'long dot with PUNCTUATION SPACE');
is(eval('foo\ .id'), 'a', 'long dot with THIN SPACE');
is(eval('foo\ .id'), 'a', 'long dot with HAIR SPACE');
is(eval('foo\ .id'), 'a', 'long dot with LINE SEPARATOR');
is(eval('foo\ .id'), 'a', 'long dot with PARAGRAPH SEPARATOR');
is(eval('foo\ .id'), 'a', 'long dot with NARROW NO-BREAK SPACE');
is(eval('foo\ .id'), 'a', 'long dot with MEDIUM MATHEMATICAL SPACE');
is(eval('foo\　.id'), 'a', 'long dot with IDEOGRAPHIC SPACE');
