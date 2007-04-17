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

# you can pre-define HARNESS_PUGS to something else, such as util/limited_pugs
$ENV{HARNESS_PUGS} ||= ($^O =~ /(?:MSWin32|mingw|msys|cygwin)/) ? 'pugs' : './pugs';

$ENV{HARNESS_PERL}  = "$ENV{HARNESS_PUGS} $optional_args";
$ENV{HARNESS_PERL}  = "$^X $FindBin::Bin/../perl5/PIL2JS/pugs-smokejs.pl ./pugs $optional_args"
    if $ENV{PUGS_RUNTIME} and $ENV{PUGS_RUNTIME} eq 'JS';
# XXX: hack to be identified by smokeserv
$ENV{HARNESS_PERL}  = "$^X -I/tmp/JSPERL5 $FindBin::Bin/../perl5/PIL2JS/pugs-smokejs.pl ./pugs $optional_args"
    if $ENV{PUGS_RUNTIME} and $ENV{PUGS_RUNTIME} eq 'JSPERL5';
if ($ENV{PUGS_RUNTIME} and $ENV{PUGS_RUNTIME} eq 'PERL5') {
    $ENV{PERL5LIB} = 'blib6/pugs/perl5/lib:blib6/pugs/perl5/arch';
    $ENV{HARNESS_PERL} = $^X;
#    $ENV{HARNESS_PERL_SWITCHES} = "blib6/pugs/perl5/lib/v6.pm";
}
if ($ENV{PUGS_RUNTIME} and $ENV{PUGS_RUNTIME} eq 'REDSIX') {
    $ENV{HARNESS_PERL}  = "./pugs -Bredsix";
}


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
my $yml_location = $html_location;
$yml_location =~ s/(\.html?(\+)?)?$/'.yml'.($2||'')/e;

# Save backups of prior html and yaml
my @saved_backup;
for my $file ($html_location, $yml_location) {
    next unless -f $file;
    my $newfile = $file;
    $newfile =~ s/[.](html?|yml)/.last.$1/;
    rename $file, $newfile
        or die "Couldn't save backup of $file to $newfile: $!";
    push @saved_backup, [$file, $newfile];
}

push @yaml_harness_args, ('--output-file', $yml_location);
system($^X, qw(-w ./util/yaml_harness.pl),
            @yaml_harness_args) == 0 or die "Could not run yaml harness: $!";
system($^X, qw(-w ./util/testgraph.pl), ('--inlinecss', $yml_location), $html_location) == 0 or die "Could not convert .yml to testgraph: $!";
upload_smoke($html_location, $yml_location);
if ($smoke_upload) {
  if (defined $smoke_upload_script) {
    system($^X => $smoke_upload_script, $html_location, $yml_location) == 0
        or die "Couln't run smoke upload script: $!";
  }
} else {
    print <<EOF;
*** All done! Smoke matrix saved as '$html_location'.
    You may want to submit the report to the public smokeserver:

        $^X $smoke_upload_script $html_location $yml_location

    Or add
        smoke_upload: 1 
    to your config.yml file if you want the reports to be uploaded
    automatically.
EOF

    for my $filepair (@saved_backup) {
        print "\n    Your old $filepair->[0] has been saved to $filepair->[1].\n"
    }
}
sub upload_smoke {
    my ($html, $yml) = @_;
    return unless defined $ENV{PUGS_SMOKE_UPLOAD};
    system("$^X $ENV{PUGS_SMOKE_UPLOAD} $html $yml") == 0 or die "couldn't run user smoke upload command: $!";
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
