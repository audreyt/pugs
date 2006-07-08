use v6-alpha;

=head1 Printing a list with commas

You'd like to print out a list containing an unknown number of elements,
placing an "and" before the last element and commas between each element if
there are more than two.

=cut

my @a = <alpha beta gamma>;

say commify_series('foo');
say commify_series(<this that>);
say commify_series(@a);

sub commify_series(@list) {
    given @list.elems {
        when 0  { return '' };
        when 1  { return @list[0] };
        when 2  { return join " and ", @list };
        default { return join(", ", @list[0 .. $_ -2]) ~ " and @list[-1]" };
    };
}
