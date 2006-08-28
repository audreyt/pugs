#!/usr/bin/perl
# "Why is the helper written in Perl 5?" --
# Because we don't want Pugs to start two times (slow), we have to use
# BSD::Resouce, and because we can't yet redirect STDOUT and STDERR.

use 5.008;
use warnings;
use strict;

use BSD::Resource;

my ($code, $tmpfile, $pugs) = @ENV{qw<EVALBOT_CODE EVALBOT_TMPFILE EVALBOT_PUGS>};
die "This program should only be run from evalbot.pl.\n" unless
  defined $code and defined $tmpfile and defined $pugs;

# %ENV does not carry Unicode strings, so we need to do an explicit decode here
utf8::decode($code);

# 5s-7s CPU time, 100 MiB RAM, maximum of 500 bytes output.
setrlimit RLIMIT_CPU,   15, 20                  or die "Couldn't setrlimit: $!\n";
setrlimit RLIMIT_VMEM,  80 * 2**20, 100 * 2**20 or die "Couldn't setrlimit: $!\n";
# PIL2JS writes to a tempfile.
setrlimit RLIMIT_FSIZE, 50000, 50000,           or die "Couldn't setrlimit: $!\n";

unlink $tmpfile or die "Couldn't unlink \"$tmpfile\": $!\n" if -e $tmpfile;
close STDOUT or die "Couldn't close STDOUT: $!\n";
close STDERR or die "Couldn't close STDERR: $!\n";;
open STDOUT, ">>", $tmpfile or
  die "Couldn't redirect STDOUT: $!\n";
open STDERR, ">>", $tmpfile or
  die "Couldn't redirect STDERR: $!\n";

# Set the safemode.
$ENV{PUGS_SAFEMODE} = "true";
$ENV{PUGS_SAFEMODE} eq  "true" or die "Couldn't set \$ENV{PUGS_SAFEMODE}!\n";

my $runcore = "vanilla";
$code =~ s/^\s*:(js|perl5|p5)\s*//i and
  $runcore = { js => "JS", p5 => "Perl5", perl5 => "Perl5" }->{lc $1};

# Run the code.
# We use an anonymous sub instead the more clear "my $ret = eval(...)" so we
# don't pollute the namespace with our variables. The code to eval should have
# exactly the same environment as if typed in the interactive Pugs, i.e.
# tabulaRasa. One exception is made: We add a safe &say.
if($runcore eq "vanilla") {
  # Escape the code.
  $code =~ s/([^A-Za-z_0-9\^])/\\$1/g;

  system $pugs, "-e", '
    my $__evalbot_print = 0;
    sub *print (*@_) {
      unless $__evalbot_print++ { 
        Pugs::Safe::safe_print "OUTPUT[";
      }
      Pugs::Safe::safe_print join "", *@_;
    }
    sub *say (*@_) {
      print *@_, "\n";
    }
    my $_;
    -> $ret {
      if $__evalbot_print { Pugs::Safe::safe_print "] " }
      Pugs::Safe::safe_print ($! ?? "Error: $!" !! $ret) ~ "\n";
    }(Pugs::Internals::eval_perl6("' . $code . '").perl);
  ';
} elsif($runcore eq "JS" or $runcore eq "Perl5") {
  system $pugs, "-B$runcore", "-e", "
    say({$code}());
  ";
}
