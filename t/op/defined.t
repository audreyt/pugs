#!/usr/bin/pugs

use v6;
require Test;

plan 12;

ok(!defined(undef), 'undef is not defined');

ok(defined(1),   'numeric literal 1 is defined');
ok(defined(""),  'empty string is defined');
ok(defined("a"), '"a" is defined');
ok(defined(0),   'numeric literal 0 is defined');

my $foo;
ok(!defined($foo), 'unassigned variable $foo is undefined');

$foo = 1;
ok(defined($foo), 'variable $foo is now defined (as numeric literal 1)');

$foo = "";
ok(defined(""), 'variable $foo is now defined (as a empty string)');

$foo = undef;
ok(!defined($foo), 'variable $foo is now undefined again');

$foo = "a";
ok(defined($foo), 'variable $foo is now defined (as string "a")');

$foo = 0;
ok(defined($foo), 'variable $foo is now defined (as numeric literal 0)');

undef $foo;
todo_ok(!defined($foo), 'undef $foo works');
