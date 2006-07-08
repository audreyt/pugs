use v6-alpha;
use Test;

plan 2;

use Perl::Compiler::PIL; pass "(dummy instead of broken use_ok)";

{   # 1 = 2 breaks
my $literal_1 = ::Perl::Compiler::PIL::PILVal.new(value => 1);
my $literal_2 = ::Perl::Compiler::PIL::PILVal.new(value => 2);
dies_ok({ ::Perl::Compiler::PIL::PILAssign.new(lefts => [$literal_1], right => $literal_2) }, '1 = 2 fails');
}

# vim: ft=perl6 :
