#!/usr/bin/pugs

use v6;
use Test;

=pod

Basic tests of C<< %?CONFIG >>, the equivalent to
C<Config.pm>. Most of this is not yet even decided on,
so all of this test can become obsolete on Larrys whim C<:)>

Currently the test is hardcoded to check for the
following values in C<< %?CONFIG >>:

    archlib
    archname
    bin
    exe_ext
    file_sep
    installarchlib
    installbin
    installprivlib
    installscript
    installsitearch
    installsitebin
    installsitelib
    osname
    pager
    path_sep
    perl_revision
    perl_subversion
    perl_version
    prefix
    privlib
    pugspath
    scriptdir
    sitearch
    sitebin
    sitelib
    pugs_versnum
    pugs_version
    pugs_revision

=cut

my @config = <
    archlib
    archname
    bin
    exe_ext
    file_sep
    installarchlib
    installbin
    installprivlib
    installscript
    installsitearch
    installsitebin
    installsitelib
    osname
    pager
    path_sep
    perl_revision
    perl_subversion
    perl_version
    prefix
    privlib
    pugspath
    scriptdir
    sitearch
    sitebin
    sitelib
    pugs_versnum
    pugs_version
    pugs_revision
>;

plan @config+2;

diag "Running under $*OS";

my ($pugs,$redir) = ("./pugs", ">");
if($*OS eq any <MSWin32 mingw msys cygwin>) {
    $pugs = 'pugs.exe';
};

ok( defined %?CONFIG, '%?CONFIG is defined' );
ok( %?CONFIG.keys() > 0, '%?CONFIG contains keys and values' );
for @config -> $entry {
    # diag $entry;
    ok( defined %?CONFIG<<$entry>>, '%?CONFIG{'~$entry~'} exists');
};
