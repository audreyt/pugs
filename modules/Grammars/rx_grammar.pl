
=pod

The world needs a Perl6 regex pattern reference grammar.
Here is a place to accumulate one.

=cut

grammar Rx;

rule pattern { ... }

rule name { <?Perl6.name> }

#rule code { <?Perl6.prog> }
rule code { ( [ <-[{}]>+ | \{<?code>\} ]* ) }

rule flag_parsetree   { <':parsetree'> }
rule flag_exhaustive  { <':exhaustive'> | <':ex'> }
rule flag_overlap     { <':overlap'> | <':ov'> }
rule flag_words       { <':words'> | <':w'> }

rule subrule                    { \< (\?)? <name> \> }
rule subpattern                 { \( <pattern>    \) }
rule noncapturing_brackets      { \[ <subpattern> \] }
rule closure	                { \{ <code>  \} }

rule named_scalar_alias		{ \$\< <name> \>     \:\= <construct> }
rule numbered_scalar_alias	{ \$ $<number>=(\d+) \:\= <construct> }
rule array_alias		{ \@\< <name> \>     \:\= <construct> }
rule hash_alias			{ \%\< <name> \>     \:\= <construct> }
rule external_scalar_alias	{ \$<name>           \:\= <construct> }
rule external_array_alias	{ \@<name>           \:\= <construct> }
rule external_hash_alias	{ \%<name>           \:\= <construct> }

rule construct {
    <subpattern>
  | <noncapturing_brackets>
  | <subrule>
  | <quantified_construct>
}

rule quantified_construct { <construct> <quantifier> }

rule quantifier {
    <quantifier_opt>
  | <quantifier_rep>
}
rule quantifier_opt { \? | \?\? } # need better name
rule quantifier_rep { \* | \+ | \*\? | \+\? } # need better name

rule comment { \# \N* \n }

rule sp { <' '> }
rule ws { \s+ }
