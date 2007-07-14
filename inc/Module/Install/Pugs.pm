package Module::Install::Pugs;
use Module::Install::Base; @ISA = qw(Module::Install::Base);
use strict;
use Config;
use File::Spec;
use File::Basename;
use IPC::Open3 'open3';
use Carp;

sub WritePugs {
    my $self = shift;

    my $install_version = shift;
    die "Install version must be 5 or 6 for WritePugs"
      unless $install_version =~ /^[56]$/;

    $self->setup_perl6_install
      if $install_version eq '6';

    $self->set_blib($install_version);

    $self->set_makefile_macros
      if $install_version eq '6';

    $self->WriteAll(@_);

    $self->pugs_fix_makefile;
}

sub set_makefile_macros {
    my $self = shift;

    package MM;
    *init_INST = sub {
        my $hash = $self->{MM};
        my $mm = shift;
        $mm->SUPER::init_INST(@_);
        for (keys %$hash) {
            $mm->{$_} = $hash->{$_};
        }
        return 1;
    }
}

sub base_path {
    my $self = shift;
    $self->{_top}{base};
}

sub is_extension_build {
    my $self = shift;
    not -e $self->base_path . "/lib/Perl6/Pugs.pm";
}

sub set_blib {
    my $self = shift;
    my $perl_version = shift
      or die "Must pass Perl version (5 or 6)";
    my $base = $self->{_top}{base};
    my $blib = ($perl_version == 5 || $self->is_extension_build)
    ? 'blib'
    : $perl_version == 6
      ? 'blib6'
      : die "Perl version '$perl_version' is bad. Must be 5 or 6.";
    my $path = File::Spec->catdir($base, $blib);

    if ( basename($Config{make}, $Config{_exe}) =~ /\bdmake\b/ ) {
        # This is purely for working around sad dmake bug
        # Which parses C:\work\pugs as C : \work\pugs
        $path =~ s{^\w:}{}
    }

    $self->makemaker_args->{INST_LIB} =
      File::Spec->catfile($path, "lib");
    $self->makemaker_args->{INST_ARCHLIB} =
      File::Spec->catfile($path, "arch");
    $self->makemaker_args->{INST_SCRIPT} =
      File::Spec->catfile($path, "script");
    $self->makemaker_args->{INST_BIN} =
      File::Spec->catfile($path, "bin");
    $self->makemaker_args->{INST_MAN1DIR} =
      File::Spec->catfile($path, "man1");
    $self->makemaker_args->{INST_MAN3DIR} =
      File::Spec->catfile($path, "man3");
    $self->makemaker_args->{MAN1PODS} = {} if $perl_version == 6;
    $self->makemaker_args->{MAN3PODS} = {} if $perl_version == 6;
    $self->{MM}{INST_AUTODIR} = '$(INST_LIB)/$(BASEEXT)';
    $self->{MM}{INST_ARCHAUTODIR} = '$(INST_ARCHLIB)/$(FULLEXT)';
}

sub setup_perl6_install {
    my $self = shift;
    my $libs = $self->get_pugs_config;
    $self->makemaker_args(
        INSTALLARCHLIB  => $libs->{archlib},
        INSTALLPRIVLIB  => $libs->{privlib},
        INSTALLSITEARCH => $libs->{sitearch},
        SITEARCHEXP     => $libs->{sitearch},
        INSTALLSITELIB  => $libs->{sitelib},
        SITELIBEXP      => $libs->{sitelib},
        PERLPREFIX      => $libs->{prefix},
        SITEPREFIX      => $libs->{siteprefix},
    );
}

sub pugs_fix_makefile {
    my $self = shift;
    my $base = $self->{_top}{base};
    my $full_pugs = $self->pugs_binary;
    my $full_blib = File::Spec->catfile($base, 'blib6', 'lib');
    open MAKEFILE, '< Makefile' or die $!;
    my $makefile = do { local $/; <MAKEFILE> };
    $full_pugs =~ s{\\}{\\\\}g;
    $full_pugs =~ s{'}{\\'}g;
    $full_blib =~ s{\\}{\\\\}g;
    $full_blib =~ s{'}{\\'}g;

    # XXX - Pugs currently has issues under cygwin, and does not
    # recognise cygwin absolute paths.  This kludge includes the
    # win32ified path as well.

    if ($Config{osname} eq q{cygwin}) {

        # The world's ugliest cygwin variable gives us a hint to the
        # cygwin root.  There is probably a better way to find this.
        # (registry lookup?)

        my $cygroot = $ENV{'!C:'};

        $cygroot =~ s{\\bin$}{};

        $full_blib .= join(q{}, q{:}, $cygroot, $full_blib)
    }

    $makefile =~ s/\b(runtests \@ARGV|test_harness\(\$\(TEST_VERBOSE\), )/ENV->{HARNESS_PERL} = q{$full_pugs}; \@ARGV = sort map glob, \@ARGV; ENV->{PERL6LIB} = q{$full_blib}; $1/;
    $makefile =~ s!("-MExtUtils::Command::MM")!"-I../../inc" "-I../inc" "-Iinc" $1!g;
    $makefile =~ s/\$\(UNINST\)/0/g;

    my $canonical_base = File::Spec->catdir(split(/[\\\/]/, $base));

    $makefile =~ s/^(\t+)cd \.\.$/$1cd $canonical_base/mg;
    close MAKEFILE;
    open MAKEFILE, '> Makefile' or die $!;
    print MAKEFILE $makefile;
    close MAKEFILE;
}

sub get_pugs_config {
    my $self = shift;
    my %args = @_;
    my $base = $self->is_extension_build
    ? '../..'
    : $self->{_top}{base};

    # Escape ' and \ in $base pathname 
    $base =~ s{(['\\])}{\\$1}g;

    eval "use lib '$base/util'; 1" or die $@;
    eval "use PugsConfig; 1" or die $@;
    PugsConfig->get_config( %args );
}

sub pugs_binary {
    my $self = shift;
    my $pugs = "pugs$Config{exe_ext}"; # exe_ext is used in util/PugsConfig.pm
    my $base = $self->{_top}{base};
    "$base/blib/script/$pugs";
}

sub warn_cygwin {
    if ($^O eq 'cygwin') {
        warn << "."
** Note that Cygwin support for pugs still depends on the .msi
   version of GHC and does not provide POSIX features absent
   from an MSYS build. If you wish to fix this please refer to:

   http://www.haskell.org/ghc/docs/5.04/html/building/winbuild.html
   http://www.reed.edu/~carlislp/ghc6-doc/users_guide/x11221.html
.
    }
}

sub assert_ghc {
    my $self = shift;
    my $ghc = $self->can_run($ENV{GHC} || ( 'ghc' . $Config{_exe} ) );

    # This local subroutine returns the version of ghc passed to it.

    my $test_ghc_ver = sub { 
        (`$_[0] --version` =~ /\bversion\s*(\S+)/s)[0]; 
    };

    my ($ghc_version) = $test_ghc_ver->($ghc);

    if (!$ghc_version and (    $Config{osname} eq "cygwin" 
                            or $Config{osname} eq "MSWin32"
                          )
       ) {

        # Looks like we're on a Windows-ish system, without GHC
        # in our path.   Let's hunt around for it.

        my $slash = ( $Config{osname} eq "cygwin" ) ? '/' : '\\';

        my $ghc_root = "$ENV{SYSTEMDRIVE}${slash}ghc";

        warn "*** ghc not found in path.  Looking in $ghc_root\n";

        if (-d $ghc_root) {
            # Looks like we've found a GHC directory.  Find the latest
            # ghc inside that.  Sort versions from highest to lowest.

            my @ghc_choices = sort {
                _normalize_version($b) cmp _normalize_version($a)
            } glob(qq/$ghc_root${slash}ghc-*/);

            GHC_TEST:
            for my $ghc_dir ($ghc_root, sort @ghc_choices) {
                my $ghc_candidate = qq/${ghc_dir}${slash}bin${slash}ghc.exe/;
                if (my $ghc_candidate_version = $test_ghc_ver->($ghc_candidate)) {
                    $ghc = $ghc_candidate;
                    $ghc_version = $ghc_candidate_version;
                }
            }
            warn "*** Using GHC version: $ghc ($ghc_version)\n" if $ghc;
        }
    }

    $ghc_version or die << '.';
*** Cannot find a runnable 'ghc' from path.
*** Please install GHC (6.6.1 or above) from http://haskell.org/ghc/.
.

    my $ghc_ge_661 = (
        ($ghc_version =~ /^(\d)\.(\d+)/ and $1 >= 6 and $2 >= 6)
            and
        $ghc_version ne '6.6'
    );

    unless ($ghc_ge_661) {
        die << ".";
*** Cannot find GHC 6.6.1 or above from path (we have $ghc_version).
*** Please install a newer version from http://haskell.org/ghc/.
.
    }

    my $ghc_flags = "-H0 ";
    $ghc_flags .= " -static ";
    $ghc_flags .= " -Wall " #  -package-name Pugs -odir dist/build/src -hidir dist/build/src "
      unless $self->is_extension_build;
    $ghc_flags .= " -fno-warn-name-shadowing ";
    $ghc_flags .= " -I../../src -i../../src "
      if $self->is_extension_build;
    chomp $ghc_flags;

    return ($ghc, $ghc_version, $ghc_flags, $self->assert_ghc_pkg($ghc));
}

sub has_ghc_package {
    my ($self, $package) = @_;
    my $ghc_pkg = $self->assert_ghc_pkg;
    `$ghc_pkg describe $package` =~ /package-url/;
}

sub _normalize_version {
    my $dir = shift;
    $dir =~ /.*ghc-(.*)$/i or die "Invalid version: $dir";
    my $ver = $1;
    $ver =~ s{(\d+)}{sprintf('%09s', $1)}eg;
    return $ver;
}

=head2 assert_ghc_pkg

Assert that we have F<ghc_pkg> installed.  This caches its result,
any further calls to ghc_pkg This method expects to
be called with a path (relative, absolute, or a command in
C<$ENV{PATH}> that can be used to execute F<ghc>.

=cut

sub assert_ghc_pkg {
    my $self = shift;

    # Return immediately if we've cached this.
    return $self->{ghc_pkg} if $self->{ghc_pkg};

    my $ghc  = shift || $self->{ghc} 
        or croak "assert_ghc_pkg not cached, and called without path to ghc";

    my $ghc_pkg = $ENV{GHC_PKG};

    unless($ghc_pkg) {
        $ghc_pkg = $ghc;
        $ghc_pkg =~ s/\bghc(?=[^\\\/]*$)/ghc-pkg/  # ghc-6.5 => ghc-pkg-6.5
            or $ghc_pkg = 'ghc-pkg'; # fallback if !/^ghc/


        my $ghc_exe = $self->can_run($ghc_pkg) || $self->can_run('ghc-pkg');

        # This above fails under cygwin with a Win32-flavoured ghc-pkg.
        # https://rt.cpan.org/Ticket/Display.html?id=16375 fixes this,
        # but we can't rely upon everyone having it.  As such, we have
        # a very special cygwin work-around.  Ugh!


        if (not $ghc_exe and $Config{osname} eq 'cygwin') {

            warn "*** ghc-pkg not found in path.  Testing $ghc_pkg\n";

            # If the file exists, and it looks like it's in windows
            # land, and it has an executable extension...

            if ( -f $ghc_pkg 
                and $ghc_pkg =~ m{^(?:/cygdrive|[A-Za-z]:)/.*$Config{_exe}$}
            ) {

                # Smells like a Windows executable called from cygwin-land.
                # Keep it.

                $ghc_exe = $ghc_pkg;

            }
        }

        # Our ghc-pkg is whatever executable we've found (which could be
        # undef, if we didn't find anything).

        $ghc_pkg = $ghc_exe;

    }

    die "*** Cannot find ghc-pkg; please set it in your GHC_PKG environment variable.\n"
        unless $ghc_pkg;

    return $self->{ghc_pkg} = $ghc_pkg;
}


sub fixpaths {
    my $self = shift;
    my $text = shift;
    my $sep = File::Spec->catdir('');
    $text =~ s{\b/}{$sep}g;
    $text =~ s/-libpath:"?(.*?)"? //g;

    # Don't let ActivePerl HTMLify our PODs.
    $text =~ s/pure_all\s+htmlifypods/pure_all/g;

    return $text;
}

# assert_ghc makes a call to EU::MM that litters ghc_flags
# with threading options.
sub dethread_flags {
    my (undef, @args) = @_;
    map { $_ = join ' ', grep { !/thread/i && $_ ne '-lc' } split ' ' } @args;
}

1;
