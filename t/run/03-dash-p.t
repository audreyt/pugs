use v6-alpha;

use Test;

=pod

Test C<-p> implementation

The C<-p> command line switch mimics the Perl5 C<-p> command line
switch, and wraps the whole script in

  while ($_ = =<>) {
    ...         # your script
    say;
  };

=cut

my @examples = (
  '-p',
  '-p "-e1;"',
  '-pe ";"',
  '-pe ""',
  '-p "-e1;" "-e1;"',
  '"-e1;" -p "-e1;"',
);

plan +@examples;
if $*OS eq "browser" {
  skip_rest "Programs running in browsers don't have access to regular IO.";
  exit;
}

diag "Running under $*OS";

my ($pugs,$redir_in,$redir_out) = ("./pugs", "<", ">");

if($*OS eq any <MSWin32 mingw msys cygwin>) {
  $pugs = 'pugs.exe';
};

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
  my $command = "$pugs $ex $redir_in $in_fn $redir_out $out_fn";
  diag $command;
  system $command;

  my $expected = $str;
  my $got      = slurp $out_fn;
  unlink $out_fn;

  is $got, $expected, "$ex works like cat";
}

unlink $in_fn;
