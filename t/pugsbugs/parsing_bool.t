#!/usr/bin/pugs

use v6;
use Test;

plan 4;

is try { 42 or Bool::False }, 42, "Bool::False as RHS";
is try { Bool::False or 42 }, 42, "Bool::False as LHS", :todo<unspecced>; # XXX

is try { 42 or False }, 42, "False as RHS";
is try { False or 42 }, 42, "False as LHS";
