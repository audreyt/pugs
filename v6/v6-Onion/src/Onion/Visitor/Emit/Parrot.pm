use v6-alpha;

class KindaPerl6::Visitor::Emit::Parrot {
    method visit ( $node ) {
        $node.emit_parrot;
    };
}

class CompUnit {
    has $.name;
    has %.attributes;
    has %.methods;
    has @.traits;
    has $.body;
    method emit_parrot {

        # --- SETUP NAMESPACE
        my $s :=   
            '.namespace [ ' ~ Main::quote ~ $.name ~ Main::quote ~ ' ] ' ~ Main::newline() ~
            #'.sub "__onload" :load' ~ Main::newline() ~
            #'.end'                ~ Main::newline() ~ Main::newline() ~
            '.sub _ :main'        ~ Main::newline() ~
            $.body.emit_parrot ~ Main::newline() ~
            '.end'                ~ Main::newline() ~ Main::newline() ~

        # --- SETUP CLASS VARIABLES

            '.sub ' ~ Main::quote ~ '_class_vars_' ~ Main::quote ~ Main::newline();
        
        # unused - 'has' declarations instead
        # for %.attributes.keys -> $item {
        #    $s := $s ~ $item.emit_parrot;
        # };

        $s := $s ~
            '.end' ~ Main::newline() ~ Main::newline();
        return $s;

        # --- SUBROUTINES AND METHODS

        #for values %.methods -> $item {
        #    $s := $s ~ $item.emit_parrot;
        #};

        # --- IMMEDIATE STATEMENTS

        #$s := $s ~ 
        #    '.sub _ :anon :load :init :outer(' ~ Main::quote ~ '_class_vars_' ~ Main::quote ~ ')' ~ Main::newline() ~
        #    '  .local pmc self'   ~ Main::newline() ~
        #    '  newclass self, ' ~ Main::quote ~ $.name ~ Main::quote ~ Main::newline();
        #$s := $s ~ $.body.emit_parrot;
        #$s := $s ~ 
        #    '.end' ~ Main::newline() ~ Main::newline();
        #return $s;
    }
}

#  .namespace [ 'Main' ]
#  .sub _ :anon :load :init
#    print "hello"
#  .end


class Val::Int {
    has $.int;
    method emit_parrot {
        '  $P0 = new .Integer' ~ Main::newline() ~
        '  $P0 = ' ~ $.int ~ Main::newline()
    }
}

class Val::Bit {
    has $.bit;
    method emit_parrot {
        '  $P0 = new .Integer' ~ Main::newline() ~
        '  $P0 = ' ~ $.bit ~ Main::newline()
    }
}

class Val::Num {
    has $.num;
    method emit_parrot {
        '  $P0 = new .Float' ~ Main::newline ~
        '  $P0 = ' ~ $.num ~ Main::newline
    }
}

class Val::Buf {
    has $.buf;
    method emit_parrot {
        '  $P0 = new .String' ~ Main::newline ~
        '  $P0 = ' ~ Main::quote ~ $.buf ~ Main::quote ~ Main::newline
    }
}

class Val::Undef {
    method emit_parrot {
        '  $P0 = new .Undef' ~ Main::newline
    }
}

class Val::Object {
    has $.class;
    has %.fields;
    method emit_parrot {
        #die 'Val::Object - not used yet';
        # 'bless(' ~ %.fields.perl ~ ', ' ~ $.class.perl ~ ')';
    }
}

class Lit::Seq {
    has @.seq;
    method emit_parrot {
        #die 'Lit::Seq - not used yet';
        # '(' ~ (@.seq.>>emit_parrot).join('') ~ ')';
    }
}

class Lit::Array {
    has @.array;
    method emit_parrot {
        my $a := @.array;
        my $item;
        my $s := 
            '  save $P1' ~ Main::newline() ~
            '  $P1 = new .ResizablePMCArray' ~ Main::newline();
        for @$a -> $item {
            $s := $s ~ $item.emit_parrot;
            $s := $s ~ 
            '  push $P1, $P0' ~ Main.newline;
        };
        my $s := $s ~ 
            '  $P0 = $P1' ~ Main::newline() ~
            '  restore $P1' ~ Main::newline();
        return $s;
    }
}

class Lit::Hash {
    has @.hash;
    method emit_parrot {
        my $a := @.hash;
        my $item;
        my $s := 
            '  save $P1' ~ Main::newline() ~
            '  save $P2' ~ Main::newline() ~
            '  $P1 = new .Hash' ~ Main::newline();
        for @$a -> $item {
            $s := $s ~ ($item[0]).emit_parrot;
            $s := $s ~ 
            '  $P2 = $P0' ~ Main.newline;
            $s := $s ~ ($item[1]).emit_parrot;
            $s := $s ~ 
            '  set $P1[$P2], $P0' ~ Main.newline;
        };
        my $s := $s ~ 
            '  $P0 = $P1'   ~ Main::newline() ~
            '  restore $P2' ~ Main::newline() ~
            '  restore $P1' ~ Main::newline();
        return $s;
    }
}

class Lit::Code {
    method emit_parrot {
        self.emit_declarations ~ self.emit_body;
    };
    method emit_body {
        (@.body.>>emit_parrot).join(' ');
    };
    method emit_signature {
        $.sig.emit_parrot
    };
    method emit_declarations {
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
            $s := $s ~ $name.emit_parrot ~ ' ' ~ Main::newline();
        };
        return $s;
    };
    method emit_arguments {
        my $array_  := ::Var( sigil => '@', twigil => '', name => '_',       namespace => [ ], );
        my $hash_   := ::Var( sigil => '%', twigil => '', name => '_',       namespace => [ ], );
        my $CAPTURE := ::Var( sigil => '$', twigil => '', name => 'CAPTURE', namespace => [ ],);
        my $CAPTURE_decl := ::Decl(decl=>'my',type=>'',var=>$CAPTURE);
        my $str := '';
        $str := $str ~ $CAPTURE_decl.emit_parrot;
        $str := $str ~ '::DISPATCH_VAR($CAPTURE,"STORE",::CAPTURIZE(\@_));';

        my $bind_ := ::Bind(parameters=>$array_,arguments=>::Call(invocant => $CAPTURE,method => 'array',arguments => []));
        $str := $str ~ $bind_.emit_parrot ~ ' ';

        my $bind_hash := 
                     ::Bind(parameters=>$hash_, arguments=>::Call(invocant => $CAPTURE,method => 'hash', arguments => []));
        $str := $str ~ $bind_hash.emit_parrot ~ ' ';

        my $i := 0;
        my $field;
        for @($.sig.positional) -> $field { 
            my $bind := ::Bind(parameters=>$field,arguments=>::Index(obj=> $array_ , 'index'=>::Val::Int(int=>$i)) );
            $str := $str ~ $bind.emit_parrot ~ ' ';
            $i := $i + 1;
        };

        return $str;
    };
}

class Lit::Object {
    has $.class;
    has @.fields;
    method emit_parrot {
        # ::Type( 'value' => 42 )
        my $fields := @.fields;
        my $str := '';        
        $str := 
            '  save $P1' ~ Main::newline() ~
            '  save $S2' ~ Main::newline() ~
            '  $P1 = new ' ~ Main::quote ~ $.class ~ Main::quote ~ Main::newline();
        for @$fields -> $field {
            $str := $str ~ 
                ($field[0]).emit_parrot ~ 
                '  $S2 = $P0'    ~ Main::newline() ~
                ($field[1]).emit_parrot ~ 
                '  setattribute $P1, $S2, $P0' ~ Main::newline();
        };
        $str := $str ~ 
            '  $P0 = $P1'   ~ Main::newline() ~
            '  restore $S2' ~ Main::newline() ~
            '  restore $P1' ~ Main::newline();
        $str;
    }
}

class Index {
    has $.obj;
    has $.index;
    method emit_parrot {
        my $s := 
            '  save $P1'  ~ Main::newline();
        $s := $s ~ $.obj.emit_parrot;
        $s := $s ~ 
            '  $P1 = $P0' ~ Main.newline();
        $s := $s ~ $.index.emit_parrot;
        $s := $s ~ 
            '  $P0 = $P1[$P0]' ~ Main.newline();
        my $s := $s ~ 
            '  restore $P1' ~ Main::newline();
        return $s;
    }
}

class Lookup {
    has $.obj;
    has $.index;
    method emit_parrot {
        my $s := 
            '  save $P1'  ~ Main::newline();
        $s := $s ~ $.obj.emit_parrot;
        $s := $s ~ 
            '  $P1 = $P0' ~ Main.newline;
        $s := $s ~ $.index.emit_parrot;
        $s := $s ~ 
            '  $P0 = $P1[$P0]' ~ Main.newline;
        my $s := $s ~ 
            '  restore $P1' ~ Main::newline();
        return $s;
    }
}

# variables can be:
# $.var   - inside a method - parrot 'attribute'
# $.var   - inside a class  - parrot 'global' (does parrot have class attributes?)
# my $var - inside a sub or method   - parrot 'lexical' 
# my $var - inside a class  - parrot 'global'
# parameters - parrot subroutine parameters - fixed by storing into lexicals

class Var {
    has $.sigil;
    has $.twigil;
    has $.name;
    method emit_parrot {
           ( $.twigil eq '.' )
        ?? ( 
             '  $P0 = getattribute self, \'' ~ $.name ~ '\'' ~ Main::newline() 
           )
        !! (
             '  $P0 = ' ~ self.full_name ~ ' ' ~ Main::newline() 
             # '  $P0 = find_lex \'' ~ self.full_name ~ '\'' ~ Main::newline() 
           )
    };
    method name {
        $.name
    };
    method full_name {
        # Normalize the sigil here into $
        # $x    => $x
        # @x    => $List_x
        # %x    => $Hash_x
        # &x    => $Code_x
        my $table := {
            '$' => 'scalar_',
            '@' => 'list_',
            '%' => 'hash_',
            '&' => 'code_',
        };
           ( $.twigil eq '.' )
        ?? ( 
             $.name 
           )
        !!  (    ( $.name eq '/' )
            ??   ( $table{$.sigil} ~ 'MATCH' )
            !!   ( $table{$.sigil} ~ $.name )
            )
    };
}

class Bind {
    has $.parameters;
    has $.arguments;
    method emit_parrot {
        if $.parameters.isa( 'Lit::Array' ) {

            #  [$a, [$b, $c]] := [1, [2, 3]]

            my $a := $.parameters.array;
            my $b := $.arguments.array;
            my $str := '';
            my $i := 0;
            for @$a -> $var {
                my $bind := ::Bind( 'parameters' => $var, 'arguments' => ($b[$i]) );
                $str := $str ~ $bind.emit_parrot;
                $i := $i + 1;
            };
            return $str ~ $.parameters.emit_parrot;
        };
        if $.parameters.isa( 'Lit::Hash' ) {

            #  {:$a, :$b} := { a => 1, b => [2, 3]}

            my $a := $.parameters.hash;
            my $b := $.arguments.hash;
            my $str := '';
            my $i := 0;
            my $arg;
            for @$a -> $var {
                $arg := ::Val::Undef();
                for @$b -> $var2 {
                    if ($var2[0]).buf eq ($var[0]).buf {
                        $arg := $var2[1];
                    }
                };
                my $bind := ::Bind( 'parameters' => $var[1], 'arguments' => $arg );
                $str := $str ~ $bind.emit_parrot;
                $i := $i + 1;
            };
            return $str ~ $.parameters.emit_parrot;
        };
        if $.parameters.isa( 'Lit::Object' ) {

            #  ::Obj(:$a, :$b) := $obj

            my $class := $.parameters.class;
            my $a     := $.parameters.fields;
            my $b     := $.arguments;
            my $str   := '';
            for @$a -> $var {
                my $bind := ::Bind( 
                    'parameters' => $var[1], 
                    'arguments'  => ::Call( 
                        invocant  => $b, 
                        method    => ($var[0]).buf, 
                        arguments => [ ], 
                        hyper     => 0 
                    )
                );
                $str := $str ~ $bind.emit_parrot;
            };
            return $str ~ $.parameters.emit_parrot;
        };
        if $.parameters.isa( 'Var' ) {
            return
                $.arguments.emit_parrot ~
                '  ' ~ $.parameters.full_name ~ ' = $P0' ~ Main::newline();
                #'  store_lex \'' ~ $.parameters.full_name ~ '\', $P0' ~ Main::newline();
        };
        if $.parameters.isa( 'Decl' ) {
            return
                $.arguments.emit_parrot ~
                '  .local pmc ' ~ (($.parameters).var).full_name     ~ Main::newline() ~
                '  ' ~ (($.parameters).var).full_name ~ ' = $P0'     ~ Main::newline() ~
                '  .lex \'' ~ (($.parameters).var).full_name ~ '\', $P0' ~ Main::newline();
                #'  store_lex \'' ~ (($.parameters).var).full_name ~ '\', $P0' ~ Main::newline();
        };
        if $.parameters.isa( 'Lookup' ) {
            my $param := $.parameters;
            my $obj   := $param.obj;
            my $index := $param.index;
            return
                $.arguments.emit_parrot ~
                '  save $P2'  ~ Main::newline() ~
                '  $P2 = $P0' ~ Main::newline() ~
                '  save $P1'  ~ Main::newline() ~
                $obj.emit_parrot     ~
                '  $P1 = $P0' ~ Main::newline() ~
                $index.emit_parrot   ~
                '  $P1[$P0] = $P2' ~ Main::newline() ~
                '  restore $P1' ~ Main::newline() ~
                '  restore $P2' ~ Main::newline();
        };
        if $.parameters.isa( 'Index' ) {
            my $param := $.parameters;
            my $obj   := $param.obj;
            my $index := $param.index;
            return
                $.arguments.emit_parrot ~
                '  save $P2'  ~ Main::newline() ~
                '  $P2 = $P0' ~ Main::newline() ~
                '  save $P1'  ~ Main::newline() ~
                $obj.emit_parrot     ~
                '  $P1 = $P0' ~ Main::newline() ~
                $index.emit_parrot   ~
                '  $P1[$P0] = $P2' ~ Main::newline() ~
                '  restore $P1' ~ Main::newline() ~
                '  restore $P2' ~ Main::newline();
        };
        die 'Not implemented binding: ' ~ $.parameters ~ Main::newline() ~ $.parameters.emit_parrot;
    }
}

class Proto {
    has $.name;
    method emit_parrot {
        '  $P0 = ' ~ $.name ~ Main::newline()
    }
}

class Call {
    has $.invocant;
    has $.hyper;
    has $.method;
    has @.arguments;
    #has $.hyper;
    method emit_parrot {
        if     ($.method eq 'perl')
            || ($.method eq 'yaml')
            || ($.method eq 'say' )
            || ($.method eq 'join')
            # || ($.method eq 'chars')
            # || ($.method eq 'isa')
        {
            if ($.hyper) {
                return
                    '[ map { Main::' ~ $.method ~ '( $_, ' ~ ', ' ~ (@.arguments.>>emit_parrot).join('') ~ ')' ~ ' } @{ ' ~ $.invocant.emit_parrot ~ ' } ]';
            }
            else {
                return
                    'Main::' ~ $.method ~ '(' ~ $.invocant.emit_parrot ~ ', ' ~ (@.arguments.>>emit_parrot).join('') ~ ')';
            }
        };

        my $meth := $.method;
        if  $meth eq 'postcircumfix:<( )>'  {
             $meth := '';
        };

        my $call := '->' ~ $meth ~ '(' ~ (@.arguments.>>emit_parrot).join('') ~ ')';
        if ($.hyper) {
            return '[ map { $_' ~ $call ~ ' } @{ ' ~ $.invocant.emit_parrot ~ ' } ]';
        };

        # TODO - arguments
        #$.invocant.emit_parrot ~
        #'  $P0.' ~ $meth ~ '()' ~ Main.newline;

        my @args := @.arguments;
        my $str := '';
        my $ii := 10;
        for @args -> $arg {
            $str := $str ~ '  save $P' ~ $ii ~ Main::newline();
            $ii := $ii + 1;
        };
        my $i := 10;
        for @args -> $arg {
            $str := $str ~ $arg.emit_parrot ~
                '  $P' ~ $i ~ ' = $P0' ~ Main::newline();
            $i := $i + 1;
        };
        $str := $str ~ $.invocant.emit_parrot ~
            '  $P0 = $P0.' ~ $meth ~ '('; 
        #$str := $str ~ '  ' ~ $.code ~ '(';
        $i := 0;
        my @p;
        for @args -> $arg {
            @p[$i] := '$P' ~ ($i+10);
            $i := $i + 1;
        };
        $str := $str ~ @p.join(', ') ~ ')' ~ Main::newline();
        for @args -> $arg {
            $ii := $ii - 1;
            $str := $str ~ '  restore $P' ~ $ii ~ Main::newline();
        };
        return $str;
    }
}

class Apply {
    has $.code;
    has @.arguments;
    my $label := 100;
    method emit_parrot {

        my $code := $.code;

        if $code eq 'die'        {
            return
                '  $P0 = new .Exception' ~ Main::newline() ~
                '  $P0[' ~ Main::quote ~ '_message' ~ Main::quote ~ '] = ' ~ Main::quote ~ 'something broke' ~ Main::quote ~ Main::newline() ~
                '  throw $P0' ~ Main::newline();
        };

        if $code eq 'say'        {
            return
                (@.arguments.>>emit_parrot).join( '  print $P0' ~ Main::newline() ) ~
                '  print $P0' ~ Main::newline() ~
                '  print ' ~ Main::quote ~ '\\' ~ 'n' ~ Main::quote ~ Main::newline()
        };
        if $code eq 'print'      {
            return
                (@.arguments.>>emit_parrot).join( '  print $P0' ~ Main::newline() ) ~
                '  print $P0' ~ Main::newline() 
        };
        if $code eq 'array'      { 
            return '  # TODO - array() is no-op' ~ Main::newline();
        };

        if $code eq 'prefix:<~>' { 
            return 
                (@.arguments[0]).emit_parrot ~
                '  $S0 = $P0'    ~ Main::newline() ~
                '  $P0 = $S0'    ~ Main::newline();
        };
        if $code eq 'prefix:<!>' {  
            return 
                ( ::If( cond      => @.arguments[0],
                        body      => [ ::Val::Bit( bit => 0 ) ],
                        otherwise => [ ::Val::Bit( bit => 1 ) ] 
                ) ).emit_parrot;
        };
        if $code eq 'prefix:<?>' {  
            return 
                ( ::If( cond      => @.arguments[0],
                        body      => [ ::Val::Bit( bit => 1 ) ],
                        otherwise => [ ::Val::Bit( bit => 0 ) ] 
                ) ).emit_parrot;
        };

        if $code eq 'prefix:<$>' { 
            return '  # TODO - prefix:<$> is no-op' ~ Main::newline();
        };
        if $code eq 'prefix:<@>' { 
            return '  # TODO - prefix:<@> is no-op' ~ Main::newline();
        };
        if $code eq 'prefix:<%>' { 
            return '  # TODO - prefix:<%> is no-op' ~ Main::newline();
        };
        
        if $code eq 'infix:<~>'  { 
            return 
                (@.arguments[0]).emit_parrot ~
                '  $S0 = $P0'    ~ Main::newline() ~
                '  save $S0'     ~ Main::newline() ~
                (@.arguments[1]).emit_parrot ~
                '  $S1 = $P0'    ~ Main::newline() ~
                '  restore $S0'  ~ Main::newline() ~
                '  $S0 = concat $S0, $S1' ~ Main::newline() ~
                '  $P0 = $S0'    ~ Main::newline();
        };
        if $code eq 'infix:<+>'  { 
            return 
                '  save $P1'        ~ Main::newline() ~
                (@.arguments[0]).emit_parrot ~
                '  $P1 = $P0'       ~ Main::newline() ~
                (@.arguments[1]).emit_parrot ~
                '  $P0 = $P1 + $P0' ~ Main::newline() ~
                '  restore $P1'     ~ Main::newline()
        };
        if $code eq 'infix:<->'  { 
            return 
                '  save $P1'        ~ Main::newline() ~
                (@.arguments[0]).emit_parrot ~
                '  $P1 = $P0'       ~ Main::newline() ~
                (@.arguments[1]).emit_parrot ~
                '  $P0 = $P1 - $P0' ~ Main::newline() ~
                '  restore $P1'     ~ Main::newline()
        };

        if $code eq 'infix:<&&>' {  
            return 
                ( ::If( cond => @.arguments[0],
                        body => [@.arguments[1]],
                        otherwise => [ ]
                ) ).emit_parrot;
        };

        if $code eq 'infix:<||>' {  
            return 
                ( ::If( cond => @.arguments[0],
                        body => [ ],
                        otherwise => [@.arguments[1]] 
                ) ).emit_parrot;
        };

        if $code eq 'infix:<eq>' { 
            $label := $label + 1;
            my $id := $label;
            return
                (@.arguments[0]).emit_parrot ~
                '  $S0 = $P0'    ~ Main::newline() ~
                '  save $S0'     ~ Main::newline() ~
                (@.arguments[1]).emit_parrot ~
                '  $S1 = $P0'    ~ Main::newline() ~
                '  restore $S0'  ~ Main::newline() ~
                '  if $S0 == $S1 goto eq' ~ $id ~ Main::newline() ~
                '  $P0 = 0'      ~ Main::newline() ~
                '  goto eq_end' ~ $id ~ Main::newline() ~
                'eq' ~ $id ~ ':' ~ Main::newline() ~
                '  $P0 = 1'      ~ Main::newline() ~
                'eq_end'  ~ $id ~ ':'  ~ Main::newline();
        };
        if $code eq 'infix:<ne>' { 
            $label := $label + 1;
            my $id := $label;
            return
                (@.arguments[0]).emit_parrot ~
                '  $S0 = $P0'    ~ Main::newline() ~
                '  save $S0'     ~ Main::newline() ~
                (@.arguments[1]).emit_parrot ~
                '  $S1 = $P0'    ~ Main::newline() ~
                '  restore $S0'  ~ Main::newline() ~
                '  if $S0 == $S1 goto eq' ~ $id ~ Main::newline() ~
                '  $P0 = 1'      ~ Main::newline() ~
                '  goto eq_end' ~ $id ~ Main::newline() ~
                'eq' ~ $id ~ ':' ~ Main::newline() ~
                '  $P0 = 0'      ~ Main::newline() ~
                'eq_end'  ~ $id ~ ':'  ~ Main::newline();
        };
        if $code eq 'infix:<==>' { 
            $label := $label + 1;
            my $id := $label;
            return
                '  save $P1'     ~ Main::newline() ~
                (@.arguments[0]).emit_parrot ~
                '  $P1 = $P0'    ~ Main::newline() ~
                (@.arguments[1]).emit_parrot ~
                '  if $P0 == $P1 goto eq' ~ $id ~ Main::newline() ~
                '  $P0 = 0'      ~ Main::newline() ~
                '  goto eq_end' ~ $id ~ Main::newline() ~
                'eq' ~ $id ~ ':' ~ Main::newline() ~
                '  $P0 = 1'      ~ Main::newline() ~
                'eq_end'  ~ $id ~ ':'  ~ Main::newline() ~
                '  restore $P1'  ~ Main::newline();
        };
        if $code eq 'infix:<!=>' { 
            $label := $label + 1;
            my $id := $label;
            return
                '  save $P1'     ~ Main::newline() ~
                (@.arguments[0]).emit_parrot ~
                '  $P1 = $P0'    ~ Main::newline() ~
                (@.arguments[1]).emit_parrot ~
                '  if $P0 == $P1 goto eq' ~ $id ~ Main::newline() ~
                '  $P0 = 1'      ~ Main::newline() ~
                '  goto eq_end' ~ $id ~ Main::newline() ~
                'eq' ~ $id ~ ':' ~ Main::newline() ~
                '  $P0 = 0'      ~ Main::newline() ~
                'eq_end'  ~ $id ~ ':'  ~ Main::newline() ~
                '  restore $P1'  ~ Main::newline();
        };

        if $code eq 'ternary:<?? !!>' { 
            return 
                ( ::If( cond => @.arguments[0],
                        body => [@.arguments[1]],
                        otherwise => [@.arguments[2]] 
                ) ).emit_parrot;
        };

        if $code eq 'defined'  { 
            return 
                (@.arguments[0]).emit_parrot ~
                '  $I0 = defined $P0' ~ Main::newline() ~
                '  $P0 = $I0' ~ Main::newline();
        };

        if $code eq 'substr'  { 
            return 
                (@.arguments[0]).emit_parrot ~
                '  $S0 = $P0'    ~ Main::newline() ~
                '  save $S0'     ~ Main::newline() ~
                (@.arguments[1]).emit_parrot ~
                '  $I0 = $P0'    ~ Main::newline() ~
                '  save $I0'     ~ Main::newline() ~
                (@.arguments[2]).emit_parrot ~
                '  $I1 = $P0'    ~ Main::newline() ~
                '  restore $I0'  ~ Main::newline() ~
                '  restore $S0'  ~ Main::newline() ~
                '  $S0 = substr $S0, $I0, $I1' ~ Main::newline() ~
                '  $P0 = $S0'    ~ Main::newline();
        };

        #(@.arguments.>>emit_parrot).join('') ~
        #'  ' ~ $.code ~ '( $P0 )' ~ Main::newline();
        
        my @args := @.arguments;
        my $str := '';
        my $ii := 10;
        my $arg;
        for @args -> $arg {
            $str := $str ~ '  save $P' ~ $ii ~ Main::newline();
            $ii := $ii + 1;
        };
        my $i := 10;
        for @args -> $arg {
            $str := $str ~ $arg.emit_parrot ~
                '  $P' ~ $i ~ ' = $P0' ~ Main::newline();
            $i := $i + 1;
        };
        $str := $str ~ '  $P0 = ' ~ $.code ~ '(';
        $i := 0;
        my @p;
        for @args -> $arg {
            @p[$i] := '$P' ~ ($i+10);
            $i := $i + 1;
        };
        $str := $str ~ @p.join(', ') ~ ')' ~ Main::newline();
        for @args -> $arg {
            $ii := $ii - 1;
            $str := $str ~ '  restore $P' ~ $ii ~ Main::newline();
        };
        return $str;
    }
}

class Return {
    has $.result;
    method emit_parrot {
        $.result.emit_parrot ~ 
        '  .return( $P0 )' ~ Main::newline();
    }
}

class If {
    has $.cond;
    has @.body;
    has @.otherwise;
    my $label := 100;
    method emit_parrot {
        $label := $label + 1;
        my $id := $label;
        return
            $.cond.emit_parrot ~ 
            '  unless $P0 goto ifelse' ~ $id ~ Main::newline() ~
                (@.body.>>emit_parrot).join('') ~ 
            '  goto ifend' ~ $id ~ Main::newline() ~
            'ifelse' ~ $id ~ ':' ~ Main::newline() ~
                (@.otherwise.>>emit_parrot).join('') ~ 
            'ifend'  ~ $id ~ ':'  ~ Main::newline();
    }
}

class Decl {
    has $.decl;
    has $.type;
    has $.var;
    method emit_parrot {
        my $decl := $.decl;
        my $name := $.var.name;
           ( $decl eq 'has' )
        ?? ( '  addattribute self, ' ~ Main::quote ~ $name ~ Main::quote ~ Main::newline() )
        !! #$.decl ~ ' ' ~ $.type ~ ' ' ~ $.var.emit_parrot;
           ( '  .local pmc ' ~ ($.var).full_name ~ ' ' ~ Main::newline() ~
             '  .lex \'' ~ ($.var).full_name ~ '\', ' ~ ($.var).full_name ~ ' ' ~ Main::newline() 
           );
    }
}

class Sig {
    has $.invocant;
    has $.positional;
    has $.named;
    method emit_parrot {
        ' print \'Signature - TODO\'; die \'Signature - TODO\'; '
    };
    method invocant {
        $.invocant
    };
    method positional {
        $.positional
    }
}

class Method {
    has $.name;
    has $.sig;
    has @.block;
    method emit_parrot {
        my $sig := $.sig;
        my $invocant := $sig.invocant;
        my $pos := $sig.positional;
        my $str := '';
        my $i := 0;
        my $field;
        for @$pos -> $field {
            $str := $str ~ 
                '  $P0 = params[' ~ $i ~ ']' ~ Main::newline() ~
                '  .lex \'' ~ $field.full_name ~ '\', $P0' ~ Main::newline();
            $i := $i + 1;
        };
        return          
            '.sub ' ~ Main::quote ~ $.name ~ Main::quote ~ 
                ' :method :outer(' ~ Main::quote ~ '_class_vars_' ~ Main::quote ~ ')' ~ Main::newline() ~
            '  .param pmc params  :slurpy'  ~ Main::newline() ~
            '  .lex \'' ~ $invocant.full_name ~ '\', self' ~ Main::newline() ~
            $str ~
            (@.block.>>emit_parrot).join('') ~ 
            '.end' ~ Main::newline() ~ Main::newline();
    }
}

class Sub {
    has $.name;
    has $.sig;
    has @.block;
    method emit_parrot {
        my $sig := $.sig;
        my $invocant := $sig.invocant;
        my $pos := $sig.positional;
        my $str := '';
        my $i := 0;
        my $field;
        for @$pos -> $field {
            $str := $str ~ 
                '  $P0 = params[' ~ $i ~ ']' ~ Main::newline() ~
                '  .lex \'' ~ $field.full_name ~ '\', $P0' ~ Main::newline();
            $i := $i + 1;
        };
        return          
            '.sub ' ~ Main::quote ~ $.name ~ Main::quote ~ 
                ' :outer(' ~ Main::quote ~ '_class_vars_' ~ Main::quote ~ ')' ~ Main::newline() ~
            '  .param pmc params  :slurpy'  ~ Main::newline() ~
            $str ~
            (@.block.>>emit_parrot).join('') ~ 
            '.end' ~ Main::newline() ~ Main::newline();
    }
}

class Do {
    has @.block;
    method emit_parrot {
        # TODO - create a new lexical pad
        (@.block.>>emit_parrot).join('') 
    }
}

class Use {
    has $.mod;
    method emit_parrot {
        '  .include ' ~ Main::quote ~ $.mod ~ Main::quote ~ Main::newline()
    }
}

=begin

=head1 NAME

MiniPerl6::Parrot::Emit::Parrot - Code generator for MiniPerl6-in-Parrot

=head1 SYNOPSIS

    $program.emit_parrot

=head1 DESCRIPTION

This module generates Parrot code for the MiniPerl6 compiler.

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
