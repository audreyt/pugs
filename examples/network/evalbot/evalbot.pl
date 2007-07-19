# Modules
BEGIN { print $*ERR: "evalbot6 started. Loading " }
use v6-alpha;
BEGIN { print $*ERR: "Net::IRC... " }
use Net::IRC;
BEGIN { print $*ERR: "File::Spec... " }
use File::Spec::Unix;

# Parse @*ARGS
my $nick;

if @*ARGS[0].substr(0,1) eq '=' {
    my $nickfile = @*ARGS[0].substr(1);
    $nick = { slurp $nickfile };
}
else {
    $nick = { @*ARGS[0] // "evalbot6" };
}

my $server = @*ARGS[1] // "localhost";
my ($host, $port) = split ":", $server;
$port //= 6667;
my $reconn_delay = @*ARGS[2] // 60 * 15;
my @chans = @*ARGS[3...];

debug "Summary of configuration:";
debug "  Will connect as...                  $nick()";
debug "  to...                               $host:$port";
debug "  and will reconnect after            {$reconn_delay}s after a disconnect";
debug "To change any of these parameters, restart $*PROGRAM_NAME";
debug "and supply appropriate arguments:";
debug "  $*PROGRAM_NAME nick host[:port] reconnect_delay";

# Create new bot "object"
my $bot = new_bot(nick => $nick(), host => $host, port => $port, debug_raw => 0);

# prototypes are required now before you can reference the subs
sub on_invite($event) {...};
sub on_privmsg($event) {...};

$bot<add_handler>("INVITE",   &on_invite);
$bot<add_handler>("PRIVMSG",  &on_privmsg);

# Rejoin chans after a reconnect
$bot<add_handler>("loggedin", -> $event {
  $bot<join>($_) for @chans;
});

my $reconnect = 1;
while 1 {
  $bot<connect>();
  $bot<login>();
  $bot<run>();
  if $reconnect { 
    # Reconnect, but not immediately to 1. not suck up all CPU, 2. to not suck
    # up all connections, 3. to not get klined by the IRC server, 4. to not
    # annoy the people on the channels.
    sleep $reconn_delay;
  } else {
    # Else somebody issued a ?quit, so really exit.
    exit;
  }
}

# Join on invite
sub on_invite($event) {
  my ($from, $chan) = $event<from rest>;
  debug "Got an invitation from \"$from\" to join channel \"$chan\".";
  $bot<join>($chan);
}

# Process private messages
sub on_privmsg($event) {
  # Trace the channels we're on, so reconnect can rejoin the channels we were
  # on
  @chans = $bot<channels>() if $bot<channels>();

  given $event<rest> {
    # Logging is important, especially with an *eval*bot.
    debug "Received a ?-request from $event<from>: $event<rest>"
      if substr($event<rest>, 0, 1) eq "?";

    my $update   = { $bot<nick>($nick()) };
    my $reply_to = substr($event<object>, 0, 1) eq "#" ?? $event<object> !! $event<from_nick>;
    my $reply    = { $update(); $bot<privmsg>(to => $reply_to, text => $^text) };

    when rx:P5/^\?help/ {
      $reply("evalbot6 -- ?help | ?quit [reason] | ?raw ... | ?join #chan | ?uptime | ?eval code");
    }

    when rx:P5/^\?quit\s*(.*)$/ {
      if substr($reply_to, 0, 1) eq "#" {
        $reply("you should only do ?quit in a private message so other bots don't quit as well.");
      } else {
        # Don't reconnect.
        $reconnect = 0;
        $bot<quit>($0);
      }
    }

    when rx:P5/^\?raw\s+(.+)$/ {
      $bot<raw>($0);
    }

    when rx:P5/^\?join\s+(.+)$/ {
      if substr($reply_to, 0, 1) eq "#" {
        $reply("you should only do ?join in a private message so other bots don't accidentally come.");
      }
      else {
        $bot<join>($0);
      }
    }

    when rx:P5/^\?uptime$/ {
      my $start_time = INIT { time };
      $reply("Running for {int(time() - $start_time)} seconds.");
    }

    when rx:P5/^\?eval\s*(.+)$/ {
      # Allow ?eval anywhere, as you can make #whateverfoo, invite evalbot
      # to that channel, and abuse the heck out of him.
      $reply(evalhelper $0);
    }

    # This is *not* correct CTCP parsing (the CTCP specification is much more
    # complex than this simple regex), but IRC clients only send this when
    # their users enter /PING bot.
    when rx:P5/^\x01(?:PING )(.*)\x01$/ {
      $bot<notice>(to => $event<from_nick>, text => "\x01(?:PING $0)\x01");
    }
  }
}

sub evalhelper(Str $code) {
  # Find the location of evalhelper-p5.pl.
  state $evalhelper = do {
    print $*ERR: "evalhelper-p5.pl...";
    my @path_parts = splitpath $*PROGRAM_NAME;
    my $progdir = @path_parts[1];
    $progdir = "." if $progdir ~~ rx:Perl5/^\s*$/;
    print $*ERR: "done.\n";
    "$progdir/evalhelper-p5.pl";
  };

  # Prevent possible abuse.
  return "Code to eval exceeds maximum length limit." if bytes($code) > 500;
  return "No code to eval given."
    if bytes($code) == 0 or $code ~~ rx:Perl5/^\s*$/;

  # Set the necessary environment vars for evalhelper-p5.pl.
  my $tmpfile = "temp-evalbot-$*PID";
  %*ENV<EVALBOT_CODE>    = $code;
  %*ENV<EVALBOT_TMPFILE> = $tmpfile;
  %*ENV<EVALBOT_PUGS>    = $*EXECUTABLE_NAME;
  # Eval!
  system "perl", $evalhelper;

  # Read the result, but convert all linebreaks into ␤, so we don't flood
  # the channel.
  my $result = join "␤", split "\n", chomp slurp $tmpfile;
  $result = substr $result, 0, 500;  # max len limit
  unlink $tmpfile;
  return bytes($result) ?? $result !! "(no output)";
}
