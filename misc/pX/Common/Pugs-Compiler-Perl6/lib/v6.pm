package v6;

# invokes the Perl6-to-Perl5 compiler and creates a .pmc file

# Command line:
#   perl v6.pm -e "some perl 6 code"

# Script or module:
#   use v6-pugs;
#   "hello, world".say;

use strict;
use warnings;
use Module::Compile-base;
use File::Basename;
use Pugs::Runtime::Perl6;

my $bin;
BEGIN { $bin = ((dirname(__FILE__) || '.') . "/..") };
use lib (
    "$bin/lib",
    "$bin/../Pugs-Compiler-Rule/lib",
);

sub pmc_can_output { 1 }

sub pmc_compile {
    my ($class, $source) = @_;

    my $file = (caller(4))[1];
    if (defined $file and $file !~ /\.pm$/i) {
        # Do the freshness check ourselves
        my $pmc = $file.'c';
        my $pmc_is_uptodate = (-s $pmc and (-M $pmc <= -M $file));
        if ($pmc_is_uptodate) {
            local $@; do $pmc; die $@ if $@; exit 0;
        }
    }

    require Pugs::Compiler::Perl6;
    require Perl::Tidy;

    my $p6 = Pugs::Compiler::Perl6->compile( $source );
    my $perl5 = $p6->{perl5};

    # $perl5 =~ s/do\{(.*)\}/$1/s;
    $perl5 = 
        "use Pugs::Runtime::Perl6;\n" . 
        "use strict;\n" . 
        $perl5 . "\n";

    my $perl5_tidy;
    {
    local @ARGV = ();  # "You may not specify any filenames ... - Perl::Tidy.pm
    Perl::Tidy::perltidy( source => \$perl5, destination => \$perl5_tidy );
    }

    return $perl5_tidy;
}

if (@ARGV and !caller) {
    # We are the main program here
    my ($compile_only, $code);

    if ($ARGV[0] eq '--compile-only') {
        shift(@ARGV);
        $compile_only++;
    }

    shift(@ARGV) if $ARGV[0] =~ /^--pugs/;
    shift(@ARGV) if $ARGV[0] =~ /^-Bperl5$/i;
    splice(@ARGV, 0, 2) if $ARGV[0] =~ /^-B$/;

    if (@ARGV and $ARGV[0] =~ s/^-e//) {
        $code = (length($ARGV[0]) ? $ARGV[0] : $ARGV[1]);
    }
    else {
        local $/;
        $code = <>;
    }

    if ($compile_only) {
        print __PACKAGE__->pmc_compile($code);
    }
    else {
        local $@;
        eval __PACKAGE__->pmc_compile($code);
        die $@ if $@;
        exit 0;
    }
}

1;
