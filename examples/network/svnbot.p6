#!/usr/bin/pugs

use v6;
use Net::IRC;

# Parse @*ARGS
my $nick     = @*ARGS[0] // "blechbot";
my $server   = @*ARGS[1] // "localhost";
my $interval = @*ARGS[2] // 300;
my ($host, $port) = split ":", $server;
$port //= 6667;

debug "svnbot started. Summary of configuration:";
debug "  Will connect as...                  $nick";
debug "  to...                               $host:$port";
debug "  checking for new revisions every... $interval seconds.";
debug "To change any of these parameters, restart $*PROGRAM_NAME";
debug "and supply appropriate arguments:";
debug "  $*PROGRAM_NAME nick host[:port] interval";

# Initialize $cur_svnrev. $cur_svnrev contains the last revision seen, and is
# set by svn_headrev() and svn_commits().
my $cur_svnrev;
svn_headrev();

# Create new bot "object"
my $bot = new_bot(nick => $nick, host => $host, port => $port, debug_raw => 0);
$bot<add_handler>("INVITE",  \&on_invite);  # We want to invite our bot
$bot<add_handler>("PRIVMSG", \&on_privmsg); # Remote control
$bot<add_handler>("runloop", \&svn_check);  # Check for new revisions
$bot<connect>();
$bot<login>();
$bot<run>();

# Join all channels we're invited to.
sub on_invite($event) {
  my ($from, $chan) = $event<from rest>;
  debug "Got an invitation from \"$from\" to join channel \"$chan\".";
  $bot<join>($chan);
}

# Remote control
sub on_privmsg($event) {
  given $event<rest> {
    debug "Received a ?-request from $event<from>: $event<rest>"
      if substr($event<rest>, 0, 1) eq "?";

    my $reply_to = substr($event<object>, 0, 1) eq "#" ?? $event<object> :: $event<from_nick>;

    when rx:P5/^\?quit\s*(.*)$/ {
      $bot<quit>($1);
    }

    when rx:P5/^\?raw\s+(.+)$/ {
      $bot<raw>($1);
    }

    when rx:P5/^\?uptime$/ {
      # Note: This is not actually the time we were started, but the time we
      # were compiled (waiting for Pugs to support INIT {}).
      my $start_time = BEGIN { time };
      $bot<notice>(to => $reply_to, text => "Running for {time() - $start_time} seconds.");
    }
  }
}

# This sub checks for new commits.
sub svn_check($event) {
  state $last_check;
  $last_check //= time;  # "state $last_check = 0" doesn't work yet in Pugs.

  # We don't want to flood poor openfoundry.
  if(time() - $last_check >= $interval) {
    debug "Checking for new commits (ignore error messages)... ";
    # svn_commits() sets $cur_svnrev, if needed.
    my $commits = svn_commits();
    debug "done, HEAD revision: $cur_svnrev";
    return unless $commits;

    $last_check = time;
    my @lines   = split("\n", $commits).grep:{ $_ };

    # We inform all channels we've joined of new commits.
    my $chans = join ",", $bot<channels>();
    return unless $chans;

    # Finally, send the announcement.
    $bot<notice>($chans, $_) for @lines;
  }
}

# This queries "svn".
sub svn_commits() {
  # Pipes not yet supported in Pugs.
  my $tempfile = "temp-svnbot";
  END { unlink $tempfile }

  # If this is an incremental update...
  if($cur_svnrev) {
    # ...only query for new commits since we last checked.
    system "svn log -r {$cur_svnrev + 1}:HEAD . > $tempfile";
  } else {
    # Else query only for the newest commit.
    system "svn log -r HEAD . > $tempfile";
  }

  my $commits;
  my $fh = open $tempfile;
  for =$fh {
    given $_ {
      state $cur_entry;
      when rx:P5/^-----+/ {
	# ignore
      }

      when rx:P5/^r(\d+) \| (\w+)/ {
	$cur_entry = "r$1 ($2)";
	# Break the loop if we see $cur_svnrev -- that means, there're no new
	# commits.
	return if $1 == $cur_svnrev;
	$cur_svnrev = $1;
      }

      when rx:P5/\S/ {
	if($cur_entry) {
	  $_ ~~ rx:P5/^(.*)$/;
	  $commits ~= "$cur_entry -- $1\n";
	}
      }
    }
  }

  return $commits;
}

# Just a thin wrapper around svn_commits().
sub svn_headrev() {
  debug "Retrieving current HEAD revision... ";
  svn_commits();
  debug "done.";
}
