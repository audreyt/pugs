{

    package Range;

    # Do not edit this file - Perl 5 generated by KindaPerl6
    use v5;
    use strict;
    no strict "vars";
    use constant KP6_DISABLE_INSECURE_CODE => 0;
    use KindaPerl6::Runtime::Perl5::Runtime;
    my $_MODIFIED;
    INIT { $_MODIFIED = {} }
    INIT { $_ = ::DISPATCH( $::Scalar, "new", { modified => $_MODIFIED, name => "$_" } ); }
    do {
        do {
            if ( ::DISPATCH( ::DISPATCH( ::DISPATCH( ( $GLOBAL::Code_VAR_defined = $GLOBAL::Code_VAR_defined || ::DISPATCH( $::Routine, "new", ) ), 'APPLY', $::Range ), "true" ), "p5landish" ) ) { }
            else {
                do {
                    do {
                        ::MODIFIED($::Range);
                        $::Range = ::DISPATCH( ::DISPATCH( $::Class, 'new', ::DISPATCH( $::Str, 'new', 'Range' ) ), 'PROTOTYPE', );
                        }
                    }
            }
        };
        ::DISPATCH( ::DISPATCH( $::Range, 'HOW', ), 'add_parent',    ::DISPATCH( $::Value, 'HOW', ) );
        ::DISPATCH( ::DISPATCH( $::Range, 'HOW', ), 'add_attribute', ::DISPATCH( $::Str,   'new', 'start' ) );
        ::DISPATCH( ::DISPATCH( $::Range, 'HOW', ), 'add_attribute', ::DISPATCH( $::Str,   'new', 'end' ) );
        ::DISPATCH(
            ::DISPATCH( $::Range, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'perl' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {

                        # emit_declarations
                        my $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $self;
                        $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) unless defined $self;
                        INIT { $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) }

                        # get $self
                        $self = shift;

                        # emit_arguments
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        { my $_param_index = 0; }

                        # emit_body
                        ::DISPATCH(
                            ( $GLOBAL::Code_infix_58__60__126__62_ = $GLOBAL::Code_infix_58__60__126__62_ || ::DISPATCH( $::Routine, "new", ) ),
                            'APPLY',
                            ::DISPATCH( $::Str, 'new', '( ' ),
                            ::DISPATCH(
                                ( $GLOBAL::Code_infix_58__60__126__62_ = $GLOBAL::Code_infix_58__60__126__62_ || ::DISPATCH( $::Routine, "new", ) ),
                                'APPLY',
                                ::DISPATCH( ::DISPATCH( $self, "start" ), 'perl', ),
                                ::DISPATCH(
                                    ( $GLOBAL::Code_infix_58__60__126__62_ = $GLOBAL::Code_infix_58__60__126__62_ || ::DISPATCH( $::Routine, "new", ) ),
                                    'APPLY',
                                    ::DISPATCH( $::Str, 'new', '..' ),
                                    ::DISPATCH(
                                        ( $GLOBAL::Code_infix_58__60__126__62_ = $GLOBAL::Code_infix_58__60__126__62_ || ::DISPATCH( $::Routine, "new", ) ),
                                        'APPLY',
                                        ::DISPATCH( ::DISPATCH( $self, "end" ), 'perl', ),
                                        ::DISPATCH( $::Str, 'new', ' )' )
                                    )
                                )
                            )
                        );
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => bless(
                                {   'namespace' => [],
                                    'name'      => 'self',
                                    'twigil'    => '',
                                    'sigil'     => '$'
                                },
                                'Var'
                            ),
                            array  => ::DISPATCH( $::Array, "new", { _array => [] } ),
                            return => $::Undef,
                        }
                    ),
                }
            )
        );
        ::DISPATCH(
            ::DISPATCH( $::Range, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'Str' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {

                        # emit_declarations
                        my $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $self;
                        $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) unless defined $self;
                        INIT { $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) }

                        # get $self
                        $self = shift;

                        # emit_arguments
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        { my $_param_index = 0; }

                        # emit_body
                        ::DISPATCH(
                            ( $GLOBAL::Code_infix_58__60__126__62_ = $GLOBAL::Code_infix_58__60__126__62_ || ::DISPATCH( $::Routine, "new", ) ),
                            'APPLY',
                            ::DISPATCH( $self, "start" ),
                            ::DISPATCH( ( $GLOBAL::Code_infix_58__60__126__62_ = $GLOBAL::Code_infix_58__60__126__62_ || ::DISPATCH( $::Routine, "new", ) ), 'APPLY', ::DISPATCH( $::Str, 'new', '..' ), ::DISPATCH( $self, "end" ) )
                        );
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => bless(
                                {   'namespace' => [],
                                    'name'      => 'self',
                                    'twigil'    => '',
                                    'sigil'     => '$'
                                },
                                'Var'
                            ),
                            array  => ::DISPATCH( $::Array, "new", { _array => [] } ),
                            return => $::Undef,
                        }
                    ),
                }
            )
        );
        ::DISPATCH(
            ::DISPATCH( $::Range, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'min' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {

                        # emit_declarations
                        my $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $self;
                        $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) unless defined $self;
                        INIT { $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) }

                        # get $self
                        $self = shift;

                        # emit_arguments
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        { my $_param_index = 0; }

                        # emit_body
                        ::DISPATCH( $self, "start" );
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => bless(
                                {   'namespace' => [],
                                    'name'      => 'self',
                                    'twigil'    => '',
                                    'sigil'     => '$'
                                },
                                'Var'
                            ),
                            array  => ::DISPATCH( $::Array, "new", { _array => [] } ),
                            return => $::Undef,
                        }
                    ),
                }
            )
        );
        ::DISPATCH(
            ::DISPATCH( $::Range, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'max' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {

                        # emit_declarations
                        my $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $self;
                        $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) unless defined $self;
                        INIT { $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) }

                        # get $self
                        $self = shift;

                        # emit_arguments
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        { my $_param_index = 0; }

                        # emit_body
                        ::DISPATCH( $self, "end" );
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => bless(
                                {   'namespace' => [],
                                    'name'      => 'self',
                                    'twigil'    => '',
                                    'sigil'     => '$'
                                },
                                'Var'
                            ),
                            array  => ::DISPATCH( $::Array, "new", { _array => [] } ),
                            return => $::Undef,
                        }
                    ),
                }
            )
        );
        ::DISPATCH(
            ::DISPATCH( $::Range, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'map' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {

                        # emit_declarations
                        my $List_res = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List_res' } );
                        my $arity;
                        $arity = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$arity' } ) unless defined $arity;
                        INIT { $arity = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$arity' } ) }
                        my $v;
                        $v = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$v' } ) unless defined $v;
                        INIT { $v = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$v' } ) }
                        my $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $Code_code;
                        $Code_code = ::DISPATCH( $::Routine, 'new', { modified => $_MODIFIED, name => '$Code_code' } ) unless defined $Code_code;
                        INIT { $Code_code = ::DISPATCH( $::Routine, 'new', { modified => $_MODIFIED, name => '$Code_code' } ) }

                        # get $self
                        $self = shift;

                        # emit_arguments
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        {
                            my $_param_index = 0;
                            if ( ::DISPATCH( $GLOBAL::Code_exists, 'APPLY', ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'code' ) ) )->{_value} ) {
                                do {
                                    ::MODIFIED($Code_code);
                                    $Code_code = ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'code' ) );
                                    }
                            }
                            elsif ( ::DISPATCH( $GLOBAL::Code_exists, 'APPLY', ::DISPATCH( $List__, 'INDEX', ::DISPATCH( $::Int, 'new', $_param_index ) ) )->{_value} ) {
                                $Code_code = ::DISPATCH( $List__, 'INDEX', ::DISPATCH( $::Int, 'new', $_param_index++ ) );
                            }
                        }

                        # emit_body
                        $List_res;
                        ::DISPATCH_VAR( $arity, 'STORE', ::DISPATCH( ::DISPATCH( $Code_code, 'signature', ), 'arity', ) );
                        ::DISPATCH_VAR( $v, 'STORE', ::DISPATCH( $self, "start" ) );
                        do {
                            while (
                                ::DISPATCH(
                                    ::DISPATCH( ::DISPATCH( ( $GLOBAL::Code_infix_58__60__60__61__62_ = $GLOBAL::Code_infix_58__60__60__61__62_ || ::DISPATCH( $::Routine, "new", ) ), 'APPLY', $v, ::DISPATCH( $self, "end" ) ), "true" ), "p5landish"
                                )
                                )
                            {
                                do {
                                    my $List_param = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List_param' } );
                                    $List_param;
                                    do {
                                        while (
                                            ::DISPATCH(
                                                ::DISPATCH(
                                                    ::DISPATCH( ( $GLOBAL::Code_infix_58__60__60__62_ = $GLOBAL::Code_infix_58__60__60__62_ || ::DISPATCH( $::Routine, "new", ) ), 'APPLY', ::DISPATCH( $List_param, 'elems', ), $arity ), "true"
                                                ),
                                                "p5landish"
                                            )
                                            )
                                        {
                                            do {
                                                ::DISPATCH(
                                                    $List_param,
                                                    'push',
                                                    ::DISPATCH(
                                                        ( $GLOBAL::Code_ternary_58__60__63__63__32__33__33__62_ = $GLOBAL::Code_ternary_58__60__63__63__32__33__33__62_ || ::DISPATCH( $::Routine, "new", ) ), 'APPLY',
                                                        ::DISPATCH( ( $GLOBAL::Code_infix_58__60__60__61__62_ = $GLOBAL::Code_infix_58__60__60__61__62_ || ::DISPATCH( $::Routine, "new", ) ), 'APPLY', $v, ::DISPATCH( $self, "end" ) ), $v,
                                                        $::Undef
                                                    )
                                                );
                                                ::DISPATCH_VAR( $v, 'STORE',
                                                    ::DISPATCH( ( $GLOBAL::Code_infix_58__60__43__62_ = $GLOBAL::Code_infix_58__60__43__62_ || ::DISPATCH( $::Routine, "new", ) ), 'APPLY', $v, ::DISPATCH( $::Int, 'new', 1 ) ) );
                                                }
                                        }
                                    };
                                    ::DISPATCH( $List_res, 'push',
                                        ::DISPATCH( $Code_code, 'APPLY', ::DISPATCH( ( $GLOBAL::Code_prefix_58__60__124__62_ = $GLOBAL::Code_prefix_58__60__124__62_ || ::DISPATCH( $::Routine, "new", ) ), 'APPLY', $List_param ) ) );
                                    }
                            }
                        };
                        $List_res;
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => $::Undef,
                            array    => ::DISPATCH(
                                $::Array, "new",
                                {   _array => [
                                        ::DISPATCH(
                                            $::Signature::Item,
                                            'new',
                                            {   sigil               => '&',
                                                twigil              => '',
                                                name                => 'code',
                                                value               => $::Undef,
                                                has_default         => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_named_only       => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_optional         => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_slurpy           => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_multidimensional => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_rw               => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_copy             => ::DISPATCH( $::Bit, 'new', 0 ),
                                            }
                                        ),
                                    ]
                                }
                            ),
                            return => $::Undef,
                        }
                    ),
                }
            )
        );
        ::DISPATCH(
            ::DISPATCH( $::Range, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'INDEX' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {

                        # emit_declarations
                        my $v;
                        $v = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$v' } ) unless defined $v;
                        INIT { $v = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$v' } ) }
                        my $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $i;
                        $i = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$i' } ) unless defined $i;
                        INIT { $i = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$i' } ) }

                        # get $self
                        $self = shift;

                        # emit_arguments
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        {
                            my $_param_index = 0;
                            if ( ::DISPATCH( $GLOBAL::Code_exists, 'APPLY', ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'i' ) ) )->{_value} ) {
                                do {
                                    ::MODIFIED($i);
                                    $i = ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'i' ) );
                                    }
                            }
                            elsif ( ::DISPATCH( $GLOBAL::Code_exists, 'APPLY', ::DISPATCH( $List__, 'INDEX', ::DISPATCH( $::Int, 'new', $_param_index ) ) )->{_value} ) {
                                $i = ::DISPATCH( $List__, 'INDEX', ::DISPATCH( $::Int, 'new', $_param_index++ ) );
                            }
                        }

                        # emit_body
                        ::DISPATCH_VAR(
                            $v, 'STORE',
                            ::DISPATCH(
                                ( $GLOBAL::Code_infix_58__60__43__62_ = $GLOBAL::Code_infix_58__60__43__62_ || ::DISPATCH( $::Routine, "new", ) ),
                                'APPLY', $i, ::DISPATCH( ( $GLOBAL::Code_infix_58__60__45__62_ = $GLOBAL::Code_infix_58__60__45__62_ || ::DISPATCH( $::Routine, "new", ) ), 'APPLY', ::DISPATCH( $self, "start" ), ::DISPATCH( $::Int, 'new', 1 ) )
                            )
                        );
                        ::DISPATCH(
                            ( $GLOBAL::Code_ternary_58__60__63__63__32__33__33__62_ = $GLOBAL::Code_ternary_58__60__63__63__32__33__33__62_ || ::DISPATCH( $::Routine, "new", ) ),
                            'APPLY', ::DISPATCH( ( $GLOBAL::Code_infix_58__60__126__126__62_ = $GLOBAL::Code_infix_58__60__126__126__62_ || ::DISPATCH( $::Routine, "new", ) ), 'APPLY', $v, $self ),
                            $v, $::Undef
                        );
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => $::Undef,
                            array    => ::DISPATCH(
                                $::Array, "new",
                                {   _array => [
                                        ::DISPATCH(
                                            $::Signature::Item,
                                            'new',
                                            {   sigil               => '$',
                                                twigil              => '',
                                                name                => 'i',
                                                value               => $::Undef,
                                                has_default         => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_named_only       => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_optional         => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_slurpy           => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_multidimensional => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_rw               => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_copy             => ::DISPATCH( $::Bit, 'new', 0 ),
                                            }
                                        ),
                                    ]
                                }
                            ),
                            return => $::Undef,
                        }
                    ),
                }
            )
        );
        ::DISPATCH(
            ::DISPATCH( $::Range, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'smartmatch' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {

                        # emit_declarations
                        my $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $v;
                        $v = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$v' } ) unless defined $v;
                        INIT { $v = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$v' } ) }

                        # get $self
                        $self = shift;

                        # emit_arguments
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        {
                            my $_param_index = 0;
                            if ( ::DISPATCH( $GLOBAL::Code_exists, 'APPLY', ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'v' ) ) )->{_value} ) {
                                do {
                                    ::MODIFIED($v);
                                    $v = ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'v' ) );
                                    }
                            }
                            elsif ( ::DISPATCH( $GLOBAL::Code_exists, 'APPLY', ::DISPATCH( $List__, 'INDEX', ::DISPATCH( $::Int, 'new', $_param_index ) ) )->{_value} ) {
                                $v = ::DISPATCH( $List__, 'INDEX', ::DISPATCH( $::Int, 'new', $_param_index++ ) );
                            }
                        }

                        # emit_body
                        do {
                            if (::DISPATCH(
                                    ::DISPATCH( ::DISPATCH( ( $GLOBAL::Code_infix_58__60__60__62_ = $GLOBAL::Code_infix_58__60__60__62_ || ::DISPATCH( $::Routine, "new", ) ), 'APPLY', $v, ::DISPATCH( $self, "start" ) ), "true" ), "p5landish"
                                )
                                )
                            {
                                do {
                                    return ( ::DISPATCH( $::Bit, 'new', 0 ) );
                                    }
                            }
                            else { ::DISPATCH( $::Bit, "new", 0 ) }
                        };
                        do {
                            if ( ::DISPATCH( ::DISPATCH( ::DISPATCH( ( $GLOBAL::Code_infix_58__60__62__62_ = $GLOBAL::Code_infix_58__60__62__62_ || ::DISPATCH( $::Routine, "new", ) ), 'APPLY', $v, ::DISPATCH( $self, "end" ) ), "true" ), "p5landish" )
                                )
                            {
                                do {
                                    return ( ::DISPATCH( $::Bit, 'new', 0 ) );
                                    }
                            }
                            else { ::DISPATCH( $::Bit, "new", 0 ) }
                        };
                        return ( ::DISPATCH( $::Bit, 'new', 1 ) );
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => $::Undef,
                            array    => ::DISPATCH(
                                $::Array, "new",
                                {   _array => [
                                        ::DISPATCH(
                                            $::Signature::Item,
                                            'new',
                                            {   sigil               => '$',
                                                twigil              => '',
                                                name                => 'v',
                                                value               => $::Undef,
                                                has_default         => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_named_only       => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_optional         => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_slurpy           => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_multidimensional => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_rw               => ::DISPATCH( $::Bit, 'new', 0 ),
                                                is_copy             => ::DISPATCH( $::Bit, 'new', 0 ),
                                            }
                                        ),
                                    ]
                                }
                            ),
                            return => $::Undef,
                        }
                    ),
                }
            )
        );
    };
    1
}
