package main;

use lib '../v6-MiniPerl6/lib5', 'lib5';
use strict;

BEGIN {
    $::_V6_COMPILER_NAME    = 'MiniPerl6';
    $::_V6_COMPILER_VERSION = '0.003';
}

use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;

package Main;
use KindaPerl6::Grammar;

use KindaPerl6::Traverse;
use KindaPerl6::Visitor::LexicalSub;
use KindaPerl6::Visitor::Perl;

use MiniPerl6::Grammar::Regex;
use MiniPerl6::Emitter::Token;

my $source = join('', <> );
my $pos = 0;

say( "# Do not edit this file - Generated by MiniPerl6" );
say( "use v5;" );
say( "use strict;" );
say( "use MiniPerl6::Perl5::Runtime;" );
say( "use MiniPerl6::Perl5::Match;" );

my $visitor = KindaPerl6::Visitor::LexicalSub->new();
my $visitor_perl = KindaPerl6::Visitor::Perl->new();

while ( $pos < length( $source ) ) {
    #say( "Source code:", $source );
    my $p = MiniPerl6::Grammar->comp_unit($source, $pos);
    #say( Main::perl( $$p ) );
    say( join( ";\n", (map { $_->emit( $visitor ) } ($$p) )));
    say( join( ";\n", (map { $_->emit( $visitor_perl ) } ($$p) )));

    print "\nPerl 5 code:\n-------\n";
    # XXX - this redefines the Traverse class
    require MiniPerl6::Perl5::Emitter;
    say( join( ";\n", (map { $_->emit() } ($$p) )));

    #say( $p->to, " -- ", length($source) );
    say( ";" );
    $pos = $p->to;
}

say "1;";
