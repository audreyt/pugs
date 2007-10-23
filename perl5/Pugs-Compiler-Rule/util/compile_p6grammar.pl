#!/usr/bin/env perl

use lib 'lib';
use File::Slurp 'slurp';
use Getopt::Std;
use Pugs::Compiler::Grammar;
use Pugs::Runtime::Tracer;

my %opts;
getopts("Ds:", \%opts) or help();
if (defined $opts{s}) {
    $::PCR_SEED = $opts{s};
}

my $infile = shift or help();
my $grammar = slurp($infile);
my $compiler = Pugs::Compiler::Grammar->compile($grammar) or
    die;
if ($compiler) {
    my $perl5 = $compiler->perl5;
    my $localtime = localtime;
    print <<EOC;
# !!! DO NOT EDIT !!!
# This file was generated by Pugs::Compiler::Rule's compile_p6grammar.pl
# script from $infile at $localtime

use strict;
use warnings;

EOC
    if ($opts{D}) {
        #print "use Pugs::Runtime::Tracer;\n";
        $perl5 = expand_tracing_code($perl5);
    }
    print $perl5;
}

sub help {
    die "Usage: $0 [-s seed] [-D] foo.grammar > Foo.pm\n";
}

__END__

=head1 NAME

compile_p6grammar.pl - Compile Perl 6 Grammars to Perl 5 Modules

=head1 SYNOPSIS

    $ util/compile_p6grammar.pl examples/adder.grammar > Adder.pm
    $ perl -MAdder -e 'print Adder->add("3 + 23")->(), "\n"'
    $ cat examples/adder.grammar
      grammar Adder;

      token add {
          (\d+) <?ws>? '+' <?ws>? (\d+) { return $/[0] + $/[1] }
      }
    $

=head1 DESCRIPTION

Used to convert grammars in Perl 6 syntax into Perl 5 modules.

=head1 AUTHORS

The Pugs Team E<lt>perl6-compiler@perl.orgE<gt>.

=head1 SEE ALSO

The Perl 6 Rules Spec: L<http://dev.perl.org/perl6/doc/design/syn/S05.html>

=head1 COPYRIGHT

Copyright 2006, 2007 by Nathan Gray and Agent Zhang.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=head1 SEE ALSO

L<Pugs::Compiler::Grammar>, L<Pugs::Compiler::Rule>,
L<Pugs::Compiler::Regex>,
L<http://perlcabal.org/syn/S05.html>.

=cut

