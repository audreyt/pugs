#!perl -w

print "1..9\n";

use URI::Escape;

print "not " unless uri_escape("|abc�") eq "%7Cabc%E5";
print "ok 1\n";

print "not " unless uri_escape("abc", "b-d") eq "a%62%63";
print "ok 2\n";

print "not " if defined(uri_escape(undef));
print "ok 3\n";

print "not " unless uri_unescape("%7Cabc%e5") eq "|abc�";
print "ok 4\n";

print "not " unless join(":", uri_unescape("%40A%42", "CDE", "F%47H")) eq
                    '@AB:CDE:FGH';
print "ok 5\n";


use URI::Escape qw(%escapes);

print "not" unless $escapes{"%"} eq "%25";
print "ok 6\n";


use URI::Escape qw(uri_escape_utf8);

print "not " unless uri_escape_utf8("|abc�") eq "%7Cabc%C3%A5";
print "ok 7\n";

if ($] < 5.008) {
    print "ok 8  # skip perl-5.8 required\n";
    print "ok 9  # skip perl-5.8 required\n";
}
else {
    eval { print uri_escape("abc" . chr(300)) };
    print "not " unless $@ && $@ =~ /^Can\'t escape \\x{012C}, try uri_escape_utf8\(\) instead/;
    print "ok 8\n";

    print "not " unless uri_escape_utf8(chr(0xFFF)) eq "%E0%BF%BF";
    print "ok 9\n";
}


