use v6-pugs;

use Test;

plan 3;

=pod

Some edge and error cases for I/O

=cut

# deal with non-existant files

if $*OS eq "browser" {
  skip_rest "Programs running in browsers don't have access to regular IO.";
  exit;
}

skip 1, "open('nonexisting') => undef is waiting on 'use fatal'";
if 0 {
    ok(!defined(open("file_which_does_not_exist")), 'open() on non-existant file returns undef');
}

open("create_this_file", :w);
ok(-e 'create_this_file', 'writing to a non-existant file creates it');
unlink('create_this_file');

open("create_this_file2", :w);
ok(-e 'create_this_file2', 'appending to a non-existant file creates it');
unlink('create_this_file2');
