use v6;
use Test;

plan 1;

# L<S02/"One-pass parsing">

ok(eval('regex foo { <[ } > ]> }; 1'),
    "can parse non-backslashed curly and right bracket in cclass");
