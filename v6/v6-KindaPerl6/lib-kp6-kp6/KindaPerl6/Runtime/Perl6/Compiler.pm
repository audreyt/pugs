use v6-alpha;

module COMPILER {

    use KindaPerl6::Visitor::Perl;
    use KindaPerl6::Visitor::EmitPerl5;
    use KindaPerl6::Visitor::EmitPerl6;
    #use KindaPerl6::Visitor::Subset;
    use KindaPerl6::Visitor::MetaClass;
    use KindaPerl6::Visitor::Token;
    use KindaPerl6::Visitor::Global;

    my $visitor_dump_ast    = KindaPerl6::Visitor::Perl.new();
    my $visitor_emit_perl5  = KindaPerl6::Visitor::EmitPerl5.new();
    my $visitor_emit_perl6  = KindaPerl6::Visitor::EmitPerl6.new();
    #my $visitor_subset      = KindaPerl6::Visitor::Subset->new();
    my $visitor_metamodel   = KindaPerl6::Visitor::MetaClass.new();
    my $visitor_token       = KindaPerl6::Visitor::Token.new();
    my $visitor_global      = KindaPerl6::Visitor::Global.new();

    sub emit_perl6($node) {
        my $perl6 = $node.emit( $visitor_emit_perl6  );
        return $perl6;
    }

    sub env_init {
        my $pad = Pad.new();
        $pad.outer = undef;
        $pad.lexicals = [ ];
        $pad.namespace = 'Main';
        unshift @COMPILER::PAD, $pad;
        $List_COMPILER::PAD = @COMPILER::PAD;
    }

    sub add_pad($namespace) {
        my $pad = Pad.new();
        $pad.outer = @COMPILER::PAD[0];
        $pad.lexicals = [ ];
        $pad.namespace = $namespace;
        unshift @COMPILER::PAD, $pad;
    }

    sub drop_pad {
        shift @COMPILER::PAD;
    }

    sub begin_block($ast) {
        # this routine is called by begin-blocks at compile time, in order to execute the code
        # Input: '::Lit::Code' AST node

        $ast = $ast.emit($visitor_token);
        $ast = $ast.emit($visitor_metamodel);
        $visitor_global.pad( @COMPILER::PAD[0] );
        $ast = $ast.emit($visitor_global);
        shift $visitor_global.pad;

        my $native = $ast.emit($visitor_emit_perl5);
        add_pad();
        my $pad = @COMPILER::PAD[0];
        my $data = $pad.eval($native. ~ '; 1 ');
        drop_pad();

        if (!$data) {
            die 'BEGIN did not return a true value ' ~ $ast.emit($visitor_dump_ast);
        }

        say 'BEGIN blocks still incomplete!!!';
    }

    sub check_block($ast) {
        # this routine saves check-blocks, in order to execute the code at the end of compilation
        my $pad = $COMPILER::PAD[0];
        #print "CHECK saved\n";
        push @COMPILER::CHECK, [ $ast, $pad ];
        return Val::Undef.new();
    }

    sub get_var($sigil, $twigil, $name) {
        # this routine is called each time a variable is parsed.
        # it checks for proper pre-declaration
        my $var = Var.new();
        $var.sigil = $sigil;
        $var.twigil = $twigil;
        $var.name = $name;
        my $pad = @COMPILER::PAD[0];
        my $decl = $pad.declaration( $var );
        #print "COMPILER::get_var: @_ --> $decl\n";
        # TODO - annotate the variable with: Type, declarator
        return $var;
    }
}
