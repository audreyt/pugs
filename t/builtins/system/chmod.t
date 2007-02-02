use v6-alpha;
use Test;

# L<S16/"Filehandles, files, and directories"/"chmod">

=kwid

chmod - the unix chmod command, changing the rights on a file

Proposed behaviour
LIST = chmod MODE, LIST
Given a list of files and directories change the rights on them.
MODE should be an octet representing or a string like similar to what can be used in
     the same UNIX program:
     one or more of the letters ugoa, one of the symbols +-= and one or more of the letters rwxXstugo.
     
return list should be the list of files that were successfully changed
in scalar context it should be the number of files successfully changed

While some of the modes are UNIX specific, it would be nice to find similar
  modes in other operating system and do the right thing there too.


We really need the stat() function in order to test this.

=cut

plan 19;

if $*OS eq "browser" {
  skip_rest "Programs running in browsers don't have access to regular IO.";
  exit;
}

if $*OS eq any <MSWin32 mingw msys cygwin> {
    skip_rest "file tests not fully available on win32";
    exit;
};


{
    my $file = create_temporary_file;
    my @result = chmod 0o000, $file;
    is +@result, 1, "One file successfully changed";
    is @result[0], $file, "name of the file returned", :todo;
    if ($*EUID) {
        ok $file~~:!r, "not readable after 0";
        ok $file~~:!w, "not writabel after 0";
        ok $file~~:!x, "not executable after 0";
    }
    else {
        skip 3, "~~:r ~~:w ~~:x can accidentally work with root permission";
    }
    remove_file($file);
}


{
    my $file = create_temporary_file;
    my @result = chmod 0o700, $file;
    is +@result, 1, "One file successfully changed";
    is @result[0], $file, "name of the file returned", :todo;

    ok $file~~:r, "readable after 700";
    ok $file~~:w, "writabel after 700";
    ok $file~~:x, "executable after 700";
    remove_file($file);
}


{
    my $file = create_temporary_file;
    my @result = chmod 0o777, $file;
    is +@result, 1, "One file successfully changed";
    is @result[0], $file, "name of the file returned", :todo;

    ok $file~~:r, "readable after 777";
    ok $file~~:w, "writable after 777";
    ok $file~~:x, "executable after 777";
    remove_file($file);
}

sub create_temporary_file {
    my $time = time;
    my $file = "temp_$time";
    my $fh = open $file, :w err die "Could not create $file";
    diag "Using file $file";
    return $file;
}
sub remove_file ($file) {
    unlink $file;
    ok($file~~:!e, "Test file was successfully removed");
}

ok(try { "nonesuch"~~:!e }, "~~:!e syntax works");


