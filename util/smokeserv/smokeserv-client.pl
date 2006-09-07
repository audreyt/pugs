#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;
use LWP::UserAgent;

use constant VERSION => 0.4;
sub debug($);

our $compress = sub { return };

GetOptions(
  "smokeserv=s" => \(my $smokeserver = ""),
  "help"        => \&usage,
  "compress|c!" => \(my $compression_wanted = 1),
  "version"     => sub { print "smokeserv-client.pl v" . VERSION . "\n"; exit },
) or usage();
@ARGV >= 1 or usage();

debug "smokeserv-client v" . VERSION . " started.\n";

my @default_smokeserv = ("http://m19s28.vlinux.de/cgi-bin/pugs-smokeserv.pl");
my @smokeserv = $smokeserver ? ($smokeserver) : @default_smokeserv;

setup_compression() if $compression_wanted;

my %request = (upload => 1, version => VERSION, smokes => []);

{
  my ($html, $yml) = @ARGV;
  debug "Reading smoke \"$html\" to upload... ";

  open my $fh, "<", $html or die "Couldn't open \"$html\" for reading: $!\n";
  local $/;
  my $smoke = <$fh>;

  unless($smoke =~ /^<!DOCTYPE html/) {
    debug "doesn't look like a smoke; aborting.\n";
    exit 1;
  }

  $request{smoke} = $compress->($smoke) || $smoke;

  debug "html ok.\n";

  if($yml and open $fh, '<', $yml) {
    $smoke = <$fh>;
    $request{yml} = $compress->($smoke) || $smoke;
  }
}

foreach my $smokeserv (@smokeserv) {
  debug "Sending data to smokeserver \"$smokeserv\"... ";
  my $ua = LWP::UserAgent->new;
  $ua->agent("pugs-smokeserv-client/" . VERSION);
  $ua->env_proxy;

  my $resp = $ua->post($smokeserv => \%request);
  if($resp->is_success) {
    if($resp->content =~ /ok$/) {
      debug "success!\n";
      exit 0;
    } else {
      debug "error: " . $resp->content . "\n";
      exit 1;
    }
  } else {
    debug "error: " . $resp->status_line . "\n";
    exit 1;
  }
}

sub usage { print STDERR <<USAGE; exit }
Usage: $0 [options] -- smoke1.html [smoke1.yml]

Available options:
  --smokeserv=http://path/to/smokeserv.pl
    Sets the path to the smoke server.
  --version
    Outputs the version of this program and exits.
  --help
    Show this help.

Options may be abbreviated to uniqueness.
USAGE

# Nice debugging output.
{
  my $fresh;
  sub debug($) {
    my $msg = shift;

    print STDERR "* " and $fresh++ unless $fresh;
    print STDERR $msg;
    $fresh = 0 if substr($msg, -1) eq "\n";
    1;
  }
}

sub setup_compression {
  eval { require Compress::Bzip2; debug "Bzip2 compression on\n" } and
    return $compress = sub { Compress::Bzip2::memBzip(shift) };
  eval { require Compress::Zlib; debug "Gzip compression on\n" } and
    $compress = sub { Compress::Zlib::memGzip(shift) };
}
