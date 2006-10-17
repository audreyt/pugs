use v6-alpha;

use Test;

plan 11;

=head1 DESCRIPTION

This test tests the C<pick> builtin.

Closest I could find to documentation:
L<"http://groups.google.com/group/perl.perl6.language/tree/browse_frm/thread/24e369fba3ed626e/4e893cad1016ed94?rnum=1&_done=%2Fgroup%2Fperl.perl6.language%2Fbrowse_frm%2Fthread%2F24e369fba3ed626e%2F6e6a2aad1dcc879d%3F#doc_2ed48e2376511fe3"> 
=cut

# L<S29/List/=item pick>

my @array = <a b c d>;
ok ?(@array.pick eq any <a b c d>), "pick works on arrays";

my %hash = (a => 1);
is %hash.pick.key,   "a", "pick works on hashes (1)";
is %hash.pick.value, "1", "pick works on hashes (2)";

my $junc = (1|2|3);
ok ?(1|2|3 == $junc.pick), "pick works on junctions";

my @arr = <z z z>;

is eval('@arr.pick(2)'), <z z>,  'method pick with $num < +@values', :todo<feature>;
is eval('@arr.pick(4)'), <z z z>, 'method pick with $num > +@values', :todo<feature>;
is eval('@arr.pick(4, :repl)'), <z z z z>, 'method pick(:repl) with $num > +@values', :todo<feature>;

is eval('pick(2, @arr)'), <z z>, 'sub pick with $num < +@values', :todo<feature>;
is eval('pick(4, @arr)'), <z z z>, 'sub pick with $num > +@values', :todo<feature>;
is eval('pick(4, :repl, @arr)'), <z z z z>, 'sub pick(:repl) with $num > +@values', :todo<feature>;

my $c = 0;
my @value = gather {
  eval '
    for (0,1).pick(*, :repl) -> $v { take($v); leave if ++$c > 3; }
    ';
}

ok +@value == $c && $c, 'pick(*, :repl) is lazy', :todo<feature>;
