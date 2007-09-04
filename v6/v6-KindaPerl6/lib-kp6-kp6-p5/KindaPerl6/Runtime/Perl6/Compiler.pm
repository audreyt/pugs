{

    package KindaPerl6::Runtime::Perl6::Compiler;

    # Do not edit this file - Perl 5 generated by KindaPerl6
    use v5;
    use strict;
    no strict 'vars';
    use constant KP6_DISABLE_INSECURE_CODE => 0;
    use KindaPerl6::Runtime::Perl5::Runtime;
    my $_MODIFIED;
    BEGIN { $_MODIFIED = {} }

    BEGIN {
        $_ =
          ::DISPATCH( $::Scalar, "new",
            { modified => $_MODIFIED, name => "$_" } );
    }
    my $visitor_dump_ast;
    $visitor_dump_ast =
      ::DISPATCH( $::Scalar, 'new',
        { modified => $_MODIFIED, name => '$visitor_dump_ast' } )
      unless defined $visitor_dump_ast;

    BEGIN {
        $visitor_dump_ast =
          ::DISPATCH( $::Scalar, 'new',
            { modified => $_MODIFIED, name => '$visitor_dump_ast' } );
    }
    my $visitor_emit_perl5;
    $visitor_emit_perl5 =
      ::DISPATCH( $::Scalar, 'new',
        { modified => $_MODIFIED, name => '$visitor_emit_perl5' } )
      unless defined $visitor_emit_perl5;

    BEGIN {
        $visitor_emit_perl5 =
          ::DISPATCH( $::Scalar, 'new',
            { modified => $_MODIFIED, name => '$visitor_emit_perl5' } );
    }
    my $visitor_emit_perl6;
    $visitor_emit_perl6 =
      ::DISPATCH( $::Scalar, 'new',
        { modified => $_MODIFIED, name => '$visitor_emit_perl6' } )
      unless defined $visitor_emit_perl6;

    BEGIN {
        $visitor_emit_perl6 =
          ::DISPATCH( $::Scalar, 'new',
            { modified => $_MODIFIED, name => '$visitor_emit_perl6' } );
    }
    my $visitor_metamodel;
    $visitor_metamodel =
      ::DISPATCH( $::Scalar, 'new',
        { modified => $_MODIFIED, name => '$visitor_metamodel' } )
      unless defined $visitor_metamodel;

    BEGIN {
        $visitor_metamodel =
          ::DISPATCH( $::Scalar, 'new',
            { modified => $_MODIFIED, name => '$visitor_metamodel' } );
    }
    my $visitor_token;
    $visitor_token =
      ::DISPATCH( $::Scalar, 'new',
        { modified => $_MODIFIED, name => '$visitor_token' } )
      unless defined $visitor_token;

    BEGIN {
        $visitor_token =
          ::DISPATCH( $::Scalar, 'new',
            { modified => $_MODIFIED, name => '$visitor_token' } );
    }
    my $visitor_global;
    $visitor_global =
      ::DISPATCH( $::Scalar, 'new',
        { modified => $_MODIFIED, name => '$visitor_global' } )
      unless defined $visitor_global;

    BEGIN {
        $visitor_global =
          ::DISPATCH( $::Scalar, 'new',
            { modified => $_MODIFIED, name => '$visitor_global' } );
    }
    our $Code_emit_perl6 =
      ::DISPATCH( $::Routine, 'new',
        { modified => $_MODIFIED, name => '$Code_emit_perl6' } );
    our $Code_env_init =
      ::DISPATCH( $::Routine, 'new',
        { modified => $_MODIFIED, name => '$Code_env_init' } );
    our $Code_add_pad =
      ::DISPATCH( $::Routine, 'new',
        { modified => $_MODIFIED, name => '$Code_add_pad' } );
    our $Code_drop_pad =
      ::DISPATCH( $::Routine, 'new',
        { modified => $_MODIFIED, name => '$Code_drop_pad' } );
    our $Code_begin_block =
      ::DISPATCH( $::Routine, 'new',
        { modified => $_MODIFIED, name => '$Code_begin_block' } );
    our $Code_check_block =
      ::DISPATCH( $::Routine, 'new',
        { modified => $_MODIFIED, name => '$Code_check_block' } );
    our $Code_get_var =
      ::DISPATCH( $::Routine, 'new',
        { modified => $_MODIFIED, name => '$Code_get_var' } );
    do {

        if (
            ::DISPATCH(
                ::DISPATCH(
                    ::DISPATCH(
                        $GLOBAL::Code_VAR_defined, 'APPLY',
                        $::KindaPerl6::Runtime::Perl6::Compiler
                    ),
                    "true"
                ),
                "p5landish"
            )
          )
        {
        }
        else {
            my $visitor_dump_ast;
            $visitor_dump_ast =
              ::DISPATCH( $::Scalar, 'new',
                { modified => $_MODIFIED, name => '$visitor_dump_ast' } )
              unless defined $visitor_dump_ast;

            BEGIN {
                $visitor_dump_ast =
                  ::DISPATCH( $::Scalar, 'new',
                    { modified => $_MODIFIED, name => '$visitor_dump_ast' } );
            }
            my $visitor_emit_perl5;
            $visitor_emit_perl5 =
              ::DISPATCH( $::Scalar, 'new',
                { modified => $_MODIFIED, name => '$visitor_emit_perl5' } )
              unless defined $visitor_emit_perl5;

            BEGIN {
                $visitor_emit_perl5 =
                  ::DISPATCH( $::Scalar, 'new',
                    { modified => $_MODIFIED, name => '$visitor_emit_perl5' } );
            }
            my $visitor_emit_perl6;
            $visitor_emit_perl6 =
              ::DISPATCH( $::Scalar, 'new',
                { modified => $_MODIFIED, name => '$visitor_emit_perl6' } )
              unless defined $visitor_emit_perl6;

            BEGIN {
                $visitor_emit_perl6 =
                  ::DISPATCH( $::Scalar, 'new',
                    { modified => $_MODIFIED, name => '$visitor_emit_perl6' } );
            }
            my $visitor_metamodel;
            $visitor_metamodel =
              ::DISPATCH( $::Scalar, 'new',
                { modified => $_MODIFIED, name => '$visitor_metamodel' } )
              unless defined $visitor_metamodel;

            BEGIN {
                $visitor_metamodel =
                  ::DISPATCH( $::Scalar, 'new',
                    { modified => $_MODIFIED, name => '$visitor_metamodel' } );
            }
            my $visitor_token;
            $visitor_token =
              ::DISPATCH( $::Scalar, 'new',
                { modified => $_MODIFIED, name => '$visitor_token' } )
              unless defined $visitor_token;

            BEGIN {
                $visitor_token =
                  ::DISPATCH( $::Scalar, 'new',
                    { modified => $_MODIFIED, name => '$visitor_token' } );
            }
            my $visitor_global;
            $visitor_global =
              ::DISPATCH( $::Scalar, 'new',
                { modified => $_MODIFIED, name => '$visitor_global' } )
              unless defined $visitor_global;

            BEGIN {
                $visitor_global =
                  ::DISPATCH( $::Scalar, 'new',
                    { modified => $_MODIFIED, name => '$visitor_global' } );
            }
            our $Code_emit_perl6 =
              ::DISPATCH( $::Routine, 'new',
                { modified => $_MODIFIED, name => '$Code_emit_perl6' } );
            our $Code_env_init =
              ::DISPATCH( $::Routine, 'new',
                { modified => $_MODIFIED, name => '$Code_env_init' } );
            our $Code_add_pad =
              ::DISPATCH( $::Routine, 'new',
                { modified => $_MODIFIED, name => '$Code_add_pad' } );
            our $Code_drop_pad =
              ::DISPATCH( $::Routine, 'new',
                { modified => $_MODIFIED, name => '$Code_drop_pad' } );
            our $Code_begin_block =
              ::DISPATCH( $::Routine, 'new',
                { modified => $_MODIFIED, name => '$Code_begin_block' } );
            our $Code_check_block =
              ::DISPATCH( $::Routine, 'new',
                { modified => $_MODIFIED, name => '$Code_check_block' } );
            our $Code_get_var =
              ::DISPATCH( $::Routine, 'new',
                { modified => $_MODIFIED, name => '$Code_get_var' } );
            do {
                ::MODIFIED($::KindaPerl6::Runtime::Perl6::Compiler);
                $::KindaPerl6::Runtime::Perl6::Compiler = ::DISPATCH(
                    ::DISPATCH(
                        $::Class, 'new',
                        ::DISPATCH(
                            $::Str, 'new',
                            'KindaPerl6::Runtime::Perl6::Compiler'
                        )
                    ),
                    'PROTOTYPE',
                );
              }
        }
    };
    use KindaPerl6::Visitor::Perl;
    use KindaPerl6::Visitor::EmitPerl5;
    use KindaPerl6::Visitor::EmitPerl6;
    use KindaPerl6::Visitor::MetaClass;
    use KindaPerl6::Visitor::Token;
    use KindaPerl6::Visitor::Global;
    ::DISPATCH_VAR( $visitor_dump_ast, 'STORE',
        ::DISPATCH( $::KindaPerl6::Visitor::Perl, 'new', ) );
    ::DISPATCH_VAR( $visitor_emit_perl5, 'STORE',
        ::DISPATCH( $::KindaPerl6::Visitor::EmitPerl5, 'new', ) );
    ::DISPATCH_VAR( $visitor_emit_perl6, 'STORE',
        ::DISPATCH( $::KindaPerl6::Visitor::EmitPerl6, 'new', ) );
    ::DISPATCH_VAR( $visitor_metamodel, 'STORE',
        ::DISPATCH( $::KindaPerl6::Visitor::MetaClass, 'new', ) );
    ::DISPATCH_VAR( $visitor_token, 'STORE',
        ::DISPATCH( $::KindaPerl6::Visitor::Token, 'new', ) );
    ::DISPATCH_VAR( $visitor_global, 'STORE',
        ::DISPATCH( $::KindaPerl6::Visitor::Global, 'new', ) );
    do {
        ::MODIFIED($Code_emit_perl6);
        $Code_emit_perl6 = ::DISPATCH(
            $::Code, 'new',
            {
                code => sub {
                    my $perl6;
                    $perl6 =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$perl6' } )
                      unless defined $perl6;

                    BEGIN {
                        $perl6 =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$perl6' } );
                    }
                    my $List__ =
                      ::DISPATCH( $::Array, 'new',
                        { modified => $_MODIFIED, name => '$List__' } );
                    my $node;
                    $node =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$node' } )
                      unless defined $node;

                    BEGIN {
                        $node =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$node' } );
                    }
                    my $CAPTURE;
                    $CAPTURE =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$CAPTURE' } )
                      unless defined $CAPTURE;

                    BEGIN {
                        $CAPTURE =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$CAPTURE' } );
                    }
                    ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                    do {
                        ::MODIFIED($List__);
                        $List__ = ::DISPATCH( $CAPTURE, 'array', );
                    };
                    do {
                        ::MODIFIED($node);
                        $node =
                          ::DISPATCH( $List__, 'INDEX',
                            ::DISPATCH( $::Int, 'new', 0 ) );
                    };
                    ::DISPATCH_VAR( $perl6, 'STORE',
                        ::DISPATCH( $node, 'emit', $visitor_emit_perl6 ) );
                    return ($perl6);
                },
                signature => ::DISPATCH(
                    $::Signature,
                    "new",
                    {
                        invocant => $::Undef,
                        array    => ::DISPATCH(
                            $::Array, "new",
                            {
                                _array => [
                                    ::DISPATCH(
                                        $::Signature::Item,
                                        "new",
                                        {
                                            sigil  => '$',
                                            twigil => '',
                                            name   => 'node',
                                        }
                                    ),
                                ]
                            }
                        ),
                        hash   => ::DISPATCH( $::Hash, "new", { _hash => {} } ),
                        return => $::Undef,
                    }
                ),
            }
        );
    };
    do {
        ::MODIFIED($Code_env_init);
        $Code_env_init = ::DISPATCH(
            $::Code, 'new',
            {
                code => sub {
                    my $pad;
                    $pad =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$pad' } )
                      unless defined $pad;

                    BEGIN {
                        $pad =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$pad' } );
                    }
                    my $List__ =
                      ::DISPATCH( $::Array, 'new',
                        { modified => $_MODIFIED, name => '$List__' } );
                    my $CAPTURE;
                    $CAPTURE =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$CAPTURE' } )
                      unless defined $CAPTURE;

                    BEGIN {
                        $CAPTURE =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$CAPTURE' } );
                    }
                    ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                    do {
                        ::MODIFIED($List__);
                        $List__ = ::DISPATCH( $CAPTURE, 'array', );
                    };
                    ::DISPATCH_VAR( $pad, 'STORE',
                        ::DISPATCH( $::Pad, 'new', ) );
                    ::DISPATCH_VAR( ::DISPATCH( $pad, 'outer', ),
                        'STORE', $::Undef );
                    ::DISPATCH_VAR(
                        ::DISPATCH( $pad, 'lexicals', ),
                        'STORE',
                        ::DISPATCH( $::Array, "new", { _array => [] } )
                    );
                    ::DISPATCH_VAR(
                        ::DISPATCH( $pad, 'namespace', ),
                        'STORE',
                        ::DISPATCH( $::Str, 'new', 'Main' )
                    );
                    ::DISPATCH(
                        $GLOBAL::Code_unshift,       'APPLY',
                        $GLOBAL::COMPILER::List_PAD, $pad
                    );
                    ::DISPATCH_VAR( $GLOBAL::List_COMPILER::PAD, 'STORE',
                        $GLOBAL::COMPILER::List_PAD );
                },
                signature => ::DISPATCH(
                    $::Signature,
                    "new",
                    {
                        invocant => $::Undef,
                        array =>
                          ::DISPATCH( $::Array, "new", { _array => [] } ),
                        hash   => ::DISPATCH( $::Hash, "new", { _hash => {} } ),
                        return => $::Undef,
                    }
                ),
            }
        );
    };
    do {
        ::MODIFIED($Code_add_pad);
        $Code_add_pad = ::DISPATCH(
            $::Code, 'new',
            {
                code => sub {
                    my $pad;
                    $pad =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$pad' } )
                      unless defined $pad;

                    BEGIN {
                        $pad =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$pad' } );
                    }
                    my $List__ =
                      ::DISPATCH( $::Array, 'new',
                        { modified => $_MODIFIED, name => '$List__' } );
                    my $namespace;
                    $namespace =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$namespace' } )
                      unless defined $namespace;

                    BEGIN {
                        $namespace =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$namespace' } );
                    }
                    my $CAPTURE;
                    $CAPTURE =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$CAPTURE' } )
                      unless defined $CAPTURE;

                    BEGIN {
                        $CAPTURE =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$CAPTURE' } );
                    }
                    ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                    do {
                        ::MODIFIED($List__);
                        $List__ = ::DISPATCH( $CAPTURE, 'array', );
                    };
                    do {
                        ::MODIFIED($namespace);
                        $namespace =
                          ::DISPATCH( $List__, 'INDEX',
                            ::DISPATCH( $::Int, 'new', 0 ) );
                    };
                    ::DISPATCH_VAR( $pad, 'STORE',
                        ::DISPATCH( $::Pad, 'new', ) );
                    ::DISPATCH_VAR(
                        ::DISPATCH( $pad, 'outer', ),
                        'STORE',
                        ::DISPATCH(
                            $GLOBAL::COMPILER::List_PAD, 'INDEX',
                            ::DISPATCH( $::Int, 'new', 0 )
                        )
                    );
                    ::DISPATCH_VAR(
                        ::DISPATCH( $pad, 'lexicals', ),
                        'STORE',
                        ::DISPATCH( $::Array, "new", { _array => [] } )
                    );
                    ::DISPATCH_VAR( ::DISPATCH( $pad, 'namespace', ),
                        'STORE', $namespace );
                    ::DISPATCH(
                        $GLOBAL::Code_unshift,       'APPLY',
                        $GLOBAL::COMPILER::List_PAD, $pad
                    );
                },
                signature => ::DISPATCH(
                    $::Signature,
                    "new",
                    {
                        invocant => $::Undef,
                        array    => ::DISPATCH(
                            $::Array, "new",
                            {
                                _array => [
                                    ::DISPATCH(
                                        $::Signature::Item,
                                        "new",
                                        {
                                            sigil  => '$',
                                            twigil => '',
                                            name   => 'namespace',
                                        }
                                    ),
                                ]
                            }
                        ),
                        hash   => ::DISPATCH( $::Hash, "new", { _hash => {} } ),
                        return => $::Undef,
                    }
                ),
            }
        );
    };
    do {
        ::MODIFIED($Code_drop_pad);
        $Code_drop_pad = ::DISPATCH(
            $::Code, 'new',
            {
                code => sub {
                    my $List__ =
                      ::DISPATCH( $::Array, 'new',
                        { modified => $_MODIFIED, name => '$List__' } );
                    my $CAPTURE;
                    $CAPTURE =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$CAPTURE' } )
                      unless defined $CAPTURE;

                    BEGIN {
                        $CAPTURE =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$CAPTURE' } );
                    }
                    ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                    do {
                        ::MODIFIED($List__);
                        $List__ = ::DISPATCH( $CAPTURE, 'array', );
                    };
                    ::DISPATCH( $GLOBAL::Code_shift, 'APPLY',
                        $GLOBAL::COMPILER::List_PAD );
                },
                signature => ::DISPATCH(
                    $::Signature,
                    "new",
                    {
                        invocant => $::Undef,
                        array =>
                          ::DISPATCH( $::Array, "new", { _array => [] } ),
                        hash   => ::DISPATCH( $::Hash, "new", { _hash => {} } ),
                        return => $::Undef,
                    }
                ),
            }
        );
    };
    do {
        ::MODIFIED($Code_begin_block);
        $Code_begin_block = ::DISPATCH(
            $::Code, 'new',
            {
                code => sub {
                    my $native;
                    $native =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$native' } )
                      unless defined $native;

                    BEGIN {
                        $native =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$native' } );
                    }
                    my $pad;
                    $pad =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$pad' } )
                      unless defined $pad;

                    BEGIN {
                        $pad =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$pad' } );
                    }
                    my $data;
                    $data =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$data' } )
                      unless defined $data;

                    BEGIN {
                        $data =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$data' } );
                    }
                    my $List__ =
                      ::DISPATCH( $::Array, 'new',
                        { modified => $_MODIFIED, name => '$List__' } );
                    my $ast;
                    $ast =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$ast' } )
                      unless defined $ast;

                    BEGIN {
                        $ast =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$ast' } );
                    }
                    my $CAPTURE;
                    $CAPTURE =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$CAPTURE' } )
                      unless defined $CAPTURE;

                    BEGIN {
                        $CAPTURE =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$CAPTURE' } );
                    }
                    ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                    do {
                        ::MODIFIED($List__);
                        $List__ = ::DISPATCH( $CAPTURE, 'array', );
                    };
                    do {
                        ::MODIFIED($ast);
                        $ast =
                          ::DISPATCH( $List__, 'INDEX',
                            ::DISPATCH( $::Int, 'new', 0 ) );
                    };
                    ::DISPATCH_VAR( $ast, 'STORE',
                        ::DISPATCH( $ast, 'emit', $visitor_token ) );
                    ::DISPATCH_VAR( $ast, 'STORE',
                        ::DISPATCH( $ast, 'emit', $visitor_metamodel ) );
                    ::DISPATCH(
                        $visitor_global,
                        'pad',
                        ::DISPATCH(
                            $GLOBAL::COMPILER::List_PAD, 'INDEX',
                            ::DISPATCH( $::Int, 'new', 0 )
                        )
                    );
                    ::DISPATCH_VAR( $ast, 'STORE',
                        ::DISPATCH( $ast, 'emit', $visitor_global ) );
                    ::DISPATCH( $GLOBAL::Code_shift, 'APPLY',
                        ::DISPATCH( $visitor_global, 'pad', ) );
                    ::DISPATCH_VAR( $native, 'STORE',
                        ::DISPATCH( $ast, 'emit', $visitor_emit_perl5 ) );
                    ::DISPATCH( $Code_add_pad, 'APPLY', );
                    ::DISPATCH_VAR(
                        $pad, 'STORE',
                        ::DISPATCH(
                            $GLOBAL::COMPILER::List_PAD, 'INDEX',
                            ::DISPATCH( $::Int, 'new', 0 )
                        )
                    );
                    ::DISPATCH_VAR(
                        $data, 'STORE',
                        ::DISPATCH(
                            $pad, 'eval',
                            ::DISPATCH(
                                $GLOBAL::Code_infix_58__60__126__62_,
                                'APPLY',
                                ::DISPATCH( $native, 'APPLY', ),
                                ::DISPATCH( $::Str, 'new', '; 1 ' )
                            )
                        )
                    );
                    ::DISPATCH( $Code_drop_pad, 'APPLY', );
                    do {

                        if (
                            ::DISPATCH(
                                ::DISPATCH(
                                    ::DISPATCH(
                                        $GLOBAL::Code_prefix_58__60__33__62_,
                                        'APPLY', $data
                                    ),
                                    "true"
                                ),
                                "p5landish"
                            )
                          )
                        {
                            ::DISPATCH(
                                $GLOBAL::Code_die,
                                'APPLY',
                                ::DISPATCH(
                                    $GLOBAL::Code_infix_58__60__126__62_,
                                    'APPLY',
                                    ::DISPATCH(
                                        $::Str, 'new',
                                        'BEGIN did not return a true value '
                                    ),
                                    ::DISPATCH(
                                        $ast, 'emit', $visitor_dump_ast
                                    )
                                )
                            );
                        }
                    };
                    ::DISPATCH(
                        $GLOBAL::Code_say,
                        'APPLY',
                        ::DISPATCH(
                            $::Str, 'new',
                            'BEGIN blocks still incomplete!!!'
                        )
                    );
                },
                signature => ::DISPATCH(
                    $::Signature,
                    "new",
                    {
                        invocant => $::Undef,
                        array    => ::DISPATCH(
                            $::Array, "new",
                            {
                                _array => [
                                    ::DISPATCH(
                                        $::Signature::Item,
                                        "new",
                                        {
                                            sigil  => '$',
                                            twigil => '',
                                            name   => 'ast',
                                        }
                                    ),
                                ]
                            }
                        ),
                        hash   => ::DISPATCH( $::Hash, "new", { _hash => {} } ),
                        return => $::Undef,
                    }
                ),
            }
        );
    };
    do {
        ::MODIFIED($Code_check_block);
        $Code_check_block = ::DISPATCH(
            $::Code, 'new',
            {
                code => sub {
                    my $pad;
                    $pad =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$pad' } )
                      unless defined $pad;

                    BEGIN {
                        $pad =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$pad' } );
                    }
                    my $List__ =
                      ::DISPATCH( $::Array, 'new',
                        { modified => $_MODIFIED, name => '$List__' } );
                    my $ast;
                    $ast =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$ast' } )
                      unless defined $ast;

                    BEGIN {
                        $ast =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$ast' } );
                    }
                    my $CAPTURE;
                    $CAPTURE =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$CAPTURE' } )
                      unless defined $CAPTURE;

                    BEGIN {
                        $CAPTURE =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$CAPTURE' } );
                    }
                    ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                    do {
                        ::MODIFIED($List__);
                        $List__ = ::DISPATCH( $CAPTURE, 'array', );
                    };
                    do {
                        ::MODIFIED($ast);
                        $ast =
                          ::DISPATCH( $List__, 'INDEX',
                            ::DISPATCH( $::Int, 'new', 0 ) );
                    };
                    ::DISPATCH_VAR(
                        $pad, 'STORE',
                        ::DISPATCH(
                            $GLOBAL::COMPILER::PAD, 'INDEX',
                            ::DISPATCH( $::Int, 'new', 0 )
                        )
                    );
                    ::DISPATCH(
                        $GLOBAL::Code_push,
                        'APPLY',
                        $GLOBAL::COMPILER::List_CHECK,
                        ::DISPATCH(
                            $::Array, "new", { _array => [ $ast, $pad ] }
                        )
                    );
                    return ( ::DISPATCH( $::Val::Undef, 'new', ) );
                },
                signature => ::DISPATCH(
                    $::Signature,
                    "new",
                    {
                        invocant => $::Undef,
                        array    => ::DISPATCH(
                            $::Array, "new",
                            {
                                _array => [
                                    ::DISPATCH(
                                        $::Signature::Item,
                                        "new",
                                        {
                                            sigil  => '$',
                                            twigil => '',
                                            name   => 'ast',
                                        }
                                    ),
                                ]
                            }
                        ),
                        hash   => ::DISPATCH( $::Hash, "new", { _hash => {} } ),
                        return => $::Undef,
                    }
                ),
            }
        );
    };
    do {
        ::MODIFIED($Code_get_var);
        $Code_get_var = ::DISPATCH(
            $::Code, 'new',
            {
                code => sub {
                    my $var;
                    $var =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$var' } )
                      unless defined $var;

                    BEGIN {
                        $var =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$var' } );
                    }
                    my $pad;
                    $pad =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$pad' } )
                      unless defined $pad;

                    BEGIN {
                        $pad =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$pad' } );
                    }
                    my $decl;
                    $decl =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$decl' } )
                      unless defined $decl;

                    BEGIN {
                        $decl =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$decl' } );
                    }
                    my $List__ =
                      ::DISPATCH( $::Array, 'new',
                        { modified => $_MODIFIED, name => '$List__' } );
                    my $sigil;
                    $sigil =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$sigil' } )
                      unless defined $sigil;

                    BEGIN {
                        $sigil =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$sigil' } );
                    }
                    my $twigil;
                    $twigil =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$twigil' } )
                      unless defined $twigil;

                    BEGIN {
                        $twigil =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$twigil' } );
                    }
                    my $name;
                    $name =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$name' } )
                      unless defined $name;

                    BEGIN {
                        $name =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$name' } );
                    }
                    my $CAPTURE;
                    $CAPTURE =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$CAPTURE' } )
                      unless defined $CAPTURE;

                    BEGIN {
                        $CAPTURE =
                          ::DISPATCH( $::Scalar, 'new',
                            { modified => $_MODIFIED, name => '$CAPTURE' } );
                    }
                    ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                    do {
                        ::MODIFIED($List__);
                        $List__ = ::DISPATCH( $CAPTURE, 'array', );
                    };
                    do {
                        ::MODIFIED($sigil);
                        $sigil =
                          ::DISPATCH( $List__, 'INDEX',
                            ::DISPATCH( $::Int, 'new', 0 ) );
                    };
                    do {
                        ::MODIFIED($twigil);
                        $twigil =
                          ::DISPATCH( $List__, 'INDEX',
                            ::DISPATCH( $::Int, 'new', 1 ) );
                    };
                    do {
                        ::MODIFIED($name);
                        $name =
                          ::DISPATCH( $List__, 'INDEX',
                            ::DISPATCH( $::Int, 'new', 2 ) );
                    };
                    ::DISPATCH_VAR( $var, 'STORE',
                        ::DISPATCH( $::Var, 'new', ) );
                    ::DISPATCH_VAR( ::DISPATCH( $var, 'sigil', ),
                        'STORE', $sigil );
                    ::DISPATCH_VAR( ::DISPATCH( $var, 'twigil', ),
                        'STORE', $twigil );
                    ::DISPATCH_VAR( ::DISPATCH( $var, 'name', ),
                        'STORE', $name );
                    ::DISPATCH_VAR(
                        $pad, 'STORE',
                        ::DISPATCH(
                            $GLOBAL::COMPILER::List_PAD, 'INDEX',
                            ::DISPATCH( $::Int, 'new', 0 )
                        )
                    );
                    ::DISPATCH_VAR( $decl, 'STORE',
                        ::DISPATCH( $pad, 'declaration', $var ) );
                    return ($var);
                },
                signature => ::DISPATCH(
                    $::Signature,
                    "new",
                    {
                        invocant => $::Undef,
                        array    => ::DISPATCH(
                            $::Array, "new",
                            {
                                _array => [
                                    ::DISPATCH(
                                        $::Signature::Item,
                                        "new",
                                        {
                                            sigil  => '$',
                                            twigil => '',
                                            name   => 'sigil',
                                        }
                                    ),
                                    ::DISPATCH(
                                        $::Signature::Item,
                                        "new",
                                        {
                                            sigil  => '$',
                                            twigil => '',
                                            name   => 'twigil',
                                        }
                                    ),
                                    ::DISPATCH(
                                        $::Signature::Item,
                                        "new",
                                        {
                                            sigil  => '$',
                                            twigil => '',
                                            name   => 'name',
                                        }
                                    ),
                                ]
                            }
                        ),
                        hash   => ::DISPATCH( $::Hash, "new", { _hash => {} } ),
                        return => $::Undef,
                    }
                ),
            }
        );
    };
    1
}

