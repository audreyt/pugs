{

    package KindaPerl6::Visitor::Global;

    # Do not edit this file - Perl 5 generated by KindaPerl6
    use v5;
    use strict;
    no strict 'vars';
    use constant KP6_DISABLE_INSECURE_CODE => 0;
    use KindaPerl6::Runtime::Perl5::KP6Runtime;
    my $_MODIFIED;
    BEGIN { $_MODIFIED = {} }
    BEGIN { $_ = ::DISPATCH( $::Scalar, "new", { modified => $_MODIFIED, name => "$_" } ); }
    {
        do {
            if ( ::DISPATCH( ::DISPATCH( ::DISPATCH( $GLOBAL::Code_VAR_defined, 'APPLY', $::KindaPerl6::Visitor::Global ), "true" ), "p5landish" ) ) { }
            else {
                {
                    do {
                        ::MODIFIED($::KindaPerl6::Visitor::Global);
                        $::KindaPerl6::Visitor::Global = ::DISPATCH( ::DISPATCH( $::Class, 'new', ::DISPATCH( $::Str, 'new', 'KindaPerl6::Visitor::Global' ) ), 'PROTOTYPE', );
                        }
                }
            }
        };
        ::DISPATCH(
            ::DISPATCH( $::KindaPerl6::Visitor::Global, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'visit' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {
                        my $List__ = ::DISPATCH( $::Array, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $node;
                        $node = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node' } ) unless defined $node;
                        BEGIN { $node = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node' } ) }
                        my $node_name;
                        $node_name = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node_name' } ) unless defined $node_name;
                        BEGIN { $node_name = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node_name' } ) }
                        $self = shift;
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        BEGIN { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        do {
                            ::MODIFIED($node);
                            $node = ::DISPATCH( $List__, 'INDEX', ::DISPATCH( $::Int, 'new', 0 ) );
                        };
                        do {
                            ::MODIFIED($node_name);
                            $node_name = ::DISPATCH( $List__, 'INDEX', ::DISPATCH( $::Int, 'new', 1 ) );
                        };
                        do {
                            if ( ::DISPATCH( ::DISPATCH( ::DISPATCH( $GLOBAL::Code_infix_58__60_eq_62_, 'APPLY', $node_name, ::DISPATCH( $::Str, 'new', 'CompUnit' ) ), "true" ), "p5landish" ) ) {
                                {
                                    ::DISPATCH( ::DISPATCH( $node, 'body', ), 'emit', $GLOBAL::self );
                                    return ($node)
                                }
                            }
                            else { ::DISPATCH( $::Bit, "new", 0 ) }
                        };
                        do {
                            if ( ::DISPATCH( ::DISPATCH( ::DISPATCH( $GLOBAL::Code_infix_58__60_eq_62_, 'APPLY', $node_name, ::DISPATCH( $::Str, 'new', 'Lit::Code' ) ), "true" ), "p5landish" ) ) {
                                {
                                    my $stmt;
                                    $stmt = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$stmt' } ) unless defined $stmt;
                                    BEGIN { $stmt = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$stmt' } ) }
                                    ::DISPATCH( $COMPILER::Code_put_pad, 'APPLY', ::DISPATCH( $node, 'pad', ) );
                                    $stmt;
                                    {
                                        my $stmt;
                                        $stmt = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$stmt' } ) unless defined $stmt;
                                        BEGIN { $stmt = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$stmt' } ) }
                                        for $stmt ( @{ ::DISPATCH( $GLOBAL::Code_prefix_58__60__64__62_, 'APPLY', ::DISPATCH( $GLOBAL::Code_prefix_58__60__64__62_, 'APPLY', ::DISPATCH( $node, 'body', ) ) )->{_value}{_array} } ) {
                                            {
                                                ::DISPATCH( $stmt, 'emit', $GLOBAL::self )
                                            }
                                        }
                                    };
                                    ::DISPATCH( $COMPILER::Code_drop_pad, 'APPLY', );
                                    return ($node)
                                }
                            }
                            else { ::DISPATCH( $::Bit, "new", 0 ) }
                        };
                        do {
                            if ( ::DISPATCH( ::DISPATCH( ::DISPATCH( $GLOBAL::Code_infix_58__60_eq_62_, 'APPLY', $node_name, ::DISPATCH( $::Str, 'new', 'Var' ) ), "true" ), "p5landish" ) ) {
                                {
                                    do {
                                        if ( ::DISPATCH( ::DISPATCH( ::DISPATCH( ::DISPATCH( $COMPILER::Code_current_pad, 'APPLY', ), 'declaration', $node ), "true" ), "p5landish" ) ) { {} }
                                        else {
                                            {
                                                do {
                                                    if (::DISPATCH(
                                                            ::DISPATCH(
                                                                do {
                                                                    do {
                                                                        my $____some__weird___var____ = ::DISPATCH( $GLOBAL::Code_infix_58__60_eq_62_, 'APPLY', ::DISPATCH( $node, 'name', ), ::DISPATCH( $::Str, 'new', '/' ) );
                                                                        ::DISPATCH( $____some__weird___var____, "true" )->{_value} && $____some__weird___var____;
                                                                        }
                                                                        || do {
                                                                        my $____some__weird___var____ = do {
                                                                            do {
                                                                                my $____some__weird___var____ = ::DISPATCH( $GLOBAL::Code_infix_58__60_eq_62_, 'APPLY', ::DISPATCH( $node, 'name', ), ::DISPATCH( $::Str, 'new', '_' ) );
                                                                                ::DISPATCH( $____some__weird___var____, "true" )->{_value} && $____some__weird___var____;
                                                                                }
                                                                                || do {
                                                                                my $____some__weird___var____ = do {
                                                                                    do {
                                                                                        my $____some__weird___var____ = ::DISPATCH( $GLOBAL::Code_infix_58__60_eq_62_, 'APPLY', ::DISPATCH( $node, 'twigil', ), ::DISPATCH( $::Str, 'new', '.' ) );
                                                                                        ::DISPATCH( $____some__weird___var____, "true" )->{_value} && $____some__weird___var____;
                                                                                        }
                                                                                        || do {
                                                                                        my $____some__weird___var____ = do {
                                                                                            (   do {
                                                                                                    my $____some__weird___var____
                                                                                                        = ::DISPATCH( $GLOBAL::Code_infix_58__60_eq_62_, 'APPLY', ::DISPATCH( $node, 'sigil', ), ::DISPATCH( $::Str, 'new', '&' ) );
                                                                                                    ::DISPATCH( $____some__weird___var____, "true" )->{_value} && $____some__weird___var____;
                                                                                                    }
                                                                                                    && do {
                                                                                                    my $____some__weird___var____
                                                                                                        = ::DISPATCH( $GLOBAL::Code_infix_58__60_eq_62_, 'APPLY', ::DISPATCH( $node, 'name', ), ::DISPATCH( $::Str, 'new', 'self' ) );
                                                                                                    ::DISPATCH( $____some__weird___var____, "true" )->{_value} && $____some__weird___var____;
                                                                                                    }
                                                                                            ) || ::DISPATCH( $::Bit, "new", 0 );
                                                                                        };
                                                                                        ::DISPATCH( $____some__weird___var____, "true" )->{_value} && $____some__weird___var____;
                                                                                        }
                                                                                        || ::DISPATCH( $::Bit, "new", 0 );
                                                                                };
                                                                                ::DISPATCH( $____some__weird___var____, "true" )->{_value} && $____some__weird___var____;
                                                                                }
                                                                                || ::DISPATCH( $::Bit, "new", 0 );
                                                                        };
                                                                        ::DISPATCH( $____some__weird___var____, "true" )->{_value} && $____some__weird___var____;
                                                                        }
                                                                        || ::DISPATCH( $::Bit, "new", 0 );
                                                                },
                                                                "true"
                                                            ),
                                                            "p5landish"
                                                        )
                                                        )
                                                    {
                                                        {};
                                                    }
                                                    else {
                                                        {
                                                            ::DISPATCH( $node, 'namespace', ::DISPATCH( $::Array, "new", { _array => [ ::DISPATCH( $::Str, 'new', 'GLOBAL' ) ] } ) )
                                                        }
                                                    }
                                                    }
                                            }
                                        }
                                    };
                                    return ($node)
                                }
                            }
                            else { ::DISPATCH( $::Bit, "new", 0 ) }
                        };
                        return ($::Undef);
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => $::Undef,
                            array    => ::DISPATCH(
                                $::Array, "new",
                                {   _array => [
                                        ::DISPATCH( $::Signature::Item, "new", { sigil => '$', twigil => '', name => 'node',      namespace => [], } ),
                                        ::DISPATCH( $::Signature::Item, "new", { sigil => '$', twigil => '', name => 'node_name', namespace => [], } ),
                                    ]
                                }
                            ),
                            hash   => ::DISPATCH( $::Hash, "new", { _hash => {} } ),
                            return => $::Undef,
                        }
                    ),
                }
            )
            )
    };
    1
}
