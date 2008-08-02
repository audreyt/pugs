use v6;

use Test;

=begin pod

Test that the C<--help> command in its various incantations
works.

=end pod

my @examples = any <-h --help>;
@examples = map -> Junction $_ { $_.values }, 
            map -> Junction $_ { $_, "-w $_", "$_ -w", "-w $_ -w" },
            @examples;

plan +@examples;
if $*OS eq "browser" {
  skip_rest "Programs running in browsers don't have access to regular IO.";
  exit;
}

diag "Running under $*OS";

my $redir = ">";

if $*OS eq any <MSWin32 mingw msys cygwin> {
  $redir = '>';
};

sub nonce () { return (".{$*PID}." ~ (1..1000).pick) }

for @examples -> $ex {
  my $out_fn = "temp-ex-output" ~ nonce;
  my $command = "$*EXECUTABLE_NAME $ex $redir $out_fn";
  diag $command;
  system $command;

  my $got      = slurp $out_fn;
  unlink $out_fn;

  like( $got, rx:Perl5/^Usage/, "'$ex' displays help");
}
