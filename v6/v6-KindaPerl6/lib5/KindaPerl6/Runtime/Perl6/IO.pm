{

    package IO;

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
    do {
        if (
            ::DISPATCH(
                ::DISPATCH(
                    ::DISPATCH( $GLOBAL::Code_VAR_defined, 'APPLY', $::IO ),
                    "true"
                ),
                "p5landish"
            )
          )
        {
        }
        else {
            do {
                ::MODIFIED($::IO);
                $::IO = ::DISPATCH(
                    ::DISPATCH(
                        $::Class, 'new', ::DISPATCH( $::Str, 'new', 'IO' )
                    ),
                    'PROTOTYPE',
                );
              }
        }
    };
    ::DISPATCH(
        ::DISPATCH( $::IO, 'HOW', ),
        'add_parent',
        ::DISPATCH( $::Str, 'new', 'Value' )
    );
    ::DISPATCH(
        ::DISPATCH( $::IO, 'HOW', ),
        'add_attribute',
        ::DISPATCH( $::Str, 'new', 'xxx' )
    );
    ::DISPATCH(
        ::DISPATCH( $::IO, 'HOW', ),
        'add_method',
        ::DISPATCH( $::Str, 'new', 'yyy' ),
        ::DISPATCH(
            $::Method,
            'new',
            sub {
                my $List__ =
                  ::DISPATCH( $::Array, 'new',
                    { modified => $_MODIFIED, name => '$List__' } );
                my $self;
                $self =
                  ::DISPATCH( $::Scalar, 'new',
                    { modified => $_MODIFIED, name => '$self' } )
                  unless defined $self;

                BEGIN {
                    $self =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$self' } );
                }
                $self = shift;
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
                ::DISPATCH( $::Kp6Security, 'guard_unsecure_code', );
                ::DISPATCH( $::Int, 'new', 42 );
            }
        )
      )

      ;
    1
}

