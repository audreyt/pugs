
use v6-alpha;

class KindaPerl6::Visitor::EmitLisp {

    # This visitor is a list emitter
    # TODO !!!
    
    method visit ( $node ) {
        $node.emit_lisp($.visitor_args{'secure'});
    };

}

class CompUnit {
    sub set_secure_mode( $args_secure ) {
        if ($args_secure != 0) {
            return '(pushnew :kp6-cl-secure *features*)' ~ Main::newline();
        } else {
            return '';
        }
    };

    method emit_lisp( $args_secure ) {
        my $interpreter := '|' ~ $.name ~ '|';

          ';; Do not edit this file - Lisp generated by ' ~ $Main::_V6_COMPILER_NAME ~ Main::newline()
        ~ '(in-package #:cl-user)' ~ Main::newline()
        ~ set_secure_mode($args_secure)
        ~ '(load "lib/KindaPerl6/Runtime/Lisp/Runtime.lisp")' ~ Main::newline()
        ~ '(defpackage #:' ~ $.name ~ Main::newline()
        ~ '  (:use #:cl #:kp6-cl))' ~ Main::newline()
        ~ '(in-package #:' ~ $.name ~ ')' ~ Main::newline()
        ~ '(defun Main ()' ~ Main::newline()
        ~ ' (with-kp6-interpreter (' ~ $interpreter ~')' ~ Main::newline()
        ~ '  (with-kp6-package (' ~ $interpreter ~ ' "GLOBAL")' ~ Main::newline()
	~ '   (with-kp6-pad (' ~ $interpreter ~ ')' ~ Main::newline()
        ~ $.body.emit_lisp($interpreter) ~ '))))' ~ Main::newline()
        # This is a function so (sb-ext:save-lisp-and-die) has
        # something to call into
        ~ '(Main::Main)' ~ Main::newline()
    }
}

class Val::Int {
    method emit_lisp ($interpreter) { 
        "(make-instance \'kp6-Int :value " ~ $.int ~ ")" ~ Main::newline();
    }
}

class Val::Bit {
    method emit_lisp ($interpreter) { 
        "(make-instance \'kp6-Bit :value " ~ $.bit ~ ")" ~ Main::newline();
    }
}

class Val::Num {
    method emit_lisp ($interpreter) { 
        "(make-instance \'kp6-Num :value " ~ $.num ~ ")" ~ Main::newline();
    }
}

class Val::Buf {
    method emit_lisp ($interpreter) { 
        "(make-instance \'kp6-Str :value " ~ '"' ~ Main::mangle_string( $.buf ) ~ '"' ~ ")" ~ Main::newline();
    }
}

class Val::Char {
    method emit_lisp ($interpreter) { 
        '(make-instance \'kp6-Char :value (code-char ' ~ $.char ~ '))'
    }
}

class Val::Undef {
    method emit_lisp ($interpreter) { 
        "(make-instance \'kp6-Undef)" ~ Main::newline();
    }
}

class Val::Object {
    method emit_lisp ($interpreter) {
        die 'Emitting of Val::Object not implemented';
        # 'bless(' ~ %.fields.perl ~ ', ' ~ $.class.perl ~ ')';
    }
}

class Native::Buf {
    method emit_lisp ($interpreter) { 
        die 'Emitting of Native::Buf not implemented';
        # '\'' ~ $.buf ~ '\''
    }
}

class Lit::Seq {
    method emit_lisp ($interpreter) {
        '(list ' ~ (@.seq.>>emit_lisp($interpreter)).join(' ') ~ ')';
    }
}

class Lit::Array {
    method emit_lisp ($interpreter) {
        "(make-instance \'kp6-Array :value (list " ~ (@.array.>>emit_lisp($interpreter)).join(' ') ~ "))" ~ Main::newline();
    }
}

class Lit::Hash {
    method emit_lisp ($interpreter) {
        my $fields := @.hash;
        my $str := '';
        my $field;
        for @$fields -> $field { 
            $str := $str ~ '  (kp6-STORE hash ' ~ ($field[0]).emit_lisp($interpreter) ~ ' ' ~ ($field[1]).emit_lisp($interpreter) ~ ')' ~ Main::newline();
        }; 
          '(let ((hash (make-instance \'kp6-Hash)))' ~ Main::newline()
        ~ $str ~ ' hash)'
        ~ Main::newline();
    }
}

class Lit::Pair {
    method emit_lisp ($interpreter) {
        "(make-instance \'kp6-pair :key " ~ $.key.emit_lisp($interpreter) ~ " :value " ~ $.value.emit_lisp($interpreter) ~ ")" ~ Main::newline();
    }
}

class Lit::NamedArgument {
    method emit_lisp ($interpreter) {
        "(make-instance \'kp6-named-argument :_argument_name_ " ~ $.key.emit_lisp($interpreter) ~ " :value " ~ $.value.emit_lisp($interpreter) ~ ")" ~ Main::newline();
    }
}

class Lit::Code {
    method emit_lisp ($interpreter) {
        self.emit_declarations($interpreter) ~ self.emit_body($interpreter);
    };
    method emit_body ($interpreter) {
        (@.body.>>emit_lisp($interpreter)).join(' ');
    };
    method emit_signature ($interpreter) {
        $.sig.emit_lisp($interpreter)
    };
    method emit_declarations ($interpreter) {
        my $s;
        my $name;
        for @($.pad.variable_names) -> $name {
            my $decl := ::Decl(
                decl => 'my',
                type => '',
                var  => ::Var(
                    sigil     => '',
                    twigil    => '',
                    name      => $name,
                    namespace => [ ],
                ),
            );
            $s := $s ~ $name.emit_lisp($interpreter) ~ ' ' ~ Main::newline();
        };
        return $s;
    };
    method emit_arguments ($interpreter) {
        my $array_  := ::Var( sigil => '@', twigil => '', name => '_',       namespace => [ ], );
        my $hash_   := ::Var( sigil => '%', twigil => '', name => '_',       namespace => [ ], );
        my $CAPTURE := ::Var( sigil => '$', twigil => '', name => 'CAPTURE', namespace => [ ],);
        my $CAPTURE_decl := ::Decl(decl=>'my',type=>'',var=>$CAPTURE);
        my $str := '';
        $str := $str ~ $CAPTURE_decl.emit_lisp($interpreter);
        $str := $str ~ '::DISPATCH_VAR($CAPTURE,"STORE",::CAPTURIZE(\@_));';

        my $bind_ := ::Bind(parameters=>$array_,arguments=>::Call(invocant => $CAPTURE,method => 'array',arguments => []));
        $str := $str ~ $bind_.emit_lisp($interpreter) ~ ' ';

        my $bind_hash := 
                     ::Bind(parameters=>$hash_, arguments=>::Call(invocant => $CAPTURE,method => 'hash', arguments => []));
        $str := $str ~ $bind_hash.emit_lisp($interpreter) ~ ' ';

        my $i := 0;
        my $field;
        for @($.sig.positional) -> $field { 
            my $bind := ::Bind(parameters=>$field,arguments=>::Index(obj=> $array_ , 'index'=>::Val::Int(int=>$i)) );
            $str := $str ~ $bind.emit_lisp($interpreter) ~ ' ';
            $i := $i + 1;
        };

        return $str;
    };
}

class Lit::Object {
    method emit_lisp ($interpreter) {
        # $.class ~ '->new( ' ~ @.fields.>>emit_lisp.join(', ') ~ ' )';
        my $fields := @.fields;
        my $str := '';
        # say @fields.map(sub { $_[0].emit_lisp ~ ' => ' ~ $_[1].emit_lisp}).join(', ') ~ ')';
        my $field;
        for @$fields -> $field { 
            $str := $str ~ ($field[0]).emit_lisp($interpreter) ~ ' => ' ~ ($field[1]).emit_lisp($interpreter) ~ ',';
        }; 
        '(kp6-new \'kp6-' ~ $.class ~ ' ' ~ $str ~ ')' ~ Main::newline();
    }
}

class Index {
    method emit_lisp ($interpreter) {
        '(kp6-lookup ' ~ $.obj.emit_lisp($interpreter) ~ ' (perl->cl ' ~ $.index.emit_lisp($interpreter) ~ '))' ~ Main::newline()
    }
}

class Lookup {
    method emit_lisp ($interpreter) {
	# XXX since we don't have a proper ::Index object which takes care of PERL->CL, we have to do it ourselves
	#'(kp6-lookup ' ~ $.obj.emit_lisp ~ ' ' ~ $.index.emit_lisp ~ ')'
        '(kp6-lookup ' ~ $.obj.emit_lisp($interpreter) ~ ' (perl->cl ' ~ $.index.emit_lisp($interpreter) ~ '))'
    }
}

class Assign {
    method emit_lisp ($interpreter) {
        # TODO - same as ::Bind
        
        my $node := $.parameters;
        
#         if $node.isa( 'Var' ) && @($node.namespace)     
#         {
#             # it's a global, 
#             # and it should be autovivified

#             $node :=
#                 ::Apply(
#                     code => ::Var(
#                         name      => 'ternary:<?? !!>',
#                         twigil    => '',
#                         sigil     => '&',
#                         namespace => [ 'GLOBAL' ],
#                     ),
#                     arguments => [
#                        ::Apply(
#                             arguments => [ $node ],
#                             code => ::Var( name => 'VAR_defined', twigil => '', sigil => '&', namespace => [ 'GLOBAL' ] ),
#                         ),
#                         $node,
#                         ::Bind(
#                             'parameters' => $node,  
#                             'arguments'  => ::Call(
#                                 'invocant' => ::Var( name => '::Scalar', twigil => '', sigil => '$', namespace => [ ] ),  
#                                 'method'   => 'new',
#                                 'hyper'    => '',
#                             ),
#                         )
#                     ],
#                 );

#         };

	'(setf ' ~ $node.emit_lisp($interpreter) ~ ' ' ~ $.arguments.emit_lisp($interpreter) ~ ')';
    }
}

class Var {
    method emit_lisp ($interpreter) {
	my $namespace := $.namespace;
	if !(@($namespace)) {
	    return '(kp6-lookup (kp6-lookup (kp6-packages ' ~ $interpreter ~ ') "GLOBAL") (kp6-generate-variable "' ~ $.sigil ~ '" "' ~ $.name ~ '"))';
	}

	return '(kp6-lookup (kp6-lookup (kp6-packages ' ~ $interpreter ~ ') "' ~ (join '::', @($namespace)) ~ '") (kp6-generate-variable "' ~ $.sigil ~ '" "' ~ $.name ~ '"))';
    };

    method perl {
        # this is used by the signature emitter
          '(kp6-new \'signature-item ' 
        ~     'sigil: \'' ~ $.sigil  ~ '\', '
        ~     'twigil: \'' ~ $.twigil ~ '\', '
        ~     'name: \'' ~ $.name   ~ '\', '
        ~     'namespace: [ ], '
        ~ ')' ~ Main::newline()
    }
}

class Bind {
    method emit_lisp ($interpreter) {
    
        # XXX - replace Bind with Assign
        if $.parameters.isa('Call') 
        {
            return ::Assign(parameters=>$.parameters,arguments=>$.arguments).emit_lisp($interpreter);
        };
        if $.parameters.isa('Lookup') {
            return ::Assign(parameters=>$.parameters,arguments=>$.arguments).emit_lisp($interpreter);
        };
        if $.parameters.isa('Index') {
            return ::Assign(parameters=>$.parameters,arguments=>$.arguments).emit_lisp($interpreter);
        };

        my $str := '';
        $str := $str ~ '(setf ' ~ $.parameters.emit_lisp($interpreter) ~ ' ' ~ $.arguments.emit_lisp($interpreter) ~ ')';
        return $str;
    }
}

class Proto {
    method emit_lisp ($interpreter) {
        return '\''~$.name;   # ???
    }
}

class Call {
    method emit_lisp ($interpreter) {
        my $invocant;
        if $.invocant.isa( 'Proto' ) {

            if $.invocant.name eq 'self' {
                $invocant := '$self';
            }
            else {
                $invocant := $.invocant.emit_lisp($interpreter);
            }
            
        }
        else {
            $invocant := $.invocant.emit_lisp($interpreter);
        };
        if $invocant eq 'self' {
            $invocant := '$self';
        };
        
        my $meth := $.method;
        if  $meth eq 'postcircumfix:<( )>'  {
             $meth := '';  
        };
        
        my $call := (@.arguments.>>emit_lisp($interpreter)).join(' ');
        if ($.hyper) {
            # TODO - hyper + role
            '[ map { $_' ~ '->' ~ $meth ~ '(' ~ $call ~ ') } @{ ' ~ $invocant ~ ' } ]' ~ Main::newline();
        }
        else {
            if ( $meth eq '' ) {
                # $var.()
                '(kp6-APPLY \'' ~ $invocant ~ ' (list ' ~ $call ~ '))' ~ Main::newline()
            }
            else {
                '(' ~ $meth ~ ' \'' ~ $invocant ~ ' (list ' ~ $call ~ '))' ~ Main::newline()
            };
        };
        

    }
}

class Apply {
    method emit_lisp ($interpreter) {
        if     ( $.code.isa( 'Var' ) && $.code.name eq 'self' )
            # && ( @.arguments.elems == 0 )
        {
            return '$self';
        }

	my $name := $.code.name;

	if ($name eq 'infix:<&&>') {
	    return '(and (perl->cl ' ~ (@.arguments.>>emit_lisp($interpreter)).join(') (perl->cl ') ~ '))';
	}

	if ($name eq 'infix:<||>') {
	    return '(or (perl->cl ' ~ (@.arguments.>>emit_lisp($interpreter)).join(') (perl->cl ') ~ '))';
	}

	if ($name eq 'ternary:<?? !!>') {
	    return '(if (kp6-true ' ~ (@.arguments[0]).emit_lisp($interpreter) ~ ') (progn ' ~ (@.arguments[1]).emit_lisp($interpreter) ~ ') (progn ' ~ (@.arguments[2]).emit_lisp($interpreter) ~ '))';
	}

        my $op := $.code.emit_lisp($interpreter);

        return  '(kp6-apply-function ' ~ $interpreter ~ ' (perl->cl ' ~ $op ~ ') (mapcar #\'cl->perl (list ' ~ (@.arguments.>>emit_lisp($interpreter)).join(' ') ~ ')))' ~ Main::newline();
    }
}

class Return {
    method emit_lisp ($interpreter) {
        return
        #'do { print Main::perl(caller(),' ~ $.result.emit_lisp ~ '); return(' ~ $.result.emit_lisp ~ ') }';
        'return(' ~ $.result.emit_lisp($interpreter) ~ ')' ~ Main::newline();
    }
}

class If {
    method emit_lisp ($interpreter) {
        #'do { if (::DISPATCH(::DISPATCH(' ~ $.cond.emit_lisp ~ ',"true"),"p5landish") ) ' 
        # XXX: Cast the value to a true/false in lisp
        '(if (kp6-true ' ~ $.cond.emit_lisp($interpreter) ~ ')'
        ~ ( $.body 
            ?? '(progn ' ~ $.body.emit_lisp($interpreter) ~ ') '
            !! '(progn)'
          )
        ~ ( $.otherwise 
            ?? ' (progn ' ~ $.otherwise.emit_lisp($interpreter) ~ ' )' 
            !! '(progn)' 
          )
        ~ ' )' ~ Main::newline();
    }
}

class For {
    method emit_lisp ($interpreter) {
        my $cond := $.cond;
        if   $cond.isa( 'Var' ) 
          && $cond.sigil eq '@' 
        {
        } else {
            $cond := ::Apply( code => ::Var(sigil=>'&',twigil=>'',name=>'prefix:<@>',namespace => [ 'GLOBAL' ],), arguments => [$cond] );
        }
        'for ' 
        ~   $.topic.emit_lisp($interpreter) 
        ~ ' ( @{ ' ~ $cond.emit_lisp($interpreter) ~ '->{_value}{_array} } )'
        ~ ' { ' 
        ~     $.body.emit_lisp($interpreter) 
        ~ ' } '
        ~ Main::newline();
    }
}

class While {
    method emit_lisp ($interpreter) {
        my $cond := $.cond;
        if   $cond.isa( 'Var' ) 
          && $cond.sigil eq '@' 
        {
        } else {
            $cond := ::Apply( code => ::Var(sigil=>'&',twigil=>'',name=>'prefix:<@>',namespace => [ 'GLOBAL' ],), arguments => [$cond] );
        }
        'do { while (::DISPATCH(::DISPATCH(' ~ $.cond.emit_lisp($interpreter) ~ ',"true"),"p5landish") ) ' 
        ~ ' { ' 
        ~     $.body.emit_lisp($interpreter) 
        ~ ' } }'
        ~ Main::newline();
    }
}

class Decl {
    method emit_lisp ($interpreter) {
        my $decl := $.decl;
        my $name := $.var.name;

	if $decl eq 'our' {
	    return '(define-package-variable (kp6-generate-variable "' ~ $.var.sigil ~ '" "' ~ $name ~ '"))';
	}
	if $decl eq 'my' {
	    return '(define-lexical-variable (kp6-generate-variable "' ~ $.var.sigil ~ '" "' ~ $name ~ '"))';
	}

	return '(kp6-error ' ~ $interpreter ~ ' \'kp6-not-implemented :feature "\\"' ~ $decl ~ '\\" variables")';

        if $decl eq 'has' {
            return 'sub ' ~ $name ~ ' { ' ~
            '@_ == 1 ' ~
                '? ( $_[0]->{' ~ $name ~ '} ) ' ~
                ': ( $_[0]->{' ~ $name ~ '} = $_[1] ) ' ~
            '}';
        };
        my $create := ', \'new\', { modified => $_MODIFIED, name => \'' ~ $.var.emit_lisp($interpreter) ~ '\' } ) ';
        if $decl eq 'our' {
            my $s;
            # ??? use vars --> because compile-time scope is too tricky to use 'our'
            # ??? $s := 'use vars \'' ~ $.var.emit_lisp ~ '\'; ';  
            $s := 'our ';

            if ($.var).sigil eq '$' {
                return $s 
                    ~ $.var.emit_lisp($interpreter)
                    ~ ' = ::DISPATCH( $::Scalar' ~ $create
                    ~ ' unless defined ' ~ $.var.emit_lisp($interpreter) ~ '; '
                    ~ 'BEGIN { '
                    ~     $.var.emit_lisp($interpreter)
                    ~     ' = ::DISPATCH( $::Scalar' ~ $create
                    ~     ' unless defined ' ~ $.var.emit_lisp($interpreter) ~ '; '
                    ~ '}' ~ Main::newline()
            };
            if ($.var).sigil eq '&' {
                return $s 
                    ~ $.var.emit_lisp($interpreter)
                    ~ ' = ::DISPATCH( $::Routine' ~ $create ~ ';' ~ Main::newline();
            };
            if ($.var).sigil eq '%' {
                return $s ~ $.var.emit_lisp($interpreter)
                    ~ ' = ::DISPATCH( $::Hash' ~ $create ~ ';' ~ Main::newline();
            };
            if ($.var).sigil eq '@' {
                return $s ~ $.var.emit_lisp($interpreter)
                    ~ ' = ::DISPATCH( $::Array' ~ $create ~ ';' ~ Main::newline();
            };
            return $s ~ $.var.emit_lisp($interpreter) ~ Main::newline();
        };
        if ($.var).sigil eq '$' {
            return 
                  $.decl ~ ' ' 
                # ~ $.type ~ ' ' 
                ~ $.var.emit_lisp($interpreter) ~ '; '
                ~ $.var.emit_lisp($interpreter)
                ~ ' = ::DISPATCH( $::Scalar' ~ $create
                ~ ' unless defined ' ~ $.var.emit_lisp($interpreter) ~ '; '
                ~ 'BEGIN { '
                ~     $.var.emit_lisp($interpreter)
                ~     ' = ::DISPATCH( $::Scalar' ~ $create
                ~ '}'
                ~ Main::newline()
                ;
        };
        if ($.var).sigil eq '&' {
            return 
                  $.decl ~ ' ' 
                # ~ $.type ~ ' ' 
                ~ $.var.emit_lisp($interpreter) ~ '; '
                ~ $.var.emit_lisp($interpreter)
                ~ ' = ::DISPATCH( $::Routine' ~ $create
                ~ ' unless defined ' ~ $.var.emit_lisp($interpreter) ~ '; '
                ~ 'BEGIN { '
                ~     $.var.emit_lisp($interpreter)
                ~     ' = ::DISPATCH( $::Routine' ~ $create
                ~ '}'
                ~ Main::newline()
                ;
        };
        if ($.var).sigil eq '%' {
            return $.decl ~ ' ' 
                # ~ $.type 
                ~ ' ' ~ $.var.emit_lisp($interpreter)
                ~ ' = ::DISPATCH( $::Hash' ~ $create ~ '; '
                ~ Main::newline();
        };
        if ($.var).sigil eq '@' {
            return $.decl ~ ' ' 
                # ~ $.type 
                ~ ' ' ~ $.var.emit_lisp($interpreter)
                ~ ' = ::DISPATCH( $::Array' ~ $create ~ '; '
                ~ Main::newline();
        };
        return $.decl ~ ' ' 
            # ~ $.type ~ ' ' 
            ~ $.var.emit_lisp($interpreter);
    }
}

class Sig {
    method emit_lisp ($interpreter) {
        my $inv := '$::Undef';
        if $.invocant.isa( 'Var' ) {
            $inv := $.invocant.perl;
        }
            
        my $pos;
        my $decl;
        for @($.positional) -> $decl {
            $pos := $pos ~ $decl.perl ~ ', ';
        };

        my $named := '';  # TODO

          '(kp6-new \'signature '
        ~     'invocant: ' ~ $inv ~ ', '
        ~     'array: ::DISPATCH( $::Array, "new", { _array => [ ' ~ $pos   ~ ' ] } ), '
        ~     'hash: ::DISPATCH( $::Hash,  "new", { _hash  => { ' ~ $named ~ ' } } ), '
        ~     'return: $::Undef, '
        ~ ')'
        ~ Main::newline();
    };
}

class Capture {
    method emit_lisp ($interpreter) {
        my $s := '(kp6-new \'capture ';
        if defined $.invocant {
           $s := $s ~ 'invocant: ' ~ $.invocant.emit_lisp($interpreter) ~ ', ';
        }
        else {
            $s := $s ~ 'invocant: $::Undef, '
        };
        if defined $.array {
           $s := $s ~ 'array: ::DISPATCH( $::Array, "new", { _array => [ ';
                            my $item;
           for @.array -> $item { 
                $s := $s ~ $item.emit_lisp($interpreter) ~ ', ';
            }
            $s := $s ~ ' ] } ),';
        };
        if defined $.hash {
           $s := $s ~ 'hash: ::DISPATCH( $::Hash, "new", { _hash => { ';
                           my $item;
           for @.hash -> $item { 
                $s := $s ~ ($item[0]).emit_lisp($interpreter) ~ '->{_value} => ' ~ ($item[1]).emit_lisp($interpreter) ~ ', ';
            }
            $s := $s ~ ' } } ),';
        };
        return $s ~ ')' ~ Main::newline();
    };
}

class Subset {
    method emit_lisp ($interpreter) {
          '(kp6-new \'subset ' 
        ~ 'base_class: ' ~ $.base_class.emit_lisp($interpreter) 
        ~ ', '
        ~ 'block: '    
        ~       'sub { local $_ = shift; ' ~ ($.block.block).emit_lisp($interpreter) ~ ' } '    # XXX
        ~ ')' ~ Main::newline();
    }
}

class Method {
    method emit_lisp ($interpreter) {
          '(kp6-new \'code '
        ~   'code: sub { '  
        ~     $.block.emit_declarations($interpreter) 
        ~     '$self = shift; ' 
        ~     $.block.emit_arguments($interpreter) 
        ~     $.block.emit_body($interpreter)
        ~    ' '
        ~   'signature: ' 
        ~       $.block.emit_signature($interpreter)
        ~ ')' 
        ~ Main::newline();
    }
}

class Sub {
    method emit_lisp ($interpreter) {
          '(kp6-new \'code '
        ~   'code: sub { '  
        ~       $.block.emit_declarations($interpreter) 
        ~       $.block.emit_arguments($interpreter) 
        ~       $.block.emit_body($interpreter)
        ~    ' } '
        ~   'signature: ' 
        ~       $.block.emit_signature($interpreter)
        ~ ')' 
        ~ Main::newline();
    }
}

class Do {
    # Everything's an expression in lisp so do {} is implicit:)
    method emit_lisp ($interpreter) {
        $.block.emit_lisp($interpreter) ~ Main::newline();
    }
}

class BEGIN {
    method emit_lisp ($interpreter) {
        'BEGIN { ' ~ 
          $.block.emit_lisp($interpreter) ~ 
        ' }'
    }
}

class Use {
    method emit_lisp ($interpreter) {
        if ($.mod eq 'v6') {
            return Main::newline() ~ '#use v6' ~ Main::newline();
        }
        if ( $.perl5 ) {
            return 'use ' ~ $.mod ~ ';$::' ~ $.mod ~ '= KindaPerl6::Runtime::Perl5::Wrap::use5(\'' ~ $.mod ~ '\')';
        } else {
            return 'use ' ~ $.mod;
        }
    }
}

=begin

=head1 NAME 

KindaPerl6::Perl5::Lisp - Code generator for KindaPerl6-in-Lisp

=head1 DESCRIPTION

This module generates Lisp code for the KindaPerl6 compiler.

=head1 AUTHORS

The Pugs Team E<lt>perl6-compiler@perl.orgE<gt>.

=head1 SEE ALSO

The Perl 6 homepage at L<http://dev.perl.org/perl6>.

The Pugs homepage at L<http://pugscode.org/>.

=head1 COPYRIGHT

Copyright 2007 by Flavio Soibelmann Glock and others.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=end
