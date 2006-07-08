use v6-alpha;

use Test;

=kwid

I/O tests

=cut

plan 4;

if $*OS eq "browser" {
  skip_rest "Programs running in browsers don't have access to regular IO.";
  exit;
}

my $filename = 'tempfile';

# Test is continued from io_finalized_part1.t
# Should see "Hello World" but with bug it is undef

my $fh = open($filename);
isa_ok($fh, 'IO');
my $line = readline($fh);
is($line, "Hello World", 'finalize without explicit filehandle close worked');

#now be sure to delete the file as well

ok($fh.close, 'file closed okay');
ok(?unlink($filename), 'file has been removed');
