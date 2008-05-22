use v6;
use Test;
plan 8;

# L<S06/Named subroutines>

#first lets test lexical named subs
{
    my String sub myNamedStr() { return 'string' };
    is myNamedStr(), 'string', 'lexical named sub() return String';
}
is eval('myNamedStr()'), '', 'Correct : lexical named sub myNamedStr() should NOT BE available outside its scope';

{
    my Int sub myNamedInt() { return 55 };
    is myNamedInt(), 55, 'lexical named sub() return Int';
}
is eval('myNamedInt()'), '', 'Correct : lexical named sub myNamedInt() should NOT BE available outside its scope';


#packge-scoped named subs

{
    our String sub ourNamedStr() { return 'string' };
    is ourNamedStr(), 'string', 'package-scoped named sub() return String';
}
is ourNamedStr(), 'string', 'Correct : package-scoped named sub ourNamedStr() should BE available in the whole package';


{
    our Int sub ourNamedInt() { return 55 };
    is ourNamedInt(), 55, 'package-scoped named sub() return Int';
}
is ourNamedInt(), 55, 'Correct : package-scoped named sub ourNamedInt() should BE available in the whole package';

