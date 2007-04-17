use v6-alpha;

use Test;
force_todo 6;

=pod

Test that the safemode is really safe.

=cut

sub nonce () { return (".$*PID." ~ int rand 1000) }

my $tmpfile = "temp-test" ~ nonce();
my @tests = (
    # Test that open() doesn't work.
    'my $fh = eval \'open("' ~ $tmpfile ~ '-opened", :w)\'; eval \'close $fh\'',
    { $^a; "$tmpfile-opened" !~~ :e },
    
    # %*ENV, %?CONFIG, and $*OS should be hidden, too.
    'Pugs::Safe::safe_print("[%*ENV{}] [%?CONFIG{}] [$*OS]")',
    { $^a eq "[] [] []" },

    # The filetest operators shouldn't work, either.
    'Pugs::Safe::safe_print(eval("\'.\' ~~ :d").perl)',
    { $^a eq "undef" },

    # Finally, "is unsafe" should cause that sub declarations have no effect
    '
        my $in_blarb;
        sub blarb () is unsafe { $in_blarb++ }
        try { blarb() };
        Pugs::Safe::safe_print($in_blarb ?? "nok" !! "ok");
    ',
    { $^a eq "ok" },

    # Safe Prelude.pm functions should be visible.
    'Pugs::Safe::safe_print(eval(\'&Carp::longmess\') ?? "ok" !! "nok")',
    { $^a eq "ok" },
    # Unsafe Prelude.pm functions should not be visible.
    'Pugs::Safe::safe_print(eval(\'&Pipe::open3\') ?? "nok" !! "ok")',
    { $^a eq "ok" },
);

plan +@tests / 2;
if $*OS eq "browser" {
  skip_rest "Programs running in browsers don't have access to regular IO.";
  exit;
}

diag "Running under $*OS";

my $redir = ">";

if $*OS eq any <MSWin32 mingw msys cygwin> {
  $redir = '>';
};

# Run our pugs childs in safemode
%*ENV<PUGS_SAFEMODE> = "true";

for @tests -> $code_to_run, $condition {
  state $i; $i++;

  {
      my $fh = open("$tmpfile-src", :w);
      say $fh: $code_to_run;
      close $fh;
  }

  my $command = "$*EXECUTABLE_NAME $tmpfile-src $redir $tmpfile-out";
  diag "Code to be run under safemode:\n  $code_to_run";
  diag "Pugs will be started using:\n  $command";
  system $command;

  my $got     = slurp "$tmpfile-out";
  unlink map { "$tmpfile-$_" }, <src out opened>;
  diag "The code wrote to STDOUT:\n  $got";

  ok $condition($got), "safemode works ($i)";
}
