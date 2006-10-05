#!/usr/bin/perl -w

use strict;
use warnings;
use Cwd qw(cwd);
use File::Copy qw(copy);
use File::Path qw(mkpath rmtree);
use File::Find qw(find);
use File::Basename qw(dirname);
use List::Util qw(max min);

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

my $run_setup;
my $want_profiling = 0;
my $AR_EXE;

sub build {
    my($opts) = @_;
    my $thispugs = { @{ $opts->{GEN_PRELUDE} } }->{'--pugs'} or # laugh at me now.
        die "$0: no pugs passed in _+GEN_PRELUDE segment";
    
    print "Build configuration:\n" . PugsBuild::Config->pretty_print;

    my ($version, $ghc, $ghc_pkg, $ghc_version, $setup, @args) = @{$opts->{GHC}};

    $want_profiling = grep { /^-prof$/ } @args; 
    @args = grep { !/^-prof$/ } @args; 

    # Set heap options via environment here; Win32 needs it instead
    # of setting on GHC flags line. 
    my @rts_args;
    foreach my $arg (@args) {
        $_ = $arg;
        push @rts_args, $_ if s/^\+RTS$// .. s/^-RTS$//;
    }
    $ENV{GHCRTS} = join(' ', ($ENV{GHCRTS} ? $ENV{GHC_RTS} : ()), @rts_args);

    if ($Config{osname} eq 'cygwin') {
        my $cygwin_path = `cygpath -w /`;
        my $cygpath = sub {
            my $path = shift;
            #warn "<> processing $path...\n";
            my $retval = `cygpath -w $path`;
            chomp $retval;
            $retval =~ s{\\}{/}g;
            #warn "<> Now it is $retval...\n";
            return $retval;
        };

        #unshift @args, '-optc-ID:\ghc\ghc-6.4.2\include\mingw', '-optc-ID:\ghc\ghc-6.4.2\gcc-lib\include', '-optc-I/usr/include', '-optc-I/usr/include/cygwin', '-D__CYGWIN__',
        unshift @args, '-I/usr/lib/perl5/5.8/cygwin/CORE',
            '-optc-ID:\ghc\ghc-6.4.2\include\mingw',
            '-optc-I/usr/include',
            '-optl-I/usr/include/cygwin';
        for my $arg (@args) {
            $arg =~ s{(-optc-[IL]|-optl|-optl-L|-I|-L)(/\S+)}{$1 . $cygpath->($2)}eg;
            #if ($arg =~ m{D:/cygwin/usr/include}i) {
            #    $arg = '-optc-ID:\ghc\ghc-6.4.2\include\mingw';
            #}
        }

        #push @args, '-optc-I$cywin_path/lib/perl5/5.8/cygwin/CORE',
        #    '-optl-L$cygwin_path/lib/perl5/5.8/cygwin/CORE';
        #warn "\n\n [248] !!!\n\n @args \n\n !!!!\n\n";
    }

    write_buildinfo($version, $ghc, $ghc_pkg, $ghc_version, @args);

    my $pwd = cwd();

    print "*** Building dependencies.  Please wait...\n\n";

    # Instead of --user, use our own package-conf storage position.

    my $runcompiler = File::Spec->rel2abs("$pwd/util/runcompiler$Config{_exe}");
    my $prefix      = File::Spec->rel2abs("$pwd/third-party/installed");
    my $hc_pkg      = File::Spec->rel2abs("$pwd/util/ghc-pkg-wrapper$Config{_exe}");

    if ($Config{osname} eq 'cygwin') {
        # NB.  We're exploiting for's aliasing of variables.
        foreach my $path ($runcompiler, $prefix, $hc_pkg) {
            $path =~ s{^/cygdrive/(\w)/}{$1:/};
        }
    }

    mkdir $prefix unless -d $prefix;

    # On Win32, a very broken heuristics in Cabal forced us to fake a
    # gcc-lib\ld.exe under pugs path.
    my ($ghc_inst_path, $ghc_bin_path, $hsc2hs);
    if ($^O eq 'MSWin32') {
        foreach my $args (@{$opts->{SETUP}}) {
            $args =~ /^--with-hsc2hs=((.*[\\\/]).*)/ or next;
            $hsc2hs = $1;
            $ghc_inst_path = $ghc_bin_path = $2;
            $ghc_inst_path =~ s{[/\\]bin[/\\]?$}{};
            $ENV{PATH} = "$ENV{PATH};$ghc_inst_path;$ghc_bin_path";

            if (!-e "gcc-lib/ld.exe" and -e "$ghc_inst_path/gcc-lib/ld.exe") {
                mkdir "gcc-lib";
                copy("$ghc_inst_path/gcc-lib/ld.exe" => "gcc-lib/ld.exe");
            }
        }
        die "Cannot obtain gcc-lib/ld.exe" unless -e "gcc-lib/ld.exe";
        warn "GHC installation path: $ghc_inst_path\n";
        warn "GHC bin path: $ghc_bin_path\n";
        warn "Runcompile: $runcompiler\n";
    }
    else {
        foreach my $args (@{$opts->{SETUP}}) {
            $args =~ /^--with-hsc2hs=((.*[\\\/]).*)/ or next;
            $hsc2hs = $1;
            $ghc_bin_path = $2;
        }
    }

    $hsc2hs ||= $ENV{HSC2HS};
    $AR_EXE = $Config{full_ar} || File::Spec->catfile($ghc_bin_path, "ar$Config{_exe}");

    my @configure_args = (
        ($want_profiling ?  '--enable-library-profiling' : ()),
        '--with-compiler=' . $runcompiler,
        '--with-hc-pkg='   . $hc_pkg,
        '--with-hsc2hs='   . $hsc2hs,
        '--prefix='        . $prefix
    );

    # Judy library
    chdir "third-party/judy/Judy-1.0.3";
    copy('src/Judy.h', '../../HsJudy');

    if ($^O eq 'MSWin32') {
        chdir 'src';
        $ENV{CC} = "$ghc_inst_path\\gcc";
        $ENV{COPT} = "-I$ghc_inst_path\\include\\mingw -I$ghc_inst_path\\gcc-lib\\include " .
            "-B$ghc_inst_path\\gcc-lib";
        warn "\nCC = $ENV{CC}\nCOPT = $ENV{COPT}\n";
        system("nmake /F Makefile.win32 /NOLOGO");
        chdir '..';
    } else {
        #if (!-e "src/obj/.libs/libJudy.a") {
            my $make = $Config{make};

            # Judy at this moment wants GNU make.
            $make = 'gmake' unless `$make --version` =~ /GNU/;
            
            system("./configure") unless -e "src/Makefile";
            #system("$make clean");
            chdir 'src';
            system("$make");
            chdir '..';
            #mkdir("../../installed") if !-d "../../installed";
        #}
        #copy('src/obj/.libs/libJudy.a', '../../installed') unless -e '../../installed/libJudy.a';
        #copy('src/obj/.libs/libJudy.a', '../../HsJudy') unless -e '../../HsJudy/libJudy.a';
    }

    chdir "../../..";

    foreach my $module (qw< filepath fps HsSyck HsJudy >) {
        if ( my ($archive_dir) = (
                glob("third-party/installed/*/$module-*"),
                glob("third-party/installed/*/pugs-$module-*"),
            )) {
            my $_a = ($want_profiling ? '_p.a' : '.a');
            my $oldest_a_file = max(
                map {-M $_} (
                    glob("$archive_dir/*$_a"),
                    glob("$archive_dir/*/*$_a"),
                    glob("$archive_dir/*/*/*$_a"),
                )
            );

            my $newest_hs_file;
            my $wanted = sub {
                return unless /\.hsc?$/ or /\.cabal$/;
                $newest_hs_file = -M $_ if !$newest_hs_file or -M $_ < $newest_hs_file;
            };
            find $wanted, "third-party/$module";

            if ($newest_hs_file and $oldest_a_file and $newest_hs_file >= $oldest_a_file) {
                # We are safe - no rebuild needed
                print "*** Skipping building the '$module' dependency.\n\n";
                next;
            }
        }

        chdir "third-party/$module";

        warn join ' ', ("../../Setup$Config{_exe}", 'configure', @configure_args), $/;
        if (-e '.setup-config') {
            system("../../Setup$Config{_exe}", 'configure', @configure_args);
            system("../../Setup$Config{_exe}", 'unregister');
            system("../../Setup$Config{_exe}", 'clean');
	}

        system("../../Setup$Config{_exe}", 'configure', @configure_args);

        print "*** Building the '$module' dependency.  Please wait...\n\n";

        system("../../Setup$Config{_exe}", 'build');
        system("../../Setup$Config{_exe}", 'install');
        chdir $pwd;

        my ($archive_dir) = (
            glob("third-party/installed/*/pugs-$module-*"),
            glob("third-party/installed/*/$module-*"),
            glob("third-party/installed/pugs-$module-*"),
            glob("third-party/installed/$module-*"),
        ) or die "Installation failed for $module";

        foreach my $a_file (
            glob("$archive_dir/*.a"),
            glob("$archive_dir/*/*.a"),
            glob("$archive_dir/*/*/*.a"),
        ) {
            system($AR_EXE, s => $a_file) unless $^O eq 'MSWin32';
        }
    }


    # Embedding Judy object files in HsJudy
    my ($archive_dir) = (
        glob("third-party/installed/*/pugs-HsJudy-*"),
        glob("third-party/installed/*/HsJudy-*"),
        glob("third-party/installed/pugs-HsJudy-*"),
        glob("third-party/installed/HsJudy-*"),
    );
    my @archive_files = (
        glob("$archive_dir/*.a"),
        glob("$archive_dir/*/*.a"),
        glob("$archive_dir/*/*/*.a"),
    );
    
    my @o_files = map { glob("third-party/judy/Judy-1.0.3/src/$_/*.o"), }
                        qw( Judy1 JudyHS JudyCommon JudyL JudySL );

    print "Embedding @o_files into @archive_files\n";
    system($AR_EXE, "-r", $_, @o_files) for @archive_files;
  
    if ($Config{ranlib} ne ':') {
        system(split(/ /,$Config{ranlib}), $_) for @archive_files;
    }


    print "*** Finished building dependencies.\n\n";

    $run_setup = sub { system($setup, @_) };
    $run_setup->('configure', @configure_args, grep { !/^--.*=$/ } @{$opts->{SETUP}});

    build_lib($version, $ghc, @args);

    $run_setup->('install');

    if ($Config{ranlib} ne ':') {
        system(split(/ /,$Config{ranlib}), $_)
            for glob("third-party/installed/lib/Pugs-$version/*.a");
    }

    build_exe($version, $runcompiler, $ghc_version, @args);

    if ($want_profiling) {
        $want_profiling = 0;
        build_exe($version, $runcompiler, $ghc_version, @args);
    }

    my $pm = "src/perl6/Prelude.pm";
    my $ppc_hs = "src/Pugs/Prelude.hs";
    my $ppc_yml = "blib6/lib/Prelude.pm.yml";

    if ((!-s $ppc_yml) or -M $ppc_yml > -M $ppc_hs) {
        # can't assume blib6/lib exists: the user may be running
        # `make unoptimised` which doesn't create it.
        mkpath(dirname($ppc_yml));
        
        run($^X, qw<util/gen_prelude.pl -v -i src/perl6/Prelude.pm>,
                (map { ('-i' => $_) } @{ PugsBuild::Config->lookup('precompile_modules') }),
                '-p', $thispugs, '--output', $ppc_yml);
    }
}

sub gzip_file {
    my ($in, $out) = @_;
    require Compress::Zlib;
    open my $ifh, "<", $in  or die "open: $in: $!";
    open my $ofh, ">", $out or die "open: $out: $!";
    binmode $ofh;
    my $gz = Compress::Zlib::gzopen($ofh, "wb") or
            die "gzopen: $Compress::Zlib::gzerrno";
    while (<$ifh>) {
        $gz->gzwrite($_)    or die "gzwrite: $Compress::Zlib::gzerrno";
    }
    $gz->gzclose;
    unlink $in;
    1;
}

sub build_lib {
    my $version = shift;
    my $ghc     = shift;

    my @a_file = File::Spec->rel2abs("dist/build/libHSPugs-$version.a");
    push @a_file, File::Spec->rel2abs("dist/build/libHSPugs-${version}_p.a") if $want_profiling;

    # Add GHC to PATH
    local $ENV{PATH} = dirname($ghc) . $Config{path_sep} . $ENV{PATH};
 
    mkdir "dist/build" unless -d "dist/build";

    # Remove all -boot files since GHC 6.4 doesn't track them.
    # This is not needed for GHC 6.5 which doesn't produce them anyway.
    my $wanted = sub {
        return unless $_ =~ /-boot$/;
        unlink $_;
    };
    find $wanted, "dist/build";

    unlink $_ for @a_file;
    $run_setup->('build');
    (-e or die "Build failed: $?") for @a_file;

    my $fixup = sub {
        my $module = shift; # eg. "Data.Yaml.Syck"
        my $pathname = $module;
        $pathname =~ s!\.!/!g;
        $pathname .= '_stub.o';
        my $basename = $pathname;
        $basename =~ s!.*/!!;

        # XXX - work around Cabal bug --
        # we have to locate "Syck_stub.o" and copy it into
        # dist/build/src/Data/Yaml/.
        my @candidates;
        my $target = File::Spec->canonpath(
            File::Spec->catfile(qw< dist build src >, $pathname)
        );
        my $wanted = sub {
            return unless $_ eq $basename;
            push @candidates, $File::Find::name;
        };
        find $wanted, "dist";

        if (@candidates > 1) {
            # This is harmless -- so we don't do anything.
            # warn "*** Found more than one '$basename' -- using the first one. \n";
        }
        elsif (@candidates == 0) {
            warn "*** Wasn't able to find '$basename' (this may be a problem)...\n";
            return;
        }

        unless( File::Spec->canonpath($candidates[0]) eq $target ) {
            mkpath(($target =~ m!(.*[/\\])!)[0]); # create dir for target
            copy($candidates[0] => $target)
                or die "Copy '$candidates[0]' => '$target' failed: $!";
        }

        for (@a_file) {
            print "==> $AR_EXE r $_ $target\n";
            system($AR_EXE, r => $_, $target);
        }
    };

    $fixup->('Pugs.Embed.Perl5') if grep /^-DPUGS_HAVE_PERL5$/, @_;
    $fixup->('Pugs.Embed.Parrot') if grep /^-DPUGS_HAVE_PARROT$/, @_;

    foreach my $a_ext (grep { /\.a$/ and !/^-/ } @_) {
        # Do some very sneaky things -- linking other .a with us!
        my $basename = $a_ext;
        $basename =~ s!.*/!!;
        my $dir = "dist/tmp-$basename";
        mkdir $dir;
        chdir $dir;
        system($AR_EXE, x => $a_ext);
        for (@a_file) {
            print "==> $AR_EXE r $_ @{[glob('*')]}\n";
            system($AR_EXE, r => $_, glob("*"));
        }
        unlink(glob("*"));
        chdir '..';
        chdir '..';
        rmdir $dir;
    }

    # Run ranlib.
    if ($Config{ranlib} ne ':') {
        system(split(/ /,$Config{ranlib}), $_) for @a_file;
    }
}

sub build_exe {
    my $version     = shift;
    my $ghc         = shift;
    my $ghc_version = shift;
    #my @o = qw( src/pcre/pcre.o src/syck/bytecode.o src/syck/emitter.o src/syck/gram.o src/syck/handler.o src/syck/implicit.o src/syck/node.o src/syck/syck.o src/syck/syck_st.o src/syck/token.o src/syck/yaml2byte.o src/cbits/fpstring.o );
    #push @o, 'src/UnicodeC.o' if grep /WITH_UNICODEC/, @_;
    #system $ghc, '--make', @_, @o, '-o' => 'pugs', 'src/Main.hs';
    my @pkgs = qw(-hide-all-packages -package stm -package network -package mtl -package template-haskell -package base -package pugs-fps -package pugs-HsSyck -package HsJudy );
    if ($^O =~ /(?:MSWin32|mingw|msys|cygwin)/) {
        push @pkgs, -package => 'Win32' unless $ghc_version =~ /^6.4(?:.0)?$/;
    }
    else {
        push @pkgs, -package => 'unix';
    }
    push @pkgs, -package => 'readline' if grep /^-DPUGS_HAVE_READLINE$/, @_;
    push @pkgs, -package => 'plugins', -package => 'haskell-src' if grep /^-DPUGS_HAVE_HSPLUGINS$/, @_;
    my @libs = "-lHSPugs-$version" . ($want_profiling ? '_p' : '');
    push @libs, grep /^-opt/, @_;
    push @libs, grep /^-[lL]/, @_;
    push @libs, grep /\.(?:a|o(?:bj)?|\Q$Config{so}\E)$/, @_;
    push @libs, grep /^-auto/, @_;

    # XXX - Hack to work around Cabal's semibroken profiling lib support!
    my $out = "pugs$Config{_exe}";

    if ($want_profiling) {
        $out = "pugs-prof$Config{_exe}";
        push @libs, '-prof';
        push @pkgs, glob('third-party/HsSyck/dist/build/syck/*.o'), qw( dist/build/src/pcre/pcre.o third-party/HsJudy/dist/build/Judy/Private_hsc.o )
    }
    else {
        push @libs, grep /^-threaded/, @_;
    }

    push @pkgs, "-package" => "Pugs"; #-$version";

    @_ = ('--make', @pkgs, qw(-optl-Lthird-party/installed -o ), $out, qw( src/Main.hs ), @libs);
    #@_ = (@pkgs, qw(-idist/build -Ldist/build -idist/build/src -Ldist/build/src -o pugs src/Main.hs), @libs);
    print "*** Building: ", join(' ', $ghc, @_), $/;
    system $ghc, @_;

    die "Build failed: $?" unless -e $out;
}

sub write_buildinfo { 
    my $version = shift;
    my $ghc = shift;
    my $ghc_pkg = shift;
    my $ghc_version = shift;

    open IN, "< Pugs.cabal.in" or die $!;
    open OUT, "> Pugs.cabal" or die $!;

    my $depends = '';
    if ($^O =~ /(?:MSWin32|mingw|msys|cygwin)/) {
        $depends = ', Win32 -any' unless $ghc_version =~ /^6.4(?:.0)?$/;
    }
    else {
        $depends = ', unix -any';
    }

    if (grep /^-DPUGS_HAVE_HSPLUGINS$/, @_) {
        $depends .= ', plugins -any, haskell-src -any';
    }

    if (grep /^-DPUGS_HAVE_READLINE$/, @_) {
        $depends .= ', readline -any';
    }

    my $perl5_c = '';
    if (grep /^-DPUGS_HAVE_PERL5$/, @_) {
        $perl5_c = 'src/perl5/p5embed.c';
    }

    my $parrot_c = '';
    if (grep /^-DPUGS_HAVE_PARROT$/, @_) {
        $parrot_c = 'src/pge/parrotembed.c';
    }

    # Remove -Wl flags in Perl5 embedding.
    @_ = grep { !/^-W/ } @_;

    my @include_dirs = grep { -d $_ }
            map File::Spec->canonpath(substr($_, 2)),
            grep /^-I/, @_;
    my @lib_dirs = grep { -d $_ }
            map File::Spec->canonpath(substr($_, 2)),
            grep /^-L/, @_;
    my @libs = map substr($_, 2), grep /^-l/, @_;
    #push @libs, grep /\.(?:a|o(?:bj)?)$/, @_;

    my $has_new_cabal = (`$ghc_pkg describe Cabal` =~ /version: 1\.[1-9]/i);

    while (<IN>) {
        # Adjust the dependency line based on Cabal version
        if ($has_new_cabal) {
            s/hs-source-dir/hs-source-dirs/;
        }
        else {
            s/pugs-fps -any, pugs-HsSyck -any, HsJudy -any, //;
        }
        s/__OPTIONS__/@_/;
        s/__VERSION__/$version/;
        s/__DEPENDS__/$depends/;
        s/__PERL5_C__/$perl5_c/;
        s/__PARROT_C__/$parrot_c/;
        s/__INCLUDE_DIRS__/@include_dirs/;
        s/__LIBS__/@libs/;
        s/__LIB_DIRS__/@lib_dirs/;
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
