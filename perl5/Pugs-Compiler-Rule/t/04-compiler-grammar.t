use strict;
use warnings;
use Test::More 'no_plan';
use Pugs::Compiler::Grammar;

my $obj = Pugs::Compiler::Grammar->compile(<<'_EOC_');
grammar Perl;

token foo { 'a'* }

grammar C ;

token bar { <ident> }

_EOC_
ok $obj, 'obj ok';
isa_ok $obj, 'Pugs::Compiler::Grammar';
ok $obj->{perl5}, 'p5 code okay';
#die $obj->{perl5};
eval $obj->{perl5};
is $@, '', "no error while eval";
my $match = Perl->foo('aaba');
ok $match->bool, 'matched';
is $match, 'aa', 'capture okay';

$match = C->bar('hello');
is $match, 'hello', 'capture okay';

$obj = Pugs::Compiler::Grammar->compile(<<'_EOC_');
grammar MyLang;
token def {
    <type> <?ws> <var_list> <?ws>? ';'
}
token type { int | float | double | char }
token var_list { <ident>**{1} <?ws>? [ ',' <?ws>? <ident> ]* }
_EOC_
ok $obj;
isa_ok $obj, 'Pugs::Compiler::Grammar';
ok $obj->{perl5}, 'p5 code okay';
eval $obj->{perl5};
$match = MyLang->def('int a, b, c;');
ok $match->bool, 'matched';
is $match, 'int a, b, c;';
$match = MyLang->type('double');
is $match, 'double';
$match = MyLang->def('char d,b ;');
is $match, 'char d,b ;';
is $match->{type}, 'char';
is $match->{var_list}->{ident}->[0], 'd';
#print $obj->perl5;

# mult-grammars
{
    my $grammar = q{
        grammar My::C;

        token def {
            <type> <?ws> <var_list> <?ws>? ';'
        }

        token type { int | float | double | char }

        token var_list {
            <ident>**{1} <?ws>? [ ',' <?ws>? <ident> ]*
        }

        grammar My::VB;

        token def {
            'Dim' <?ws> <My::C.var_list>
            [ <?ws> 'As' <?ws> <My::C.type> ]? <?ws>? ';'
        }
    };
    my $obj = Pugs::Compiler::Grammar->compile($grammar);
    my $perl5 = $obj->perl5;
    #warn $perl5;
    eval $perl5; die $@ if $@;
    my $match = My::C->def("float foo;");
    is $match->{type}, 'float', "My::C's type okay";
    is $match->{var_list}, 'foo', "My::C's var_list okay\n";
    $match = My::VB->def("Dim foo, bar;");
    #die;
    is $match->{'My::C.var_list'}, 'foo, bar', "My::VB's var_list okay\n";
}

{
    $Blah::Count = 0;
    my $grammar = q{

        grammar Blah;

        %{ our $Count = 27; %}

        token add {
            (\d+) { return $Blah::Count += $/[0] }
        }

    };
    my $obj = Pugs::Compiler::Grammar->compile($grammar);
    #warn $obj->perl5;
    eval $obj->perl5;
    is $@, '', 'eval ok';
    #warn "HERE!";
    my $match = Blah->add('53');
    ok $match->bool, 'matched';
    is $Blah::Count, 80;
    is $match->(), 80, 'closure works';
}

