#!/usr/bin/pugs

use v6;

use Test;

plan 33;


=head1 DESCRIPITION

These tests test subroutine references and their invocation.

See L<S06/"Types"> for more information about Code, Routine, Sub, Block, etc.

=cut

# See L<S06/"Types"> and especially L<A06/"The C<sub> form"> why {...} and ->
# ... {...} aren't Subs, but Blocks (they're all Codes, though).
# Quoting A06:
#                                   Code
#                        ____________|________________
#                       |                             |
#                    Routine                        Block
#       ________________|_______________ 
#      |     |       |       |    |     |
#     Sub Method Submethod Multi Rule Macro

{
    my $foo = sub () { 42 };
    isa_ok($foo, 'Code');
    isa_ok($foo, 'Routine');
    isa_ok($foo, 'Sub');
    is $foo.(), 42,                 "basic invocation of an anonymous sub";
    try { $foo.(23) };
    ok($!, "invocation of an parameterless anonymous sub with a parameter dies",:todo);
}

{
    my $foo = -> () { 42 };
    isa_ok($foo, 'Code');
    isa_ok($foo, 'Block');
    is $foo.(), 42,                 "basic invocation of a pointy block";
    try { $foo.(23) };
    ok($!, "invocation of an parameterless pointy block with a parameter dies",:todo);
}

{
    my $foo = { 100 + $^x };
    isa_ok($foo, 'Code');
    isa_ok($foo, 'Block');
    is $foo.(42), 142,              "basic invocation of a pointy block with a param";
    try { $foo.() };
    ok($!, "invocation of an parameterized block expecting a param without a param dies");
}

{
    my $foo = sub { 100 + (@_[0] // -1) };
    isa_ok($foo, 'Code');
    isa_ok($foo, 'Routine');
    isa_ok($foo, 'Sub');
    is $foo.(42), 142,              "basic invocation of a perl5-like anonymous sub (1)";
    is $foo.(),    99,              "basic invocation of a perl5-like anonymous sub (2)";
}

{
    my $foo = sub ($x) { 100 + $x };
    isa_ok($foo, 'Code');
    isa_ok($foo, 'Routine');
    isa_ok($foo, 'Sub');
    is $foo.(42),      142,    "calling an anonymous sub with a positional param";
    is $foo.(x => 42), 142,    "calling an anonymous sub with a positional param addressed by name";
    try{ $foo.() };
    ok($!, "calling an anonymous sub expecting a param without a param dies");
    try{ $foo.(42, 5) };
    ok($!, "calling an anonymous sub expecting one param with two params dies",:todo);
}

# Confirmed by p6l, see thread "Anonymous macros?" by Ingo Blechschmidt
# http://www.nntp.perl.org/group/perl.perl6.language/21825
{
    # We do all this in a eval() not because the code doesn't parse,
    # but because it's safer to only call macro references at compile-time.
    # So we'd need to wrap the code in a BEGIN {...} block. But then, our test
    # code would be called before all the other tests, causing confusion. :)
    # So, we wrap the code in a eval() with an inner BEGIN.
    # (The macros are subject to MMD thing still needs to be fleshed out, I
    # think.)
    eval 'BEGIN {
        BEGIN { our &foo_macro = macro ($x) { "1000 + $x" } }
        isa_ok(&foo_macro, "Code");
        isa_ok(&foo_macro, "Routine");
        isa_ok(&foo_macro, "Macro", :todo<feature>);

        is foo_macro(3), 1003, "anonymous macro worked";
    }';
}

{
    my $mkinc = sub { my $x = 0; return sub { $x++ }; };

    my $inc1 = $mkinc();
    my $inc2 = $mkinc();

    is($inc1(), 0, "inc1 == 0");
    is($inc1(), 1, "inc1 == 1");
    is($inc2(), 0, "inc2 == 0");
    is($inc2(), 1, "inc2 == 1");
}
