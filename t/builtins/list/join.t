#!/usr/bin/pugs

use v6;
require Test;

plan 26;

# test all variants of join() 

is(["a", "b", "c"].join("|"), "a|b|c", '[].join("|") works'); # unTODOme

my $joined1 = ("a", "b", "c").join("|");
is($joined1, "a|b|c", '().join("|") works'); # unTODOme

my @list = ("a", "b", "c");

is(@list.join("|"), "a|b|c", '@list.join("|") works'); # unTODOme

my $joined2 = join("|", @list);
is($joined2, "a|b|c", 'join("|", @list) works');

my $joined3 = join("|", "a", "b", "c");
is($joined3, "a|b|c", 'join("|", 1, 2, 3) works');

my $joined4 = join("|", [ "a", "b", "c" ]);
is($joined4, "a|b|c", 'join("|", []) works');

# join() with $sep as a variable

my $sep = ", ";

is(["a", "b", "c"].join($sep), "a, b, c", '[].join($sep) works'); # unTODOme

my $joined1a = ("a", "b", "c").join($sep);
is($joined1a, "a, b, c", '().join($sep) works'); # unTODOme

is(@list.join($sep), "a, b, c", '@list.join($sep) works'); # unTODOme

my $joined2a = join($sep, @list);
is($joined2a, "a, b, c", 'join($sep, @list) works');

my $joined3a = join($sep, "a", "b", "c");
is($joined3a, "a, b, c", 'join($sep, "a", "b", "c") works');

my $joined4a = join($sep, [ "a", "b", "c" ]);
is($joined4a, "a, b, c", 'join($sep, []) works');

# join ... without parens

my $joined2b = join $sep, @list;
is($joined2b, "a, b, c", 'join $sep, @list works');

my $joined2c = join ":", @list;
is($joined2c, "a:b:c", 'join ":", @list works');

my $joined3b = join $sep, "a", "b", "c";
is($joined3b, "a, b, c", 'join $sep, "a", "b", "c" works');

my $joined3c = join ":", "a", "b", "c";
is($joined3c, "a:b:c", 'join(":", "a", "b", "c") works');

my $joined4b = join $sep, [ "a", "b", "c" ];
is($joined4b, "a, b, c", 'join $sep, [] works');

my $joined4c = join ":", [ "a", "b", "c" ];
is($joined4c, "a:b:c", 'join ":", [] works');

# join() with empty string as seperator

is(["a", "b", "c"].join(''), "abc", '[].join("") works'); # unTODOme

my $joined1d = ("a", "b", "c").join('');
is($joined1d, "abc", '().join("") works'); # unTODOme

my @list = ("a", "b", "c");

is(@list.join(''), "abc", '@list.join("") works'); # unTODOme

my $joined2d = join('', @list);
is($joined2d, "abc", 'join("", @list) works');

my $joined3d = join('', "a", "b", "c");
is($joined3d, "abc", 'join("", 1, 2, 3) works');

my $joined4d = join("", [ "a", "b", "c" ]);
is($joined4d, "abc", 'join("", []) works');

# some odd edge cases

my $undefined;
my @odd_list1 = (1, $undefined, 2, $undefined, 3);

my $joined2e = join(':', @odd_list1);
is($joined2e, "1::2::3", 'join(":", @odd_list1) works');

my @odd_list2 = (1, undef, 2, undef, 3);

my $joined2f = join(':', @odd_list2);
is($joined2f, "1::2::3", 'join(":", @odd_list2) works');
