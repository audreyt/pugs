use v6-alpha;

# Please remember to update t/examples/examples.t and rename
# examples/output/junctions/all-any if you rename/move this file.

my @new_data   = <100 90 70>;
my @old_data   = <55 35 5>;

my $epsilon = 50;

if ( $epsilon > (all(@new_data) - any(@old_data))  ) {
  say "data is close enough. add it."
} else {
  say "new data is not close enough. DO NOT ADD";
}

for @old_data -> $old_datum {
  print "[ $old_datum ]\t";
  for @new_data -> $new_datum {
    print $new_datum - $old_datum;
    print "\t";
  }
  print "\n";
}      
