use v6-alpha;

use Test;

plan 4;

if $*OS eq "browser" {
  skip_rest "Programs running in browsers don't have access to regular IO.";
  exit;
}

unless %*ENV<PUGS_TESTS_ALLOW_NETWORK> {
  skip_rest "Won't test &connect as environment variable \"PUGS_TESTS_ALLOW_NETWORK\" is not true.";
  exit;
}

{
  my $fh = connect "google.com", 80;

  my $nl = chr(13) ~ chr(10);
  $fh.print("GET / HTTP/1.0{$nl}Host: google.de{$nl}User-Agent: pugs/connect.t{$nl}Connection: close$nl$nl");
  $fh.flush();

  ok index($fh.readline, "HTTP/") > -1, "connect('google.de', 80) works";
}

{
  dies_ok { connect "localhost", 70000 }, "&connect fails when it can't connect";
}

skip_rest("waiting on 'use fatal'"); exit;

{
  # no fatal;
  lives_ok { connect "localhost", 70000 },
    "&connect does not die when it can't connect";

  ok !connect("localhost", 70000),
    "&connect returns a false value when it can't connect";
}
