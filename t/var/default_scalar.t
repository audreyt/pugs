use v6-alpha;


use Test;

plan 4;

    my $a := $_; $_ = 30;
    for 1 .. 3 { $a++ }; 
    is $a, 33, 'global $_ increments' ;

if $*OS eq "browser" {
  skip_rest "Programs running in browsers don't have access to regular IO.";
  exit;
}

# work around missing capabilities
# to get the output of 'say' into a test; 
    my $out = open("tmpfile", :w);
    $out.say(3);
    close $out; 
    my$in = open "tmpfile"; 
    my $s = =$in; close $in; 
    unlink "tmpfile";

    is $s,"3", 'and is the default argument for "say"';

#pugs> for .. { say }; 

    my $out = open("tmpfile", :w);
    for 1 { say $out, };
    close $out; 
    my$in = open "tmpfile"; 
    my $s = =$in; close $in;
    unlink "tmpfile";

    isnt $s,"3", 'and global $_ should not be the default topic of "for"'; 
    lives_ok { for 1 .. 3 { $_++ } }, 'default topic is rw by default',:todo<bug>; 
# #*** Error: cannot modify constant item at 1

