#!/usr/bin/perl

use strict;
use warnings;
use Shell qw(svn);
use Config;
use File::Spec;
use FindBin;
use lib File::Spec->catdir($FindBin::Bin, "..", "inc");
use PugsBuild::Config;

my $failed = 0;
for (qw/YAML Test::TAP::Model Test::TAP::HTMLMatrix Best/) {
    check_prereq($_) or $failed++;
}

die <<"EOF" if $failed;

You don't seem to have the required modules installed.
Please install them from the CPAN and try again.

This can be accomplished in one go by running:

  cpan Task::Smoke
EOF
#'

#
# run-smoke.pl /some/sandbox/dir /some/www/file.html
#
my $pugs_sandbox    = $ARGV[0] or die "Need pugs sandbox location";
my $html_location   = $ARGV[1] or die "Need HTML output file location";
my $optional_args   = $ARGV[2] || "";

my $smoke_upload     = PugsBuild::Config->lookup('smoke_upload');
my $smoke_upload_script = File::Spec->canonpath('./util/smokeserv/smokeserv-client.pl'); 

chdir($pugs_sandbox) or die "Could change directory: $!";

# '.' needs to be at the front of the path for everything to find the correct
# pugs executable.
$ENV{PATH} = "." . $Config{path_sep} . $ENV{PATH};

$ENV{HARNESS_PERL}  = "./pugs $optional_args";
$ENV{HARNESS_PERL}  = "$^X $FindBin::Bin/../perl5/PIL2JS/pugs-smokejs.pl ./pugs $optional_args"
    if $ENV{PUGS_RUNTIME} and $ENV{PUGS_RUNTIME} eq 'JS';
# XXX: hack to be identified by smokeserv
$ENV{HARNESS_PERL}  = "$^X -I/tmp/JSPERL5 $FindBin::Bin/../perl5/PIL2JS/pugs-smokejs.pl ./pugs $optional_args"
    if $ENV{PUGS_RUNTIME} and $ENV{PUGS_RUNTIME} eq 'JSPERL5';
$ENV{HARNESS_PERL}  = "$^X $FindBin::Bin/../perl5/PIL-Run/pugs-p5.pl"
    if $ENV{PUGS_RUNTIME} and $ENV{PUGS_RUNTIME} eq 'PERL5';

$ENV{PERL6LIB}      = join $Config{path_sep},
        qw<ext/Test/lib blib6/lib>, $ENV{PERL6LIB}||"";

my @yaml_harness_args;
push(@yaml_harness_args,'--concurrent', PugsBuild::Config->lookup('smoke_concurrent') || 1);
push(@yaml_harness_args,'--exclude','Disabled,^ext\b')
    if $ENV{PUGS_SMOKE_EXCLUDE_EXT}
        or ($ENV{PUGS_RUNTIME} and ($ENV{PUGS_RUNTIME} eq 'JS' or
                   $ENV{PUGS_RUNTIME} eq 'PERL5' or $ENV{PUGS_RUNTIME} eq 'JSPERL5'));

sub make { return `$Config{make} @_` };
my $dev_null = File::Spec->devnull;

my $output ;# = svn("up") or die "Could not update pugs tree: $!";
system($^X, qw(-w ./util/yaml_harness.pl),@yaml_harness_args) == 0 or die "Could not run yaml harness: $!";
system($^X, qw(-w ./util/testgraph.pl --inlinecss tests.yml), $html_location) == 0 or die "Could not convert .yml to testgraph: $!";
upload_smoke($html_location);
if ($smoke_upload) {
  if (defined $smoke_upload_script) {
    system("$^X $smoke_upload_script $html_location") == 0
        or die "Couln't run smoke upload script: $!";
  }
} else {
print <<EOF;
*** All done! Smoke matrix saved as '$html_location'.
    You may want to submit the report to the public smokeserver:

        $^X $smoke_upload_script $html_location

    Or add
        smoke_upload: 1 
    to your config.yml file if you want the reports to be uploaded
    automatically.
EOF
}
sub upload_smoke {
    my ($loc) = @_;
    return unless defined $ENV{PUGS_SMOKE_UPLOAD};
    system("$^X $ENV{PUGS_SMOKE_UPLOAD} $loc") == 0 or die "couldn't run user smoke upload command: $!";
}

sub check_prereq {
    my ($mod) = @_;
    (my $file = $mod) =~ s,::,/,g;
    if (eval { require "$file.pm"; 1 }) {
        return 1;
    }
    else {
        warn "$mod - missing dependency\n";
        warn "($@)\n" if $@ and $@ !~ /Can't locate \Q$file\E/;
        return 0;
    }
}
# END
