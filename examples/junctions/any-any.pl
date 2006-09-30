use v6-alpha;

# Please remember to update t/examples/examples.t and rename
# examples/output/junctions/any-any if you rename/move this file.

# any compared with any

my @first_set = <1 1 1 1 1 1 1 1 1 1 1 1 1 1>;
my @new_set = <1 2 1 1 1 1 1 1 1>;

if (any(@first_set) != any(@new_set)) {
  "a fluctuation in the readings has been detected".say;
}
