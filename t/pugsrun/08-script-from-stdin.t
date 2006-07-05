use v6-pugs;

use Test;

=pod

Test evaluation a script read from STDIN, as
indicated by the C<-> switch.

=cut

my @examples = map -> Junction $_ { $_.values }, (
   any('say qq.Hello Pugs.',
       'say @*ARGS',
   )
);

plan +@examples;
if $*OS eq "browser" {
  skip_rest "Programs running in browsers don't have access to regular IO.";
  exit;
}

diag "Running under $*OS";

my ($pugs,$redir,$echo) = ("./pugs", ">", "echo");

if($*OS eq any <MSWin32 mingw msys cygwin>) {
  $pugs = 'pugs.exe';
};

sub nonce () { return (".$*PID." ~ (int rand 1000) ~ ".tmp") }
my $tempfile = "temp-ex-output" ~ nonce;
for @examples -> $ex {
  my $command = qq($echo $ex | $pugs - "Hello Pugs" $redir $tempfile);
  diag $command;
  system $command;

  my $expected = "Hello Pugs\n";
  my $got      = slurp $tempfile;

  is $got, $expected, "Running a script from stdin works";
  unlink $tempfile;
}
