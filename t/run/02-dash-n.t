use v6-alpha;

use Test;

=pod

Test -n implementation

The -n command line switch mimics the Perl5 -n command line
switch, and wraps the whole script in

  while (=<>) {
    ...
  };

=cut

my @examples = (
  '-n -e .say',
  '-ne .say',
  '-e "" -ne .say',
);

plan +@examples;
if $*OS eq "browser" {
  skip_rest "Programs running in browsers don't have access to regular IO.";
  exit;
}

diag "Running under $*OS";

my ($redir_in, $redir_out) = ("<", ">");

my $str = "
foo
bar
";

sub nonce () { return (".$*PID." ~ int rand 1000) }
my($in_fn, $out_fn) = <temp-ex-input temp-ext-output> >>~<< nonce;
my $h = open("$in_fn", :w);
$h.print($str);
$h.close();

for @examples -> $ex {
  my $command = "$*EXECUTABLE_NAME $ex $redir_in $in_fn $redir_out $out_fn";
  diag $command;
  system $command;

  my $expected = $str;
  my $got      = slurp $out_fn;
  unlink $out_fn;

  is $got, $expected, "-n -e print works like cat";
}

unlink $in_fn;
