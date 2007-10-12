use v6-alpha;

grammar MiniPerl6::Grammar {

use MiniPerl6::Grammar::Regex;
use MiniPerl6::Grammar::Mapping;
use MiniPerl6::Grammar::Control;

# XXX - move to v6.pm emitter
#sub array($data)    { use v5; @$data; use v6; }
 
my $Class_name;  # for diagnostic messages
sub get_class_name { $Class_name } 

token ident_digit {
    [ [ <?word> | _ | <?digit> ] <?ident_digit>
    |   ''
    ]    
}

token ident {
    [ <?word> | _ ] <?ident_digit>
}

token full_ident {
    <?ident>
    [   <'::'> <?full_ident>
    |   ''
    ]    
}

token to_line_end {
    |  \N <?to_line_end>
    |  ''
}

token pod_begin {
    |   \n <'=end'> <?to_line_end>
    |   . <?to_line_end> <?pod_begin>
}

token pod_other {
    |   \n <'=cut'> <?to_line_end>
    |   . <?to_line_end> <?pod_other>
}

token ws {
    [
    |    <'#'> <?to_line_end>
    |    \n [
            |  <'=begin'>  <?pod_begin>
            |  <'=kwid'>   <?pod_other>
            |  <'=pod'>    <?pod_other>
            |  <'=for'>    <?pod_other>
            |  <'=head1'>  <?pod_other>
            |  ''
            ]
    |    \s
    ]
    [ <?ws> | '' ]
}

token opt_ws  {  <?ws> | ''  }
token opt_ws2 {  <?ws> | ''  }
token opt_ws3 {  <?ws> | ''  }

token parse {
    | <comp_unit>
        [
        |   <parse>
            { return [ $$<comp_unit>, @( $$<parse> ) ] }
        |   { return [ $$<comp_unit> ] }
        ]
    | { return [] }
}

token comp_unit {
    <?opt_ws> [\; <?opt_ws> | '' ]
    [ <'use'> <?ws> <'v6-'> <ident> <?opt_ws> \; <?ws>  |  '' ]
    
    [ <'class'> | <'grammar'> ]  <?opt_ws> <full_ident> <?opt_ws> 
    <'{'>
        { $Class_name := ~$<full_ident> }
        <?opt_ws>
        <exp_stmts>
        <?opt_ws>
    <'}'>
    <?opt_ws> [\; <?opt_ws> | '' ]
    {
        return ::CompUnit(
            'name'        => $$<full_ident>,
            'attributes'  => { },
            'methods'     => { },
            'body'        => $$<exp_stmts>,
        )
    }
}

token infix_op {
    <'+'> | <'-'> | <'*'> | <'/'> | eq | ne | <'=='> | <'!='> | <'&&'> | <'||'> | <'~~'> | <'~'> | '>'
}

token hyper_op {
    <'>>'> | ''
}

token prefix_op {
    [ <'$'> | <'@'> | <'%'> | <'?'> | <'!'> | <'++'> | <'--'> | <'+'> | <'-'> | <'~'> ] 
    <before <'('> | <'$'> >
}

token declarator {
     <'my'> | <'state'> | <'has'> 
}

token exp2 { <exp> { return $$<exp> } }
token exp_stmts2 { <exp_stmts> { return $$<exp_stmts> } }

}
    #---- split into compilation units in order to use less RAM...
grammar MiniPerl6::Grammar {


token exp {
    # { say 'exp: going to match <term_meth> at ', $/.to; }
    <term_meth> 
    [
        <?opt_ws>
        <'??'>
        [
          <?opt_ws>  <exp>
          <?opt_ws>  <'!!'>
          <?opt_ws>
          <exp2>
          { return ::Apply(
            'code'      => 'ternary:<?? !!>',
            'arguments' => [ $$<term_meth>, $$<exp>, $$<exp2> ],
          ) }
        | { say '*** Syntax error in ternary operation' }
        ]
    |
        <?opt_ws>
        <infix_op>
        <?opt_ws>
        <exp>
          { return ::Apply(
            'code'      => 'infix:<' ~ $<infix_op> ~ '>',
            'arguments' => [ $$<term_meth>, $$<exp> ],
          ) }
    | <?opt_ws> <':='> <?opt_ws> <exp>
        { return ::Bind( 'parameters' => $$<term_meth>, 'arguments' => $$<exp>) }
    |   { return $$<term_meth> }
    ]
}

token opt_ident {  
    | <ident>  { return $$<ident> }
    | ''     { return 'postcircumfix:<( )>' }
}

token term_meth {
    <full_ident>
    [ \.
    
        [

            'new'
            \( 
            [
                <?opt_ws> <exp_mapping> <?opt_ws> \)
                {
                    # say 'Parsing Lit::Object ', $$<full_ident>, ($$<exp_mapping>).perl;
                    return ::Lit::Object(
                        'class'  => $$<full_ident>,
                        'fields' => $$<exp_mapping>
                    )
                }
            | { say '*** Syntax Error parsing Constructor'; die() }
            ]

        
        ]
        |
        [
            <hyper_op>
            <ident>
                [ \( <?opt_ws> <exp_seq> <?opt_ws> \)
                    # { say 'found parameter list: ', $<exp_seq>.perl }
                | \: <?ws> <exp_seq> <?opt_ws>
                |
                    {
                        return ::Call(
                            'invocant'  => ::Proto( 'name' => ~$<full_ident> ),
                            'method'    => $$<ident>,
                            'arguments' => undef,
                            'hyper'     => $$<hyper_op>,
                        )
                    }
                ]
                {
                    return ::Call(
                        'invocant'  => ::Proto( 'name' => ~$<full_ident> ),
                        'method'    => $$<ident>,
                        'arguments' => $$<exp_seq>,
                        'hyper'     => $$<hyper_op>,
                    )
                }
        ]
    ]
    |
    <term>
    [ \.
        <hyper_op>
        <opt_ident>   # $obj.(42)
            [ \( 
                # { say 'testing exp_seq at ', $/.to }
                <?opt_ws> <exp_seq> <?opt_ws> \)
                # { say 'found parameter list: ', $<exp_seq>.perl }
            | \: <?ws> <exp_seq> <?opt_ws>
            |
                {
                    return ::Call(
                        'invocant'  => $$<term>,
                        'method'    => $$<opt_ident>,
                        'arguments' => undef,
                        'hyper'     => $$<hyper_op>,
                    )
                }
            ]
            {
                return ::Call(
                    'invocant'  => $$<term>,
                    'method'    => $$<opt_ident>,
                    'arguments' => $$<exp_seq>,
                    'hyper'     => $$<hyper_op>,
                )
            }
    | \[ <?opt_ws> <exp> <?opt_ws> \]
         { return ::Index(  'obj' => $$<term>, 'index' => $$<exp> ) }   # $a[exp]
    | \{ <?opt_ws> <exp> <?opt_ws> \}
         { return ::Lookup( 'obj' => $$<term>, 'index' => $$<exp> ) }   # $a{exp}
    |    { return $$<term> }
    ]
}

token sub_or_method_name {
    <full_ident> [ \. <ident> | '' ]
}

token opt_type {
    |   [ <'::'> | '' ]  <full_ident>   { return $$<full_ident> }
    |   ''                              { return '' }
}

token term {
    | <var>     { return $$<var> }     # $variable
    | <prefix_op> <exp> 
          { return ::Apply(
            'code'      => 'prefix:<' ~ $<prefix_op> ~ '>',
            'arguments' => [ $$<exp> ],
          ) }
    | \( <?opt_ws> <exp> <?opt_ws> \)
        { return $$<exp> }   # ( exp )
    | \{ <?opt_ws> <exp_mapping> <?opt_ws> \}
        { return ::Lit::Hash( 'hash' => $$<exp_mapping> ) }   # { exp => exp, ... }
    | \[ <?opt_ws> <exp_seq> <?opt_ws> \]
        { return ::Lit::Array( 'array' => $$<exp_seq> ) }   # [ exp, ... ]
    | \$ \< <sub_or_method_name> \>
        { return ::Lookup( 
            'obj'   => ::Var( 'sigil' => '$', 'twigil' => '', 'name' => '/' ), 
            'index' => ::Val::Buf( 'buf' => $$<sub_or_method_name> ) 
        ) }   # $<ident>
    | do <?opt_ws> \{ <?opt_ws> <exp_stmts> <?opt_ws> \}
        { return ::Do( 'block' => $$<exp_stmts> ) }   # do { stmt; ... }
    | <declarator> <?ws> <opt_type> <?opt_ws> <var>   # my Int $variable
        { return ::Decl( 'decl' => $$<declarator>, 'type' => $$<opt_type>, 'var' => $$<var> ) }
    | use <?ws> <full_ident>  [ - <ident> | '' ]
        { return ::Use( 'mod' => $$<full_ident> ) }
    | <val>     { return $$<val> }     # 'value'
    | <lit>     { return $$<lit> }     # [literal construct]
#   | <bind>    { return $$<bind>   }  # $lhs := $rhs
    | <token>   { return $$<token>  }  # token  { regex... }
    | <method>  { return $$<method> }  # method { code... }
    | <sub>     { return $$<sub>    }  # sub    { code... }
    | <control> { return $$<control> } # Various control structures.  Does _not_ appear in binding LHS
#   | <index>     # $obj[1, 2, 3]
#   | <lookup>    # $obj{'1', '2', '3'}
    | <apply>   { return $$<apply>  }  # self; print 1,2,3
}

#token index { XXX }
#token lookup { XXX }

}
    #---- split into compilation units in order to use less RAM...
grammar MiniPerl6::Grammar {

token sigil { \$ |\% |\@ |\& }

token twigil { [ \. | \! | \^ | \* ] | '' }

token var_name { <full_ident> | <'/'> | <digit> }

token var {
    <sigil> <twigil> <var_name>
    {
        return ::Var(
            'sigil'  => ~$<sigil>,
            'twigil' => ~$<twigil>,
            'name'   => ~$<var_name>,
        )
    }
}

token val {
    | <val_undef>  { return $$<val_undef> }  # undef
    # | $<exp> := <val_object>   # (not exposed to the outside)
    | <val_int>    { return $$<val_int>   }  # 123
    | <val_bit>    { return $$<val_bit>   }  # True, False
    | <val_num>    { return $$<val_num>   }  # 123.456
    | <val_buf>    { return $$<val_buf>   }  # 'moose'
}

token val_bit {
    | True  { return ::Val::Bit( 'bit' => 1 ) }
    | False { return ::Val::Bit( 'bit' => 0 ) }
}


}
    #---- split into compilation units in order to use less RAM...
grammar MiniPerl6::Grammar {


token val_undef {
    undef <!before \w >
    { return ::Val::Undef( ) }
}

token val_num {  
    XXX { return 'TODO: val_num' } 
}

token double_quoted {
    |  \\ .  <double_quoted>
    |  <!before \" > . <double_quoted>
    |  ''    
}

token single_quoted {
    |  \\ .  <single_quoted>
    |  <!before \' > . <single_quoted>
    |  ''    
}

token digits {  \d  [ <digits> | '' ]  }

token val_buf {
    | \" <double_quoted>  \" { return ::Val::Buf( 'buf' => ~$<double_quoted> ) }
    | \' <single_quoted>  \' { return ::Val::Buf( 'buf' => ~$<single_quoted> ) }
}

token val_int {
    <digits>
    { return ::Val::Int( 'int' => ~$/ ) }
}

token exp_stmts {
    | <exp>
        [
        |   <?opt_ws> [ \; | '' ] <?opt_ws> <exp_stmts>
            <?opt_ws> [ \; <?opt_ws> | '' ]
            { return [ $$<exp>, @( $$<exp_stmts> ) ] }
        |   <?opt_ws> [ \; <?opt_ws> | '' ]
            { return [ $$<exp> ] }
        ]
    | { return [] }
}

token exp_seq {
    | <exp>
        # { say 'exp_seq: matched <exp>' }
        [
        |   <?opt_ws> \, <?opt_ws> <exp_seq> 
            <?opt_ws> [ \, <?opt_ws> | '' ]
            { return [ $$<exp>, @( $$<exp_seq> ) ] }
        |   <?opt_ws> [ \, <?opt_ws> | '' ]
            { return [ $$<exp> ] }
        ]
    | 
        # { say 'exp_seq: end of match' }
        { return [] }
}

}
    #---- split into compilation units in order to use less RAM...
grammar MiniPerl6::Grammar {

token lit {
    #| <lit_seq>    { return $$<lit_seq>    }  # (a, b, c)
    #| <lit_array>  { return $$<lit_array>  }  # [a, b, c]
    #| <lit_hash>   { return $$<lit_hash>   }  # {a => x, b => y}
    #| <lit_code>   { return $$<lit_code>   }  # sub $x {...}
    | <lit_object> { return $$<lit_object> }  # ::Tree(a => x, b => y);
}

token lit_seq   {  XXX { return 'TODO: lit_seq'    } }
token lit_array {  XXX { return 'TODO: lit_array'  } }
token lit_hash  {  XXX { return 'TODO: lit_hash'   } }
token lit_code  {  XXX { return 'TODO - Lit::Code' } }

token lit_object {
    <'::'>
    <full_ident>
    \( 
    [
        <?opt_ws> <exp_mapping> <?opt_ws> \)
        {
            # say 'Parsing Lit::Object ', $$<full_ident>, ($$<exp_mapping>).perl;
            return ::Lit::Object(
                'class'  => $$<full_ident>,
                'fields' => $$<exp_mapping>
            )
        }
    | { say '*** Syntax Error parsing Constructor'; die() }
    ]
}

token bind {
    <exp>  <?opt_ws> <':='> <?opt_ws>  <exp2>
    {
        return ::Bind(
            'parameters' => $$<exp>,
            'arguments'  => $$<exp2>,
        )
    }
}

token call {
    <exp> \. <ident> \( <?opt_ws> <exp_seq> <?opt_ws> \)
    {
        return ::Call(
            'invocant'  => $$<exp>,
            'method'    => $$<ident>,
            'arguments' => $$<exp_seq>,
        )
    }
}

token apply {
    <full_ident>
    [
        [ \( <?opt_ws> <exp_seq> <?opt_ws> \)
        | <?ws> <exp_seq> <?opt_ws>
        ]
        {
            return ::Apply(
                'code'      => $$<full_ident>,
                'arguments' => $$<exp_seq>,
            )
        }
    |
        {
            return ::Apply(
                'code'      => $$<full_ident>,
                'arguments' => [],
            )
        }
    ]
}

token opt_name {  <ident> | ''  }


token invocant {
    |  <var> \:    { return $$<var> }
    |  { return ::Var( 
            'sigil'  => '$',
            'twigil' => '',
            'name'   => 'self',
         ) 
       }
}

token sig {
        <invocant>
        <?opt_ws> 
        # TODO - exp_seq / exp_mapping == positional / named 
        <exp_seq> 
        {
            # say ' invocant: ', ($$<invocant>).perl;
            # say ' positional: ', ($$<exp_seq>).perl;
            return ::Sig( 'invocant' => $$<invocant>, 'positional' => $$<exp_seq>, 'named' => { } );
        }
}

token method_sig {
    |   <?opt_ws> \( <?opt_ws>  <sig>  <?opt_ws>  \)
        { return $$<sig> }
    |   { return ::Sig( 
            'invocant' => ::Var( 
                'sigil'  => '$',
                'twigil' => '',
                'name'   => 'self' ), 
            'positional' => [ ], 
            'named' => { } ) }
}

token method {
    method
    <?ws>  <opt_name>  <?opt_ws> 
    <method_sig>
    <?opt_ws> \{ <?opt_ws>  
          # { say ' parsing statement list ' }
          <exp_stmts> 
          # { say ' got statement list ', ($$<exp_stmts>).perl } 
        <?opt_ws> 
    [   \}     | { say '*** Syntax Error in method \'', get_class_name(), '.', $$<name>, '\' near pos=', $/.to; die 'error in Block'; } ]
    {
        # say ' block: ', ($$<exp_stmts>).perl;
        return ::Method( 'name' => $$<opt_name>, 'sig' => $$<method_sig>, 'block' => $$<exp_stmts> );
    }
}

token sub {
    sub
    <?ws>  <opt_name>  <?opt_ws> 
    <method_sig>
    <?opt_ws> \{ <?opt_ws>  
          <exp_stmts> <?opt_ws> 
    [   \}     | { say '*** Syntax Error in sub \'', $$<name>, '\''; die 'error in Block'; } ]
    { return ::Sub( 'name' => $$<opt_name>, 'sig' => $$<method_sig>, 'block' => $$<exp_stmts> ) }
}

}
    #---- split into compilation units in order to use less RAM...
grammar MiniPerl6::Grammar {

token token {
    # { say 'parsing Token' }
    token
    <?ws>  <opt_name>  <?opt_ws> \{
        <MiniPerl6::Grammar::Regex.rule>
    \}
    {
        #say 'Token was compiled into: ', ($$<MiniPerl6::Grammar::Regex.rule>).perl;
        my $source := 'method ' ~ $<opt_name> ~ ' ( $grammar: $str, $pos ) { ' ~
            'my $MATCH; $MATCH := ::MiniPerl6::Perl5::Match( \'str\' => $str, \'from\' => $pos, \'to\' => $pos, \'bool\' => 1 ); ' ~ 
            '$MATCH.bool( ' ~
                ($$<MiniPerl6::Grammar::Regex.rule>).emit ~
            '); ' ~
            'return $MATCH }';
        #say 'Intermediate code: ', $source;
        my $ast := MiniPerl6::Grammar.term( $source );
        # say 'Intermediate ast: ', $$ast.emit;
        return $$ast;
    }
}

}

=begin

=head1 NAME 

MiniPerl6::Grammar - Grammar for MiniPerl6

=head1 SYNOPSIS

    my $match := $source.parse;
    ($$match).perl;    # generated MiniPerl6 AST

=head1 DESCRIPTION

This module generates a syntax tree for the MiniPerl6 compiler.

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
