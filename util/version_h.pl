#!/usr/bin/perl -w

# This program determines the revision (number) that has been checked out. It
# then sets the version inside src/Pugs/pugs_version.sh to the revision
# number. Call it like so:
#   util/version_h.pl src/Pugs/pugs_version.h
# It currently works when you have checked out the pugs project with SVN or
# SVK. If the revision number from the checkout is the same as the version
# number found in src/Pugs/pugs_version.h, then it doesn't update the file. If
# it can't determine the pugs revision, then the pugs version is set to 0.

use strict;
use warnings;
use FindBin qw($Bin);

my $version_h = shift || "$Bin/../src/Pugs/pugs_version.h";
my $base = shift || "$Bin/../";
chdir $base;
my $svn_entries = "$base/.svn/entries";

my $old_revision = -1;
open IN, "< $version_h" and do {
  while (<IN>) {
    /#define PUGS_SVN_REVISION (\d+)/ or next;
    $old_revision = $1;
    last;
  }
  close IN;
};

# We can't use SVN keyword expansion (like $Rev$), because
# that is only updated when the file in which the keyword appears
# is modified.
my $revision = 0;

# SVK tries to ask the user questions when it has a STDIN and there is
# no repository.  Since we don't need a STDIN anyway, get rid of it.
close STDIN;

if (-e "$base/MANIFEST") {
    # This is a release -- do nothing!
}
elsif (-d '.svn' and my @svn_info = qx/svn info/ and $? == 0) {
    print "Writing version from `svn info` to $version_h\n";
    if (my ($line) = grep /^Revision:/, @svn_info) {
        ($revision) = $line =~ / (\d+)$/;
    }
}
elsif (-r $svn_entries) {
    print "Writing version from $svn_entries to $version_h\n";
    open FH, $svn_entries or die "Unable to open file ($svn_entries). Aborting. Error returned was: $!";
    while (<FH>) {
        /^ *committed-rev=.(\d+)./ or next;
        $revision = $1;
        last;
    }
    close FH;
}
elsif (my @svk_info = qx/svk info/ and $? == 0) {
    print "Writing version from `svk info` to $version_h\n";
    if (my ($line) = grep /(?:file|svn|https?)\b/, @svk_info) {
        ($revision) = $line =~ / (\d+)$/;
    } elsif (my ($source_line) = grep /^(Copied|Merged) From/, @svk_info) {
        if (my ($source_depot) = $source_line =~ /From: (.*?), Rev\. \d+/) {
            if (my ($path_line) = grep /^Depot Path/, @svk_info ) {
                if (my ($depot_path) = $path_line =~ m!Path: (/[^/]*)! ) {
                    $source_depot = "$depot_path$source_depot";
                }
            }
            if (my @svk_info = qx/svk info $source_depot/ and $? == 0) {
                if (my ($line) = grep /(?:file|svn|https?)\b/, @svk_info) {
                    ($revision) = $line =~ / (\d+)$/;
                }
            }
        }
    }
}
$revision ||= 0;

# WARNING! don't modify the following output, since smartlinks.pl relies on it.
print "Current version is $revision\n";

#utime undef, undef, "$base/src/Pugs/Version.hs";

if ($revision != $old_revision) {
  # As we've closed STDIN (filehandle #0), slot #0 is available for new
  # filehandles again. If we opened a new file ($version_h) without turning
  # "io" warnings off, perl will print "Filehandle STDIN reopened...", because
  # our handle for $version_h got slot #0, like STDIN.
  no warnings "io";
  open OUT, "> $version_h" or die "unable to open file ($version_h) for writing. Aborting. Error was: $!";
  print OUT "#undef PUGS_SVN_REVISION\n";
  print OUT "#define PUGS_SVN_REVISION $revision\n";
  close OUT;

  my $hs_file = "$base/src/Pugs/Version.hs";
  # warn "===> touching $hs_file\n";
  utime undef, undef, $hs_file;

  if ($revision != 0) {
    # rebuild Help.hs to show new revision number
    unlink "$base/dist/build/src/Pugs/Version.hi";
    unlink "$base/dist/build/src/Pugs/Version.o";
    unlink "$base/dist/build/Pugs/Version.hi";
    unlink "$base/dist/build/Pugs/Version.o";
    exit;
  }
} elsif ($revision) {
  print "Not writing $version_h because $old_revision == $revision\n";
}
