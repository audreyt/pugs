use v6-alpha;

use Test;

# $failed is set to 0 (actually to undef) at compiletime.
my $failed;
# At run time, if we ever reach runtime, $failed is set to 1.
$failed = 1;

# When we end, we check if $failed is still 0. If yes, we've never reached runtime.
END {
  is $failed, undef,
      'exit() works in CHECK {} - $fail not yet initialized at END time';
}

CHECK {
  # Output the TAP header...
  plan 2;
  is $failed, undef, '$failed not yet initialized in CHECK {}';
  # ...and exit, implicitly calling END.
  exit;
}

# This file was testing that exit does not trigger END at CHECK time.
# However, the spec did not say anything on this subject, and Perl 5
# does call END blocks upon exit in CHECK.  Hence I've preserved the
# original test below but now it tests for the perl5-compatible behaviour.
#   -- audreyt 20061006

=begin END

use v6-alpha;

use Test;

# $failed is set to 0 (actually to undef) at compiletime.
my $failed;
# At run time, if we ever reach runtime, $failed is set to 1.
$failed = 1;

# When we end, we check if $failed is still 0. If yes, we've never reached runtime.
END {
  ok 0, 'END {...} should not be invoked';
}

CHECK {
  # Output the TAP header...
  plan 1;
  is $failed, undef, 'exit() works in CHECK {}';
  # ...and exit, which does _not_ call END.
  exit;
}
