{

    package KindaPerl6::Visitor::CreateEnv;

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
            if ( ::DISPATCH( ::DISPATCH( ::DISPATCH( $GLOBAL::Code_VAR_defined, 'APPLY', $::KindaPerl6::Visitor::CreateEnv ), "true" ), "p5landish" ) ) { }
            else {
                {
                    do {
                        ::MODIFIED($::KindaPerl6::Visitor::CreateEnv);
                        $::KindaPerl6::Visitor::CreateEnv = ::DISPATCH( ::DISPATCH( $::Class, 'new', ::DISPATCH( $::Str, 'new', 'KindaPerl6::Visitor::CreateEnv' ) ), 'PROTOTYPE', );
                        }
                }
            }
        };
        ::DISPATCH( ::DISPATCH( $::KindaPerl6::Visitor::CreateEnv, 'HOW', ), 'add_attribute', ::DISPATCH( $::Str, 'new', 'env' ) );
        ::DISPATCH( ::DISPATCH( $::KindaPerl6::Visitor::CreateEnv, 'HOW', ), 'add_attribute', ::DISPATCH( $::Str, 'new', 'lexicals' ) );
        ::DISPATCH(
            ::DISPATCH( $::KindaPerl6::Visitor::CreateEnv, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'visit' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {
                        my $List__ = ::DISPATCH( $::Array, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $node;
                        $node = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node' } ) unless defined $node;
                        BEGIN { $node = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node' } ) }
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
                            if ( ::DISPATCH( ::DISPATCH( ::DISPATCH( $node, 'isa', ::DISPATCH( $::Str, 'new', 'Lit::Code' ) ), "true" ), "p5landish" ) ) {
                                {
                                    my $temp_env;
                                    $temp_env = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$temp_env' } ) unless defined $temp_env;
                                    BEGIN { $temp_env = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$temp_env' } ) }
                                    my $temp_lexicals;
                                    $temp_lexicals = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$temp_lexicals' } ) unless defined $temp_lexicals;
                                    BEGIN { $temp_lexicals = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$temp_lexicals' } ) }
                                    my $body;
                                    $body = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$body' } ) unless defined $body;
                                    BEGIN { $body = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$body' } ) }
                                    my $node2;
                                    $node2 = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node2' } ) unless defined $node2;
                                    BEGIN { $node2 = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node2' } ) }
                                    do {
                                        ::MODIFIED($temp_env);
                                        $temp_env = ::DISPATCH( $self, "env" );
                                    };
                                    do {
                                        ::MODIFIED($temp_lexicals);
                                        $temp_lexicals = ::DISPATCH( $self, "lexicals" );
                                    };
                                    do {
                                        ::MODIFIED( ::DISPATCH( $self, "lexicals" ) );
                                        ::DISPATCH( $self, "lexicals" ) = ::DISPATCH( $::Array, "new", { _array => [] } );
                                    };
                                    do {
                                        ::MODIFIED($body);
                                        $body = ::DISPATCH( $KindaPerl6::Traverse::Code_visit, 'APPLY', $self, ::DISPATCH( $node, 'body', ) );
                                    };
                                    do {
                                        ::MODIFIED($node2);
                                        $node2 = ::DISPATCH(
                                            $::Lit::Code,
                                            'new',
                                            ::DISPATCH( $::Str, 'new', 'pad' ) => ::DISPATCH(
                                                $::Pad, 'new', ::DISPATCH( $::Str, 'new', 'outer' ) => $temp_env,
                                                ::DISPATCH( $::Str, 'new', 'lexicals' ) => ::DISPATCH( $self, "lexicals" ),
                                            ),
                                            ::DISPATCH( $::Str, 'new', 'state' ) => ::DISPATCH( $node, 'state', ),
                                            ::DISPATCH( $::Str, 'new', 'sig' )   => ::DISPATCH( $node, 'sig', ),
                                            ::DISPATCH( $::Str, 'new', 'body' )  => ::DISPATCH( $node, 'body', ),
                                        );
                                    };
                                    do {
                                        ::MODIFIED( ::DISPATCH( $self, "env" ) );
                                        ::DISPATCH( $self, "env" ) = ::DISPATCH( $node2, 'pad', );
                                    };
                                    do {
                                        ::MODIFIED( ::DISPATCH( $self, "lexicals" ) );
                                        ::DISPATCH( $self, "lexicals" ) = ::DISPATCH( $::Array, "new", { _array => [] } );
                                    };
                                    ::DISPATCH( $node2, 'body', ::DISPATCH( $KindaPerl6::Traverse::Code_visit, 'APPLY', $self, ::DISPATCH( $node, 'body', ) ) );
                                    do {
                                        ::MODIFIED( ::DISPATCH( $self, "env" ) );
                                        ::DISPATCH( $self, "env" ) = $temp_env;
                                    };
                                    do {
                                        ::MODIFIED( ::DISPATCH( $self, "lexicals" ) );
                                        ::DISPATCH( $self, "lexicals" ) = $temp_lexicals;
                                    };
                                    return ($node2)
                                }
                            }
                            else { ::DISPATCH( $::Bit, "new", 0 ) }
                        };
                        do {
                            if (::DISPATCH(
                                    ::DISPATCH(
                                        do {
                                            (   do {
                                                    my $____some__weird___var____ = ::DISPATCH( $node, 'isa', ::DISPATCH( $::Str, 'new', 'Decl' ) );
                                                    ::DISPATCH( $____some__weird___var____, "true" )->{_value} && $____some__weird___var____;
                                                    }
                                                    && do {
                                                    my $____some__weird___var____ = ::DISPATCH( $GLOBAL::Code_infix_58__60_eq_62_, 'APPLY', ::DISPATCH( $node, 'decl', ), ::DISPATCH( $::Str, 'new', 'my' ) );
                                                    ::DISPATCH( $____some__weird___var____, "true" )->{_value} && $____some__weird___var____;
                                                    }
                                            ) || ::DISPATCH( $::Bit, "new", 0 );
                                        },
                                        "true"
                                    ),
                                    "p5landish"
                                )
                                )
                            {
                                {
                                    ::DISPATCH( $GLOBAL::Code_push, 'APPLY', ::DISPATCH( $GLOBAL::Code_prefix_58__60__64__62_, 'APPLY', ::DISPATCH( $self, "lexicals" ) ), $node );
                                    return ( ::DISPATCH( $node, 'var', ) )
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
                            array    => ::DISPATCH( $::Array, "new", { _array => [ ::DISPATCH( $::Signature::Item, "new", { sigil => '$', twigil => '', name => 'node', namespace => [], } ), ] } ),
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
