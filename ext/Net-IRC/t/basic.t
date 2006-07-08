use v6-alpha;
use Test;
use Net::IRC;

plan 2;

my $bot = new_bot(
  nick     => "blechbot",
  username => "blech",
  ircname  => "Ingo's Bot",
  host     => "localhost",
  port     => 6667,
  autoping => 90,
  live_timeout => 120,
  debug_raw => 0,
);

ok $bot,               "instantiation of a bot 'object' worked";
ok !$bot<connected>(), "calling a method on a bot 'object' worked";
