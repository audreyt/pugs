# This is a Perl 6 solution to QoTW regular #6, see
# http://perl.plover.com/qotw/r/solution/006.

use v6-alpha;

sub format_number_list(*@input is copy) {
  my @output;
  while @input {
    my $range_start = shift @input;
    my $range_end   = $range_start;

    # check if the numbers go in sequence from here
    $range_end = shift @input while @input and @input[0] == $range_end + 1;

    # ...and add to output accordingly
    if $range_start == $range_end { push @output, $range_start }
    else { push @output, "$range_start-$range_end" }
  }

  return join ", ", @output;
}

say format_number_list(1, 2, 4, 5, 6, 7, 9, 13, 24, 25, 26, 27);
