use v6;

use Test;

=kwid

Test miscellaneous golfish examples.

=cut

# See L<"http://www.nntp.perl.org/group/perl.perl6.compiler/1135">
# for discussion of:
#    list(=<>).reverse.print
#    [=<>].reverse.print

sub build_file (Str $fname, Str $data) {
    my $fh = open($fname, :w) orelse die("open '$fname' failed: $!");
    $fh.print($data) orelse die("print '$fname' failed: $!");
    $fh.close() orelse die("close '$fname' failed: $!");
}

my @examples = (
    'list(=<>).reverse.map:{.say}',
    '[=<>].reverse.map:{.say}'
);

plan +@examples * 4;
if $*OS eq "browser" {
    skip_rest "Programs running in browsers don't have access to regular IO.";
    exit;
}

diag "Running under $*OS";

# XXX: this $outtmp/slurp will go away when backticks supported.
# XXX: should also check to verify that nothing is written to stderr.
sub nonce () { return (".$*PID." ~ int rand 1000) }
my $outtmp   = 'gtmp'  ~ nonce();
my $tmpprog  = 'gprog' ~ nonce();
my $origfile = 'gorig' ~ nonce();

my $original = "line1\nline2\nline3\n";
my $reversed = "line3\nline2\nline1\n";

unlink($origfile);
build_file($origfile, $original);

for @examples -> $ex {
    unlink($tmpprog);
    build_file($tmpprog, $ex);
    unlink($outtmp);
    my $exists = $outtmp ~~ :f;
    ok( ! $exists, "file '$outtmp' does not exist" );
    my $cmd = "$*EXECUTABLE_NAME $tmpprog $origfile >$outtmp";
    ok( system($cmd), "Run '$cmd'" );
    ok( $outtmp ~~ :f, "file '$outtmp' exists" );
    my $got = slurp($outtmp);
    is( $got, $reversed, "'$ex' works" );
}

END {
    defined($outtmp)   and unlink($outtmp);
    defined($tmpprog)  and unlink($tmpprog);
    defined($origfile) and unlink($origfile);
}
