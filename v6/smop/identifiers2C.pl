#!/usr/bin/perl

use strict;
use warnings;

open my $file, '<', 'include/smop_identifiers.h' or die $!;
open my $decl, '>', 'src/idconst_decl_all.h' or die $!;
open my $init, '>', 'src/idconst_init_all.c' or die $!;


my $count = 0;
my $rest = '';
while (<$file>) {
    chomp;
    next unless /^extern SMOP__Object\* (\S+);.+\/\*\s\"(.+)\"\s\*\//;
    print {$decl} "SMOP__Object* $1;\n";
    print {$init} "$1 = SMOP__NATIVE__idconst_create_nolist( \"$2\\0\" );\n";
    $rest .= "constlist[$count] = $1;\n";
    $count++;
}

print {$init} "constlist_size = $count;\n";
print {$init} "constlist = calloc(constlist_size,sizeof(SMOP__Object*));\n";
print {$init} "assert(constlist);\n";
print {$init} $rest;

close $file;
close $decl;
close $init;
