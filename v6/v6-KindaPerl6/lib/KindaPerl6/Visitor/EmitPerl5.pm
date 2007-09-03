
use v6-alpha;

class KindaPerl6::Visitor::EmitPerl5 {

    # This visitor is a perl5 emitter
    
    method visit ( $node ) {
        $node.emit_perl5($.visitor_args{'secure'});
    };

}

class CompUnit {
    sub set_secure_mode( $args_secure ) {
        my $value := '0';
        if ($args_secure != 0) { $value := '1' };
        return 'use constant KP6_DISABLE_INSECURE_CODE => ' ~ $value ~ ';' ~ Main::newline();
    };

    method emit_perl5( $args_secure ) {
          '{ package ' ~ $.name ~ '; ' ~ Main::newline()
        ~ '# Do not edit this file - Perl 5 generated by ' ~ $Main::_V6_COMPILER_NAME ~ Main::newline()
        ~ 'use v5;' ~ Main::newline()
        ~ 'use strict;' ~ Main::newline()
        ~ 'no strict \'vars\';' ~ Main::newline()
        ~ set_secure_mode($args_secure)
        ~ 'use KindaPerl6::Runtime::Perl5::Runtime;' ~ Main::newline()
        #~ 'use KindaPerl6::Runtime::Perl6::Hash; '
        ~ 'my $_MODIFIED; BEGIN { $_MODIFIED = {} }' ~ Main::newline()

        # XXX - not sure about $_ scope
        ~ 'BEGIN { '
        ~   '$_ = ::DISPATCH($::Scalar, "new", { modified => $_MODIFIED, name => "$_" } ); '
        ~ '}' ~ Main::newline()

        ~ $.body.emit_perl5 ~ Main::newline()
        ~ '; 1 }' ~ Main::newline();
    }
}

class Val::Int {
    method emit_perl5 { 
        # $.int 
        '::DISPATCH( $::Int, \'new\', ' ~ $.int ~ ' )' ~ Main::newline();
    }
}

class Val::Bit {
    method emit_perl5 { 
        # $.bit 
        '::DISPATCH( $::Bit, \'new\', ' ~ $.bit ~ ' )' ~ Main::newline();
    }
}

class Val::Num {
    method emit_perl5 { 
        #$.num 
        '::DISPATCH( $::Num, \'new\', ' ~ $.num ~ ' )' ~ Main::newline();
    }
}

class Val::Buf {
    method emit_perl5 { 
        # '\'' ~ $.buf ~ '\'' 
        '::DISPATCH( $::Str, \'new\', ' ~ Main::singlequote() ~ Main::mangle_string( $.buf ) ~ Main::singlequote ~ ' )' ~ Main::newline();
    }
}

class Val::Undef {
    method emit_perl5 { 
        #'(undef)' 
        '$::Undef'
    }
}

class Val::Object {
    method emit_perl5 {
        die 'Emitting of Val::Object not implemented';
        # 'bless(' ~ %.fields.perl ~ ', ' ~ $.class.perl ~ ')';
    }
}

class Native::Buf {
    method emit_perl5 { 
        die 'Emitting of Native::Buf not implemented';
        # '\'' ~ $.buf ~ '\''
    }
}

class Lit::Seq {
    method emit_perl5 {
        '(' ~ (@.seq.>>emit_perl5).join(', ') ~ ')';
    }
}

class Lit::Array {
    method emit_perl5 {
        '::DISPATCH( $::Array, "new", { _array => [' ~ (@.array.>>emit_perl5).join(', ') ~ '] } )' ~ Main::newline();
    }
}

class Lit::Hash {
    method emit_perl5 {
        my $fields := @.hash;
        my $str := '';
        for @$fields -> $field { 
            $str := $str ~ ($field[0]).emit_perl5 ~ '->{_value} => ' ~ ($field[1]).emit_perl5 ~ ',';
        }; 
        '::DISPATCH( $::Hash, "new", { _hash => { ' ~ $str ~ ' } } )' ~ Main::newline();
    }
}

class Lit::Pair {
    method emit_perl5 {
        '::DISPATCH( $::Pair, \'new\', ' 
        ~ '{ key => '   ~ $.key.emit_perl5
        ~ ', value => ' ~ $.value.emit_perl5
        ~ ' } )' ~ Main::newline();
    }
}

class Lit::Code {
    method emit_perl5 {
        self.emit_declarations ~ self.emit_body;
    };
    method emit_body {
        (@.body.>>emit_perl5).join('; ');
    };
    method emit_signature {
        $.sig.emit_perl5
    };
    method emit_declarations {
        my $s;
        for @($.pad.variable_names) -> $name {
            my $decl := ::Decl(
                decl => 'my',
                type => '',
                var  => ::Var(
                    sigil => '',
                    twigil => '',
                    name => $name,
                ),
            );
            $s := $s ~ $name.emit_perl5 ~ ';' ~ Main::newline();
        };
        return $s;
    };
    method emit_arguments {
        my $array_ := ::Var( sigil => '@', twigil => '', name => '_' );
        my $CAPTURE := ::Var( sigil => '$', twigil => '', name => 'CAPTURE');
        my $CAPTURE_decl := ::Decl(decl=>'my',type=>'',var=>$CAPTURE);
        my $str := '';
        $str := $str ~ $CAPTURE_decl.emit_perl5;
        $str := $str ~ '::DISPATCH_VAR($CAPTURE,"STORE",::CAPTURIZE(\@_));';

        my $bind_ := ::Bind(parameters=>$array_,arguments=>::Call(invocant => $CAPTURE,method => 'array',arguments => []));
        $str := $str ~ $bind_.emit_perl5 ~ ';';

        my $i := 0;
        for @($.sig.positional) -> $field { 
            my $bind := ::Bind(parameters=>$field,arguments=>::Index(obj=> $array_ , 'index'=>::Val::Int(int=>$i)) );
            $str := $str ~ $bind.emit_perl5 ~ ';';
            $i := $i + 1;
        };

        return $str;
    };
}

class Lit::Object {
    method emit_perl5 {
        # $.class ~ '->new( ' ~ @.fields.>>emit_perl5.join(', ') ~ ' )';
        my $fields := @.fields;
        my $str := '';
        # say @fields.map(sub { $_[0].emit_perl5 ~ ' => ' ~ $_[1].emit_perl5}).join(', ') ~ ')';
        for @$fields -> $field { 
            $str := $str ~ ($field[0]).emit_perl5 ~ ' => ' ~ ($field[1]).emit_perl5 ~ ',';
        }; 
        '::DISPATCH( $::' ~ $.class ~ ', \'new\', ' ~ $str ~ ' )' ~ Main::newline();
    }
}

class Index {
    method emit_perl5 {
        '::DISPATCH( ' ~ $.obj.emit_perl5 ~ ', \'INDEX\', ' ~ $.index.emit_perl5 ~ ' )' ~ Main::newline();
    }
}

class Lookup {
    method emit_perl5 {
        '::DISPATCH( ' ~ $.obj.emit_perl5 ~ ', \'LOOKUP\', ' ~ $.index.emit_perl5 ~ ' )' ~ Main::newline();
    }
}

class Assign {
    method emit_perl5 {
        # TODO - same as ::Bind
        '::DISPATCH_VAR( ' ~ $.parameters.emit_perl5 ~ ', \'STORE\', ' ~ $.arguments.emit_perl5 ~ ' )' ~ Main::newline();
    }
}

class Var {
    method emit_perl5 {
        # Normalize the sigil here into $
        # $x    => $x
        # @x    => $List_x
        # %x    => $Hash_x
        # &x    => $Code_x
        my $table := {
            '$' => '$',
            '@' => '$List_',
            '%' => '$Hash_',
            '&' => '$Code_',
        };
        
        if $.twigil eq '.' {
            return '::DISPATCH( $self, "' ~ $.name ~ '" )'  ~ Main::newline()
        };
        
        if $.name eq '/' {
            return $table{$.sigil} ~ 'MATCH' 
        };
        
        return Main::mangle_name( $.sigil, $.twigil, $.name ); 
    };
    method perl {
        # this is used by the signature emitter
          '::DISPATCH( $::Signature::Item, "new", { ' 
        ~     'sigil  => \'' ~ $.sigil  ~ '\', '
        ~     'twigil => \'' ~ $.twigil ~ '\', '
        ~     'name   => \'' ~ $.name   ~ '\', '
        ~ '} )' ~ Main::newline()
    }
}

class Bind {
    method emit_perl5 {
        my $str := '::MODIFIED(' ~ $.parameters.emit_perl5 ~ ');' ~ Main::newline();
        $str := $str ~ $.parameters.emit_perl5 ~ ' = ' ~ $.arguments.emit_perl5;
        return 'do {'~$str~'}';
    }
}

class Proto {
    method emit_perl5 {
        return '$::'~$.name;
    }
}

class Call {
    method emit_perl5 {
        my $invocant;
        if $.invocant.isa( 'Proto' ) {

            if $.invocant.name eq 'self' {
                $invocant := '$self';
            }
            else {
                $invocant := $.invocant.emit_perl5;
            }
            
        }
        else {
            $invocant := $.invocant.emit_perl5;
        };
        if $invocant eq 'self' {
            $invocant := '$self';
        };
        if     ($.method eq 'yaml')
            # || ($.method eq 'join')
            || ($.method eq 'chars')
            # || ($.method eq 'isa')
        { 
            if ($.hyper) {
                return 
                    '[ map { Main::' ~ $.method ~ '( $_, ' ~ ', ' ~ (@.arguments.>>emit_perl5).join(', ') ~ ')' ~ ' } @{ ' ~ $invocant ~ ' } ]';
            }
            else {
                return
                    'Main::' ~ $.method ~ '(' ~ $invocant ~ ', ' ~ (@.arguments.>>emit_perl5).join(', ') ~ ')' ~ Main::newline();
            }
        };

        my $meth := $.method;
        if  $meth eq 'postcircumfix:<( )>'  {
             $meth := '';  
        };
        
        my $call := (@.arguments.>>emit_perl5).join(', ');
        if ($.hyper) {
            # TODO - hyper + role
            '[ map { $_' ~ '->' ~ $meth ~ '(' ~ $call ~ ') } @{ ' ~ $invocant ~ ' } ]' ~ Main::newline();
        }
        else {
            if ( $meth eq '' ) {
                # $var.()
                '::DISPATCH( ' ~ $invocant ~ ', \'APPLY\', ' ~ $call ~ ' )' ~ Main::newline()
            }
            else {
                  '::DISPATCH( ' 
                ~ $invocant ~ ', '
                ~ '\'' ~ $meth ~ '\', '
                ~ $call
                ~ ' )' 
                ~ Main::newline()
            };
        };
        

    }
}

class Apply {
    method emit_perl5 {
        if     ( $.code.name eq 'self' )
            # && ( @.arguments.elems == 0 )
        {
            return '$self';
        }
        return  '::DISPATCH( ' ~ $.code.emit_perl5 ~ ', \'APPLY\', ' ~ (@.arguments.>>emit_perl5).join(', ') ~ ' )' ~ Main::newline();
    }
}

class Return {
    method emit_perl5 {
        return
        #'do { print Main::perl(caller(),' ~ $.result.emit_perl5 ~ '); return(' ~ $.result.emit_perl5 ~ ') }';
        'return(' ~ $.result.emit_perl5 ~ ')' ~ Main::newline();
    }
}

class If {
    method emit_perl5 {
        'do { if (::DISPATCH(::DISPATCH(' ~ $.cond.emit_perl5 ~ ',"true"),"p5landish") ) ' 
        ~ ( $.body 
            ?? '{ ' ~ $.body.emit_perl5 ~ ' } '
            !! '{ } '
          )
        ~ ( $.otherwise 
            ?? ' else { ' ~ $.otherwise.emit_perl5 ~ ' }' 
            !! '' 
          )
        ~ ' }' ~ Main::newline();
    }
}

class For {
    method emit_perl5 {
        my $cond := $.cond;
        if   $cond.isa( 'Var' ) 
          && $cond.sigil eq '@' 
        {
        } else {
            $cond := ::Apply( code => ::Var(sigil=>'&',twigil=>'',name=>'GLOBAL::prefix:<@>'), arguments => [$cond] );
        }
        'do { for my ' ~ $.topic.emit_perl5 
            ~ ' ( @{ ' ~ $cond.emit_perl5 ~ '->{_value}{_array} } )'
            ~ ' { ' 
            ~     $.body.emit_perl5 
            ~ ' } '
        ~ '}' ~ Main::newline();
    }
}

class Decl {
    method emit_perl5 {
        my $decl := $.decl;
        my $name := $.var.name;
        if $decl eq 'has' {
            return 'sub ' ~ $name ~ ' { ' ~
            '@_ == 1 ' ~
                '? ( $_[0]->{' ~ $name ~ '} ) ' ~
                ': ( $_[0]->{' ~ $name ~ '} = $_[1] ) ' ~
            '}';
        };
        my $create := ', \'new\', { modified => $_MODIFIED, name => \'' ~ $.var.emit_perl5 ~ '\' } ) ';
        if $decl eq 'our' {
            my $s;
            # ??? use vars --> because compile-time scope is too tricky to use 'our'
            # ??? $s := 'use vars \'' ~ $.var.emit_perl5 ~ '\'; ';  
            $s := 'our ';

            if ($.var).sigil eq '$' {
                return $s 
                    ~ $.var.emit_perl5
                    ~ ' = ::DISPATCH( $::Scalar' ~ $create
                    ~ ' unless defined ' ~ $.var.emit_perl5 ~ '; '
                    ~ 'BEGIN { '
                    ~     $.var.emit_perl5
                    ~     ' = ::DISPATCH( $::Scalar' ~ $create
                    ~     ' unless defined ' ~ $.var.emit_perl5 ~ '; '
                    ~ '}' ~ Main::newline()
            };
            if ($.var).sigil eq '&' {
                return $s 
                    ~ $.var.emit_perl5
                    ~ ' = ::DISPATCH( $::Routine' ~ $create ~ ';' ~ Main::newline();
            };
            if ($.var).sigil eq '%' {
                return $s ~ $.var.emit_perl5
                    ~ ' = ::DISPATCH( $::Hash' ~ $create ~ ';' ~ Main::newline();
            };
            if ($.var).sigil eq '@' {
                return $s ~ $.var.emit_perl5
                    ~ ' = ::DISPATCH( $::Array' ~ $create ~ ';' ~ Main::newline();
            };
            return $s ~ $.var.emit_perl5 ~ Main::newline();
        };
        if ($.var).sigil eq '$' {
            return 
                  $.decl ~ ' ' 
                # ~ $.type ~ ' ' 
                ~ $.var.emit_perl5 ~ '; '
                ~ $.var.emit_perl5
                ~ ' = ::DISPATCH( $::Scalar' ~ $create
                ~ ' unless defined ' ~ $.var.emit_perl5 ~ '; '
                ~ 'BEGIN { '
                ~     $.var.emit_perl5
                ~     ' = ::DISPATCH( $::Scalar' ~ $create
                ~ '}'
                ~ Main::newline()
                ;
        };
        if ($.var).sigil eq '&' {
            return 
                  $.decl ~ ' ' 
                # ~ $.type ~ ' ' 
                ~ $.var.emit_perl5 ~ '; '
                ~ $.var.emit_perl5
                ~ ' = ::DISPATCH( $::Routine' ~ $create
                ~ ' unless defined ' ~ $.var.emit_perl5 ~ '; '
                ~ 'BEGIN { '
                ~     $.var.emit_perl5
                ~     ' = ::DISPATCH( $::Routine' ~ $create
                ~ '}'
                ~ Main::newline()
                ;
        };
        if ($.var).sigil eq '%' {
            return $.decl ~ ' ' 
                # ~ $.type 
                ~ ' ' ~ $.var.emit_perl5
                ~ ' = ::DISPATCH( $::Hash' ~ $create ~ '; '
                ~ Main::newline();
        };
        if ($.var).sigil eq '@' {
            return $.decl ~ ' ' 
                # ~ $.type 
                ~ ' ' ~ $.var.emit_perl5
                ~ ' = ::DISPATCH( $::Array' ~ $create ~ '; '
                ~ Main::newline();
        };
        return $.decl ~ ' ' 
            # ~ $.type ~ ' ' 
            ~ $.var.emit_perl5;
    }
}

class Sig {
    method emit_perl5 {
        my $inv := '$::Undef';
        if $.invocant.isa( 'Var' ) {
            $inv := $.invocant.perl;
        }
            
        my $pos;
        for @($.positional) -> $decl {
            $pos := $pos ~ $decl.perl ~ ', ';
        };

        my $named := '';  # TODO

          '::DISPATCH( $::Signature, "new", { '
        ~     'invocant => ' ~ $inv ~ ', '
        ~     'array    => ::DISPATCH( $::Array, "new", { _array => [ ' ~ $pos   ~ ' ] } ), '
        ~     'hash     => ::DISPATCH( $::Hash,  "new", { _hash  => { ' ~ $named ~ ' } } ), '
        ~     'return   => $::Undef, '
        ~ '} )'
        ~ Main::newline();
    };
}

class Capture {
    method emit_perl5 {
        my $s := '::DISPATCH( $::Capture, "new", { ';
        if defined $.invocant {
           $s := $s ~ 'invocant => ' ~ $.invocant.emit_perl5 ~ ', ';
        }
        else {
            $s := $s ~ 'invocant => $::Undef, '
        };
        if defined $.array {
           $s := $s ~ 'array => ::DISPATCH( $::Array, "new", { _array => [ ';
           for @.array -> $item { 
                $s := $s ~ $item.emit_perl5 ~ ', ';
            }
            $s := $s ~ ' ] } ),';
        };
        if defined $.hash {
           $s := $s ~ 'hash => ::DISPATCH( $::Hash, "new", { _hash => { ';
           for @.hash -> $item { 
                $s := $s ~ ($item[0]).emit_perl5 ~ '->{_value} => ' ~ ($item[1]).emit_perl5 ~ ', ';
            }
            $s := $s ~ ' } } ),';
        };
        return $s ~ ' } )' ~ Main::newline();
    };
}

class Subset {
    method emit_perl5 {
          '::DISPATCH( $::Subset, "new", { ' 
        ~ 'base_class => ' ~ $.base_class.emit_perl5 
        ~ ', '
        ~ 'block => '    
        ~       'sub { local $_ = shift; ' ~ ($.block.block).emit_perl5 ~ ' } '    # XXX
        ~ ' } )' ~ Main::newline();
    }
}

class Method {
    method emit_perl5 {
        'sub ' ~ $.name ~ ' { ' 
          ~     $.block.emit_declarations 
          ~     '$self = shift; ' 
          ~     $.block.emit_arguments 
          ~     $.block.emit_body
          ~ ' }' 
          ~ Main::newline();
    }
}

class Sub {
    method emit_perl5 {
          '::DISPATCH( $::Code, \'new\', { '
        ~   'code => sub { '  
        ~       $.block.emit_declarations 
        ~       $.block.emit_arguments 
        ~       $.block.emit_body
        ~    ' }, '
        ~   'signature => ' 
        ~       $.block.emit_signature
        ~    ', '
        ~ ' } )' 
        ~ Main::newline();
    }
}

class Do {
    method emit_perl5 {
        'do { ' ~ 
          $.block.emit_perl5 ~ 
        ' }'
        ~ Main::newline();
    }
}

class BEGIN {
    method emit_perl5 {
        'BEGIN { ' ~ 
          $.block.emit_perl5 ~ 
        ' }'
    }
}

class Use {
    method emit_perl5 {
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

KindaPerl6::Perl5::EmitPerl5 - Code generator for KindaPerl6-in-Perl5

=head1 DESCRIPTION

This module generates Perl5 code for the KindaPerl6 compiler.

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
