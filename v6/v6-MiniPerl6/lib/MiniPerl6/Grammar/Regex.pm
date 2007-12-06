
use v6-alpha;

grammar MiniPerl6::Grammar::Regex {

my %rule_terms;

token ws {  <.MiniPerl6::Grammar.ws>  }

token ident {  <.MiniPerl6::Grammar.full_ident> | <digit> }

token any { . }

token literal {
    |  \\ .        <literal>
    |  <!before \' > .  <literal>
    |  ''
}

token metasyntax {
    [ 
    |  \\ .
    |  \'  <.literal>     \'
    |  \{  <.string_code> \}
    |  \<  <.metasyntax>  \>
    |  <!before \> > . 
    ]
    [ <metasyntax> | '' ]
}

token char_range {
    [ 
    |  \\ .
    |  <!before \] > . 
    ]
    [ <char_range> | '' ]
}

token char_class {
    |  <.ident>
    |  \[  <.char_range>  \]
}

# XXX - not needed
token string_code {
    # bootstrap 'code'
    [ 
    |  \\ .
    |  \'  <.literal>     \'
    |  \{  <.string_code> \}
    |  <!before \} > . 
    ]
    [ <string_code> | '' ]
}

token parsed_code {
    # this subrule is overridden inside the perl6 compiler
    # XXX - call MiniPerl6 'Statement List'
    <.string_code>
    { make ~$/ }
}

token named_capture_body {
    | \(  <rule>        \)  { make { 'capturing_group' => $$<rule> ,} } 
    | \[  <rule>        \]  { make $$<rule> } 
    | \<  <metasyntax>  \>  
            { make ::Rul::Subrule( 'metasyntax' => $$<metasyntax> ) }
    | { die 'invalid alias syntax' }
}

token variables {
    |
        '$<'
        <ident> \> 
        { make '$/{' ~ '\'' ~ $<ident> ~ '\'' ~ '}' }
    |
        # TODO
        <MiniPerl6::Grammar.sigil> 
        <MiniPerl6::Grammar.digits>
        { make $<MiniPerl6::Grammar.sigil> ~ '/[' ~ $<MiniPerl6::Grammar.digits> ~ ']' }
    |
        <MiniPerl6::Grammar.sigil> 
        <MiniPerl6::Grammar.twigil> 
        <MiniPerl6::Grammar.full_ident> 
        {
            make ::Rul::Var( 
                    'sigil'  => ~$<MiniPerl6::Grammar.sigil>,
                    'twigil' => ~$<MiniPerl6::Grammar.twigil>,
                    'name'   => ~$<MiniPerl6::Grammar.full_ident>
                   )
        }
}

token rule_terms {
    |   '('
        <rule> \)
        { make ::Rul::Capture( 'rule' => $$<rule> ) }
    |   '<('
        <rule>  ')>'
        { make ::Rul::CaptureResult( 'rule' => $$<rule> ) }
    |   '<after'
        <.ws> <rule> \> 
        { make ::Rul::After( 'rule' => $$<rule> ) }
    |   '<before'
        <.ws> <rule> \> 
        { make ::Rul::Before( 'rule' => $$<rule> ) }
    |   '<!before'
        <.ws> <rule> \> 
        { make ::Rul::NotBefore( 'rule' => $$<rule> ) }
    |   '<!'
        # TODO
        <metasyntax> \> 
        { make { negate  => { 'metasyntax' => $$<metasyntax> } } }
    |   '<+'
        # TODO
        <char_class>  \> 
        { make ::Rul::CharClass( 'chars' => ~$<char_class> ) }
    |   '<-'
        # TODO
        <char_class> \>
        { make ::Rul::NegateCharClass( 'chars' => ~$<char_class> ) }
    |   \'
        <literal> \'
        { make ::Rul::Constant( 'constant' => $$<literal> ) }
    |   # XXX - obsolete syntax
        \< \'
        <literal> \' \>
        { make ::Rul::Constant( 'constant' => $$<literal> ) }
    |   \< 
        [  
            <variables>   \>
            # { say 'matching < variables ...' }
            {
                # say 'found < hash-variable >';
                make ::Rul::InterpolateVar( 'var' => $$<variables> )
            }
        |
            \?
            # TODO 
            <metasyntax>  \>
            { make ::Rul::SubruleNoCapture( 'metasyntax' => $$<metasyntax> ) }
        |
            \.
            <metasyntax>  \>
            { make ::Rul::SubruleNoCapture( 'metasyntax' => $$<metasyntax> ) }
        |
            # TODO
            <metasyntax>  \>
            { make ::Rul::Subrule( 'metasyntax' => $$<metasyntax> ) }
        ]
    |   \{ 
        <parsed_code>  \}
        { make ::Rul::Block( 'closure' => $$<parsed_code> ) }
    |   <MiniPerl6::Grammar.backslash>  
        [
# TODO
#        | [ x | X ] <[ 0..9 a..f A..F ]]>+
#          #  \x0021    \X0021
#          { make ::Rul::SpecialChar( char => '\\' ~ $/ ) }
#        | [ o | O ] <[ 0..7 ]>+
#          #  \x0021    \X0021
#          { make ::Rul::SpecialChar( char => '\\' ~ $/ ) }
#        | ( x | X | o | O ) \[ (<-[ \] ]>*) \]
#          #  \x[0021]  \X[0021]
#          { make ::Rul::SpecialChar( char => '\\' ~ $0 ~ $1 ) }
        | <any>
          #  \e  \E
          { make ::Rul::SpecialChar( 'char' => $$<any> ) }
        ]
    |   \. 
        { make ::Rul::Dot( 'dot' => 1 ) }
    |   '[' 
        <rule> ']' 
        { make $$<rule> }

}

=for later
    |   ':::' { make { 'colon' => ':::' ,} }
    |   ':?'  { make { 'colon' => ':?' ,} }
    |   ':+'  { make { 'colon' => ':+' ,} }
    |   '::'  { make { 'colon' => '::' ,} }
    |   ':'   { make { 'colon' => ':'  ,} }
    |   '$$'  { make { 'colon' => '$$' ,} }
    |   '$'   { make { 'colon' => '$'  ,} }


# TODO - parser error ???
#    |   '^^' { make { 'colon' => '^^' ,} }
#    |   '^'  { make { 'colon' => '^'  ,} } }
#    |   '»'  { make { 'colon' => '>>' ,} } }
#    |   '«'  { make { 'colon' => '<<' ,} } }

    |   '<<'  { make { 'colon' => '<<' ,} }     
    |   '>>'  { make { 'colon' => '>>' ,} }     
    |   ':i' 
        <.ws> <rule> 
        { make { 'modifier' => 'ignorecase', 'rule' => $$<rule>, } }     
    |   ':ignorecase' 
        <.ws> <rule> 
        { make { 'modifier' => 'ignorecase', 'rule' => $$<rule>, } }     
    |   ':s' 
        <.ws> <rule> 
        { make { 'modifier' => 'sigspace',   'rule' => $$<rule>, } }     
    |   ':sigspace' 
        <.ws> <rule> 
        { make { 'modifier' => 'sigspace',   'rule' => $$<rule>, } }     
    |   ':P5' 
        <.ws> <rule> 
        { make { 'modifier' => 'Perl5',  'rule' => $$<rule>, } }     
    |   ':Perl5' 
        <.ws> <rule> 
        { make { 'modifier' => 'Perl5',  'rule' => $$<rule>, } }     
    |   ':bytes' 
        <.ws> <rule> 
        { make { 'modifier' => 'bytes',  'rule' => $$<rule>, } }     
    |   ':codes' 
        <.ws> <rule> 
        { make { 'modifier' => 'codes',  'rule' => $$<rule>, } }     
    |   ':graphs' 
        <.ws> <rule> 
        { make { 'modifier' => 'graphs', 'rule' => $$<rule>, } }     
    |   ':langs' 
        <.ws> <rule> 
        { make { 'modifier' => 'langs',  'rule' => $$<rule>, } } }
}
=cut

token term {
    |  
       # { say 'matching variables' } 
       <variables>
       [  <.ws>? <':='> <.ws>? <named_capture_body>
          { 
            make ::Rul::NamedCapture(
                'rule' =>  $$<named_capture_body>,
                'ident' => $$<variables>
            ); 
          }
       |
          { 
            make $$<variables>
          }
       ]
    | 
        # { say 'matching terms'; }
        <rule_terms>
        { 
            #print 'term: ', Dumper( $_[0]->data );
            make $$<rule_terms> 
        }
    |  <!before \] | \} | \) | \> | \: | \? | \+ | \* | \| | \& | \/ > <any>   # TODO - <...>* - optimize!
        { make ::Rul::Constant( 'constant' => $$<any> ) }
}

token quant {
    |   <'**'> <.MiniPerl6::Grammar.opt_ws> \{  <parsed_code>  \}
        { make { 'closure' => $$<parsed_code> } }
    |   [  \? | \* | \+  ]
}

token greedy {   \?  |  \+  |  ''  }

token quantifier {
    #|   <.MiniPerl6::Grammar.opt_ws>
    #    <before   \}  |  \]   |  \)   >
    #    XXX   # fail
    #|
        <.MiniPerl6::Grammar.opt_ws>
        <term> 
        <.MiniPerl6::Grammar.opt_ws2>
        [
            <quant> <greedy>
            <.MiniPerl6::Grammar.opt_ws3>
            { make ::Rul::Quantifier(
                    'term'    => $$<term>,
                    'quant'   => $$<quant>,
                    'greedy'  => $$<greedy>,
                    'ws1'     => $$<MiniPerl6::Grammar.opt_ws>,
                    'ws2'     => $$<MiniPerl6::Grammar.opt_ws2>,
                    'ws3'     => $$<MiniPerl6::Grammar.opt_ws3>,
                )
            }
        |
            { make $$<term> }
        ]
}

token concat_list {
    <quantifier>
    [
        <concat_list> 
        { make [ $$<quantifier>, @($$<concat_list>) ] }
    |
        { make [ $$<quantifier> ] }
    ]
    |
        { make [] }
}

token concat {
    <concat_list>
    { make ::Rul::Concat( 'concat' => $$<concat_list> ) }
}

token or_list {
    <concat>
    [
        <'|'>
        <or_list> 
        { make [ $$<concat>, @($$<or_list>) ] }
    |
        { make [ $$<concat> ] }
    ]
    |
        { make [] }
}

token rule {
    [ <.ws>? '|' | '' ]
    # { say 'trying M::G::Rule on ', $s }
    <or_list>
    { 
        # say 'found Rule';
        make ::Rul::Or( 'or' => $$<or_list> ) 
    }
}

}

=begin

=head1 NAME 

MiniPerl6::Grammar::Regex - Grammar for MiniPerl6 Regex

=head1 SYNOPSIS

    my $match := $source.rule;
    ($$match).perl;    # generated Regex AST

=head1 DESCRIPTION

This module generates a syntax tree for the Regex compiler.

=head1 AUTHORS

The Pugs Team E<lt>perl6-compiler@perl.orgE<gt>.

=head1 SEE ALSO

The Perl 6 homepage at L<http://dev.perl.org/perl6>.

The Pugs homepage at L<http://pugscode.org/>.

=head1 COPYRIGHT

Copyright 2006 by Flavio Soibelmann Glock, Audrey Tang and others.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=end
