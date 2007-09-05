use v6-alpha;


#class Module {
#    has $.name;
#    has @.body;
#    method emit( $visitor, $path ) {
#        KindaPerl6::Traverse::visit( 
#            $visitor, 
#            self,
#            'Module',
#        );
#    };
#    method attribs {
#            { 
#                name    => $.name,
#                body    => @.body,
#            }
#    };
#}

class CompUnit {
    has $.unit_type;
    has $.name;
    has @.traits;
    has %.attributes;
    has %.methods;
    has @.body;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'CompUnit',
            $path,
        );
    };
    method attribs {
            { 
                unit_type => $.unit_type,
                name    => $.name,
                traits  => @.traits,
                attributes => %.attributes,
                methods => %.methods,
                body    => @.body,
            }
    };
}

class Val::Int {
    has $.int;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Val::Int',
            $path,
        );
    };
    method attribs {
            { 
                int    => $.int,
            }
    };
}

class Val::Bit {
    has $.bit;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Val::Bit',
            $path,
        );
    };
    method attribs {
            { 
                bit    => $.bit,
            }
    };
}

class Val::Num {
    has $.num;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Val::Num',
            $path,
        );
    };
    method attribs {
            { 
                num    => $.num,
            }
    };
}

class Val::Buf {
    has $.buf;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Val::Buf',
            $path,
        );
    };
    method attribs {
            { 
                buf    => $.buf,
            }
    };
}

class Val::Undef {
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Val::Undef',
            $path,
        );
    };
    method attribs {
            { 
            }
    };
}

class Val::Object {
    has $.class;
    has %.fields;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Val::Object',
            $path,
        );
    };
    method attribs {
            { 
                class  => $.class,
                fields => %.fields,
            }
    };
}

class Lit::Seq {
    has @.seq;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Lit::Seq',
            $path,
        );
    };
    method attribs {
            { 
                seq  => @.seq,
            }
    };
}

class Lit::Array {
    has @.array;    
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Lit::Array',
            $path,
        );
    };
    method attribs {
            { 
                array  => @.array,
            }
    };
}

class Lit::Hash {
    has @.hash;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Lit::Hash',
            $path,
        );
    };
    method attribs {
            { 
                hash  => @.hash,
            }
    };
}

class Lit::Pair {
    has $.key;
    has $.value;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Lit::Pair',
            $path,
        );
    };
    method attribs {
            { 
                key   => $.key,
                value => $.value,
            }
    };
}

class Lit::Code {
    has %.pad;         #  is Mapping of Type; # All my/state/parameter variables
    has %.state;       #  is Mapping of Exp;  # State initializers, run upon first entry 
    has $.sig;         #  is Sig              # Signature
    has @.body;        #  is Seq of Exp;      # Code body 
    #has @.parameters;  #  is Seq of Exp;      # Signature
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Lit::Code',
            $path,
        );
    };
    method attribs {
            { 
                pad   => %.pad,
                state => %.state,
                sig   => $.sig,
                body  => @.body,
            }
    };
}

class Lit::Object {
    has $.class;
    has @.fields;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Lit::Object',
            $path,
        );
    };
    method attribs {
            { 
                class  => $.class,
                fields => %.fields,
            }
    };
}

class Index {
    has $.obj;
    has $.index;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Index',
            $path,
        );
    };
    method attribs {
            { 
                obj   => $.obj,
                index => $.index,
            }
    };
}

class Lookup {
    has $.obj;
    has $.index;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Lookup',
            $path,
        );
    };
    method attribs {
            { 
                obj   => $.obj,
                index => $.index,
            }
    };
}

class Var {
    has $.sigil;
    has $.twigil;
    has $.name;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Var',
            $path,
        );
    };
    method attribs {
            { 
                sigil   => $.sigil,
                twigil  => $.twigil,
                name    => $.name,
            }
    };
}

class Bind {
    has $.parameters;
    has $.arguments;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Bind',
            $path,
        );
    };
    method attribs {
            { 
                parameters   => $.parameters,
                arguments    => $.arguments,
            }
    };
}

class Assign {
    has $.parameters;
    has $.arguments;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Assign',
            $path,
        );
    };
    method attribs {
            { 
                parameters   => $.parameters,
                arguments    => $.arguments,
            }
    };
}

class Proto {
    has $.name;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Proto',
            $path,
        );
    };
    method attribs {
            { 
                name   => $.name,
            }
    };
}

class Call {
    has $.invocant;
    has $.hyper;
    has $.method;
    has @.arguments;
    #has $.hyper;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Call',
            $path,
        );
    };
    method attribs {
            { 
                invocant   => $.invocant,
                hyper      => $.hyper,
                method     => $.method,
                arguments  => @.arguments,
            }
    };
}

class Apply {
    has $.code;
    has @.arguments;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Apply',
            $path,
        );
    };
    method attribs {
            { 
                code       => $.code,
                arguments  => @.arguments,
            }
    };
}

class Return {
    has $.result;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Return',
            $path,
        );
    };
    method attribs {
            { 
                result    => $.result,
            }
    };
}

class If {
    has $.cond;
    has @.body;
    has @.otherwise;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'If',
            $path,
        );
    };
    method attribs {
            { 
                cond       => $.cond,
                body       => @.body,
                otherwise  => @.otherwise,
            }
    };
}

class For {
    has $.cond;
    has @.body;
    has @.topic;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'For',
            $path,
        );
    };
    method attribs {
            { 
                cond       => $.cond,
                body       => @.body,
                topic      => @.topic,
            }
    };
}

class Decl {
    has $.decl;
    has $.type;
    has $.var;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Decl',
            $path,
        );
    };
    method attribs {
            { 
                decl       => $.decl,
                type       => @.type,
                var        => @.var,
            }
    };
}

class Sig {
    has $.invocant;
    has $.positional;
    has $.named;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Sig',
            $path,
        );
    };
    method attribs {
            { 
                invocant   => $.invocant,
                positional => @.positional,
                named      => @.named,
            }
    };
}

class Capture {
    has $.invocant;
    has $.array;
    has $.hash;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Capture',
            $path,
        );
    };
    method attribs {
            { 
                invocant   => $.invocant,
                array      => @.array,
                hash       => @.hash,
            }
    };
}

class Subset {
    has $.name;
    has $.base_class;
    has $.block;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Subset',
            $path,
        );
    };
    method attribs {
            { 
                name       => $.name,
                base_class => $.base_class,
                block      => $.block,
            }
    };
}

class Method {
    has $.name;
    #has $.sig;
    has $.block;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Method',
            $path,
        );
    };
    method attribs {
            { 
                name    => $.name,
                #sig     => $.sig,
                block   => $.block,
            }
    };
}

class Sub {
    has $.name;
    #has $.sig;
    has @.block;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Sub',
            $path,
        );
    };
    method attribs {
            { 
                name    => $.name,
                #sig     => $.sig,
                block   => $.block,
            }
    };
}

class Token {
    has $.name;
    #has $.sig;
    has $.regex;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Token',
            $path,
        );
    };
    method attribs {
            { 
                name    => $.name,
                #sig     => $.sig,
                regex   => $.regex,
            }
    };
}

class Do {
    has @.block;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Do',
            $path,
        );
    };
    method attribs {
            { 
                block   => @.block,
            }
    };
}

class BEGIN {
    has @.block;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'BEGIN',
            $path,
        );
    };
    method attribs {
            { 
                block   => @.block,
            }
    };
}

class Use {
    has $.mod;
    has $.perl5;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Use',
            $path,
        );
    };
    method attribs {
            { 
                mod    => $.mod,
                perl5  => $.perl5,
            }
    };
}


# ------------- REGEX AST ----------


class Rule {
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule',
            $path,
        );
    };
    method attribs {
            { 
            }
    };
}

class Rule::Quantifier {
    has $.term;
    has $.quant;
    has $.greedy;
    has $.ws1;
    has $.ws2;
    has $.ws3;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::Quantifier',
            $path,
        );
    };
    method attribs {
            { 
                term   => $.term,
                quant  => $.quant,
                greedy => $.greedy,
                ws1    => $.ws1,
                ws2    => $.ws2,
                ws3    => $.ws3,
            }
    };
}

class Rule::Or {
    has @.or;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::Or',
            $path,
        );
    };
    method attribs {
            { 
                or   => $.or,
            }
    };
}

class Rule::Concat {
    has @.concat;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::Concat',
            $path,
        );
    };
    method attribs {
            { 
                concat => $.concat,
            }
    };
}

class Rule::Subrule {
    has $.metasyntax;
    has $.ident;
    has $.capture_to_array;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::Subrule',
            $path,
        );
    };
    method attribs {
            { 
                metasyntax   => $.metasyntax,
                ident        => $.ident,
                capture_to_array => $.capture_to_array,
            }
    };
}

class Rule::SubruleNoCapture {
    has $.metasyntax;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::SubruleNoCapture',
            $path,
        );
    };
    method attribs {
            { 
                metasyntax   => $.metasyntax,
            }
    };
}

class Rule::Var {
    has $.sigil;
    has $.twigil;
    has $.name;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::Var',
            $path,
        );
    };
    method attribs {
            { 
                sigil   => $.sigil,
                twigil  => $.twigil,
                name    => $.name,
            }
    };
}

class Rule::Constant {
    has $.constant;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::Constant',
            $path,
        );
    };
    method attribs {
            { 
                constant   => $.constant,
            }
    };
}

class Rule::Dot {
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::Dot',
            $path,
        );
    };
    method attribs {
            { 
            }
    };
}

class Rule::SpecialChar {
    has $.char;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::SpecialChar',
            $path,
        );
    };
    method attribs {
            { 
                char   => $.char,
            }
    };
}

class Rule::Block {
    has $.closure;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::Block',
            $path,
        );
    };
    method attribs {
            { 
                closure   => $.closure,
            }
    };
}

class Rule::InterpolateVar {
    has $.var;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::InterpolateVar',
            $path,
        );
    };
    method attribs {
            { 
                var   => $.var,
            }
    };
}

class Rule::NamedCapture {
    has $.rule;
    has $.ident;
    has $.capture_to_array;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::NamedCapture',
            $path,
        );
    };
    method attribs {
            { 
                rule   => $.rule,
                ident  => $.ident,
                capture_to_array => $.capture_to_array,
            }
    };
}

class Rule::Before {
    has $.rule;
    has $.assertion_modifier;
    has $.capture_to_array;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::Before',
            $path,
        );
    };
    method attribs {
            { 
                rule   => $.rule,
                capture_to_array   => $.capture_to_array,
                assertion_modifier => $.assertion_modifier,
            }
    };
}

class Rule::After {
    has $.rule;
    has $.assertion_modifier;
    has $.capture_to_array;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::After',
            $path,
        );
    };
    method attribs {
            { 
                rule   => $.rule,
                capture_to_array   => $.capture_to_array,
                assertion_modifier => $.assertion_modifier,
            }
    };
}

class Rule::NegateCharClass {
    has $.chars;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::NegateCharClass',
            $path,
        );
    };
    method attribs {
            { 
                chars   => $.chars,
            }
    };
}

class Rule::CharClass {
    has $.chars;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::CharClass',
            $path,
        );
    };
    method attribs {
            { 
                chars   => $.chars,
            }
    };
}

class Rule::Capture {
    has $.rule;
    has $.position;
    has $.capture_to_array;
    method emit( $visitor, $path ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Rule::Capture',
            $path,
        );
    };
    method attribs {
            { 
                rule     => $.rule,
                position => $.position,
                capture_to_array => $.capture_to_array,
            }
    };
}




=begin

=head1 NAME 

KindaPerl6::Traverse - Tree traverser for KindaPerl6 AST

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
