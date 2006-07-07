use v6;
use Test;
use File::Spec;

plan 3;

use Pod::Event::Parser; pass "(dummy instead of broken use_ok)";
use Pod::Event::Handler::HTML; pass "(dummy instead of broken use_ok)";
try { chdir "ext/Pod-Event-Parser" }; # Hack if we're run from make smoke

my $test_output = "";
parse(catfile('t', 'sample.pod'), pod2html($test_output));
is($test_output, 
'<H1>This is <B>header</B> 1</H1>
<UL>
<LI>This is an <I>item</I></LI>
<P>This is the <B>items</B> body</P>
</UL>
<H2>This is header 2</H2>
<P>This is regular text which wraps <I>up <B>to</B></I> two lines</P>
<PRE>
 This is verbatim text
 which contains some code in it
 for () {
     this is the stuff
 }
</PRE>
<P>This is regular text again</P>
',
'... POD -> to -> HTML worked');
