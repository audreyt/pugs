#!/usr/bin/pugs

use v6;
use Test;

plan 8;

# L<S29/"Perl6::Str" /lcfirst/>

is lcfirst("HELLO WORLD"), "hELLO WORLD", "simple";
is lcfirst(""),            "",            "empty string";
is lcfirst("ÜÜÜÜ"),        "üÜÜÜ",        "umlaut";
is lcfirst("ÓÓÓÓŃ"),       "óÓÓÓŃ",       "accented chars";

is "HELLO WORLD".lcfirst,  "hELLO WORLD", "simple.lcfirst";

my $str = "Some String";
is $str.lcfirst,    "some String",          "simple.lcfirst on scalar variable";
is "Other String".lcfirst,  "other String", ".lcfirst on  literal string";

$_ = "HELLO WORLD";
my $x = lcfirst;
is $x, "hELLO WORLD", 'lcfirst uses $_ as default'


