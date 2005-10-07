#!/usr/bin/perl -w

use strict;
use warnings;
use File::Copy qw(copy);
use File::Path qw(mkpath rmtree);

our %BuildPrefs;
use Config;
use FindBin;
BEGIN { chdir $FindBin::RealBin; chdir '..'; };
use lib 'inc';
use PugsBuild::Config;

help() if ($ARGV[0] || '--help') =~ /^--?h(?:elp)?/i;
build(classify_options(@ARGV));
exit 0;

sub help {
    print <<".";
$0 - build a pugs executable

This script calls GHC to build a pugs exectuable, optionally inlining
precompiled modules in a second pass.

Primary configuration settings are read from the file `config.yml` in
the build root. You may override these settings using the PUGS_BUILD_OPTS
environment variable.

Current settings:
.
    print PugsBuild::Config->pretty_print;

    exit 0;
}

sub build {
    my($opts) = @_;
    my $thispugs = { @{ $opts->{GEN_PRELUDE} } }->{'--pugs'} or # laugh at me now.
        die "$0: no pugs passed in _+GEN_PRELUDE segment";
    
    print "Build configuration:\n" . PugsBuild::Config->pretty_print;

    my ($version, $ghc, $ghc_version, $setup, @args) = @{$opts->{GHC}};
    write_buildinfo($version, $ghc_version, @args);
    system($setup, 'configure');

    # if Prelude.pm wasn't changed, don't bother to recompile Run.hs.
    if (PugsBuild::Config->lookup('precompile_prelude')) {
        my $pm = "src/perl6/Prelude.pm";
        my $ppc_hs = "src/Pugs/PreludePC.hs";
        my $ppc_null = "src/Pugs/PreludePC.hs-null";
        if (-e $ppc_hs and -s $ppc_hs > -s $ppc_null and -M $ppc_hs < -M $pm) {
            build_lib($version, $ghc, $setup);
            build_exe($version, $ghc, $ghc_version, @args);
            return;
        }
    }

    run($^X, qw<util/gen_prelude.pl -v --touch --null --output src/Pugs/PreludePC.hs>);
    build_lib($version, $ghc, $setup);
    build_exe($version, $ghc, $ghc_version, @args);

    if (PugsBuild::Config->lookup('precompile_prelude')) {
        run($^X, qw<util/gen_prelude.pl -v -i src/perl6/Prelude.pm>,
                (map { ('-i' => $_) } @{ PugsBuild::Config->lookup('precompile_modules') }),
                '-p', $thispugs, qw<--touch --output src/Pugs/PreludePC.hs>);
        build_lib($version, $ghc, $setup);
        build_exe($version, $ghc, $ghc_version, @args);
    }
}

sub build_lib {
    my $version = shift;
    my $ghc     = shift;
    my $setup   = shift;

    my $ar = $Config{full_ar};
    my $a_file = "dist/build/libHSPugs-$version.a";

    unlink $a_file;
    system($setup, 'build'); # , '--verbose';
    die "Build failed: $?" unless -e $a_file;

    if (!$ar) {
        $ar = $ghc;
        $ar =~ s{(.*)ghc}{$1ar};
    }

    # XXX - work around Cabal bug
    copy(
        "dist/build/src/Syck_stub.o",
        "dist/build/src/Data/Yaml/Syck_stub.o"
    );
    copy(
        "dist/build/src/src/Data/Yaml/Syck_stub.o",
        "dist/build/src/Data/Yaml/Syck_stub.o"
    );

    system(
        $ar,
        r => $a_file, "dist/build/src/Data/Yaml/Syck_stub.o"
    );
}

sub build_exe {
    my $version     = shift;
    my $ghc         = shift;
    my $ghc_version = shift;
    #my @o = qw( src/pcre/pcre.o src/syck/bytecode.o src/syck/emitter.o src/syck/gram.o src/syck/handler.o src/syck/implicit.o src/syck/node.o src/syck/syck.o src/syck/syck_st.o src/syck/token.o src/syck/yaml2byte.o src/cbits/fpstring.o );
    #push @o, 'src/UnicodeC.o' if grep /WITH_UNICODEC/, @_;
    #system $ghc, '--make', @_, @o, '-o' => 'pugs', 'src/Main.hs';
    my @pkgs = qw(-package stm -package network -package mtl -package template-haskell -package base);
    if ($^O =~ /(?:MSWin32|mingw|msys|cygwin)/) {
        push @pkgs, -package => 'Win32' unless $ghc_version =~ /^6.4(?:.0)$/;
    }
    else {
        push @pkgs, -package => 'unix';
    }
    push @pkgs, -package => 'readline' if grep /^readline$/, @_;
    print "*** Building: ", join(' ', $ghc, @pkgs, qw(-idist/build -Ldist/build -idist/build/src -Ldist/build/src -o pugs src/Main.hs), "-lHSPugs-$version"), $/;
    system $ghc, @pkgs, qw(-idist/build -Ldist/build -idist/build/src -Ldist/build/src -o pugs src/Main.hs), "-lHSPugs-$version";
    die "Build failed: $?" unless -e "pugs$Config{_exe}";
}

sub write_buildinfo { 
    my $version = shift;
    my $ghc_version = shift;

    open IN, "< Pugs.cabal.in" or die $!;
    open OUT, "> Pugs.cabal" or die $!;

    my $depends = 'unix -any';
    if ($^O =~ /(?:MSWin32|mingw|msys|cygwin)/) {
        $depends = 'Win32 -any';
    }

    if (grep /^readline$/, @_) {
        $depends .= ', readline -any';
    }

    my $unicode_c = '';
    if ($ghc_version =~ /^6\.4(?:\.0)?$/) {
        $unicode_c = 'src/UnicodeC.c';
    }

    while (<IN>) {
        s/__OPTIONS__/@_/;
        s/__VERSION__/$version/;
        s/__DEPENDS__/$depends/;
        s/__UNICODE_C__/$unicode_c/;
        print OUT $_;
    }

    close IN;
    close OUT;
}

sub classify_options {
    my($kind, %opts);
    for (@_) {
        # we can't use +SEGMENT and -SEGMENT since that interferes with GHC.
        $kind = $1,  next if /^_\+(.*)/;        # _+SEGMENT start
        undef $kind, next if $_ eq "_-$kind";   # _-SEGMENT end
        
        s/^__(.*)__$/PugsBuild::Config->lookup($1)/e;
        
        die "don't know where this option belongs: $_" unless $kind;
        push @{ $opts{$kind} }, $_;
    }
    \%opts;
}

sub run {
    print ((join " ", @_) . "\n");
    system @_ and die (sprintf "system: [%s]: $!", join " ", @_);
}

sub copy_all {
    my ($src, $dest) = @_;
    mkpath($dest);
    local *DIR;
    opendir(DIR, $src) or die $!;
    my @nodes = readdir(DIR);
    foreach my $node (sort @nodes) {
        next if $node =~ /^(\.|\.\.|\.svn|src)$/;
        my $src_path = "$src/$node";
        my $dest_path = "$dest/$node";
        if (-f $src_path) {
            copy($src_path, $dest_path);
        }
        if (-d $src_path) {
            copy_all($src_path, $dest_path);
        }
    }
}
