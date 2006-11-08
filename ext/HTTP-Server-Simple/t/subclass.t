use v6-alpha;
use Test;

plan 1;

use HTTP::Server::Simple;
class MyServer is HTTP::Server::Simple {
    method handler {
        $.remote.say("stuff");
    }
}

my $s = MyServer.new;
my $thr = async { $s.run; };

# the connect is done in this way since it takes a
# while for the server to accept connections. the
# first one usually does not work so it tries 3 times
my $fh;
my $count = 0;
while !$fh {
    try {
        $fh = connect "localhost", 8080;
        last; # escape the loop on a successful connect
    }
    if ++$count > 3 {
        ok 0, "could not connect to a subclassed server";
        exit;
    }
    sleep 1;
}

my $nl = chr(13) ~ chr(10);
$fh.print("GET / HTTP/1.0{$nl}Host: localhost$nl$nl");
$fh.flush();
ok index($fh.readline, "stuff") > -1, "connected to a subclassed server";

# vi:set ft=perl6:

