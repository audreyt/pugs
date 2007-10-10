# Do not edit this file - Generated by MiniPerl6
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;

package KindaPerl6::Grammar;
sub new { shift; bless {@_}, "KindaPerl6::Grammar" }

sub key {
    my $grammar = shift;
    my $List__  = \@_;
    my $str;
    my $pos;
    do { $str = $List__->[0]; $pos = $List__->[1]; [ $str, $pos ] };
    my $MATCH;
    $MATCH = MiniPerl6::Perl5::Match->new( 'str' => $str, 'from' => $pos, 'to' => $pos, 'bool' => 1, );
    $MATCH->bool(
        do {
            my $pos1 = $MATCH->to();
            (   do {
                    (   do {
                            my $m2 = $grammar->ident( $str, $MATCH->to() );
                            do {
                                if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'ident'} = $m2; 1 }
                                else     {0}
                                }
                            }
                            && (
                            do {
                                my $tmp = $MATCH;
                                $MATCH = MiniPerl6::Perl5::Match->new( 'str' => $str, 'from' => $tmp->to(), 'to' => $tmp->to(), 'bool' => 1, );
                                $MATCH->bool(
                                    do {
                                        my $pos1 = $MATCH->to();
                                        (   do { ( ( '=>' eq substr( $str, $MATCH->to(), 2 ) ) ? ( 1 + $MATCH->to( ( 2 + $MATCH->to() ) ) ) : 0 ) }
                                                || do {
                                                $MATCH->to($pos1);
                                                do {
                                                    my $m2 = $grammar->ws( $str, $MATCH->to() );
                                                    do {
                                                        if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                                        else     {0}
                                                        }
                                                    }
                                                }
                                        );
                                        }
                                );
                                $tmp->bool( ( $MATCH ? 1 : 0 ) );
                                $MATCH = $tmp;
                                ( $MATCH ? 1 : 0 );
                            }
                            && do {
                                my $ret = sub {
                                    my $List__ = \@_;
                                    do { [] };
                                    do { return ( Val::Buf->new( 'buf' => ( "" . $MATCH->{'ident'} ), ) ) };
                                    '974^213';
                                    }
                                    ->();
                                do {
                                    if ( ( $ret ne '974^213' ) ) { $MATCH->capture($ret); $MATCH->bool(1); return ($MATCH) }
                                    else                         { }
                                };
                                1;
                            }
                            )
                    );
                    }
                    || do {
                    $MATCH->to($pos1);
                    (   do {
                            my $m2 = $grammar->exp( $str, $MATCH->to() );
                            do {
                                if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'exp'} = $m2; 1 }
                                else     {0}
                                }
                            }
                            && do {
                            my $ret = sub {
                                my $List__ = \@_;
                                do { [] };
                                do { return ( ${ $MATCH->{'exp'} } ) };
                                '974^213';
                                }
                                ->();
                            do {
                                if ( ( $ret ne '974^213' ) ) { $MATCH->capture($ret); $MATCH->bool(1); return ($MATCH) }
                                else                         { }
                            };
                            1;
                            }
                    );
                    }
            );
            }
    );
    return ($MATCH);
}

sub pair {
    my $grammar = shift;
    my $List__  = \@_;
    my $str;
    my $pos;
    do { $str = $List__->[0]; $pos = $List__->[1]; [ $str, $pos ] };
    my $MATCH;
    $MATCH = MiniPerl6::Perl5::Match->new( 'str' => $str, 'from' => $pos, 'to' => $pos, 'bool' => 1, );
    $MATCH->bool(
        do {
            my $pos1 = $MATCH->to();
            (   do {
                    (   do {
                            my $m2 = $grammar->key( $str, $MATCH->to() );
                            do {
                                if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'key'} = $m2; 1 }
                                else     {0}
                                }
                            }
                            && (
                            do {
                                my $m2 = $grammar->opt_ws( $str, $MATCH->to() );
                                do {
                                    if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                    else     {0}
                                    }
                            }
                            && (( ( '=>' eq substr( $str, $MATCH->to(), 2 ) ) ? ( 1 + $MATCH->to( ( 2 + $MATCH->to() ) ) ) : 0 ) && (
                                    do {
                                        my $m2 = $grammar->opt_ws( $str, $MATCH->to() );
                                        do {
                                            if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                            else     {0}
                                            }
                                    }
                                    && (do {
                                            my $m2 = $grammar->exp( $str, $MATCH->to() );
                                            do {
                                                if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'exp'} = $m2; 1 }
                                                else     {0}
                                                }
                                        }
                                        && do {
                                            my $ret = sub {
                                                my $List__ = \@_;
                                                do { [] };
                                                do { return ( [ ${ $MATCH->{'key'} }, ${ $MATCH->{'exp'} } ] ) };
                                                '974^213';
                                                }
                                                ->();
                                            do {
                                                if ( ( $ret ne '974^213' ) ) { $MATCH->capture($ret); $MATCH->bool(1); return ($MATCH) }
                                                else                         { }
                                            };
                                            1;
                                        }
                                    )
                                )
                            )
                            )
                    );
                    }
                    || (
                    do {
                        $MATCH->to($pos1);
                        (   ( ( ':' eq substr( $str, $MATCH->to(), 1 ) ) ? ( 1 + $MATCH->to( ( 1 + $MATCH->to() ) ) ) : 0 ) && (
                                do {
                                    my $m2 = $grammar->ident( $str, $MATCH->to() );
                                    do {
                                        if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'ident'} = $m2; 1 }
                                        else     {0}
                                        }
                                }
                                && (( ( '<' eq substr( $str, $MATCH->to(), 1 ) ) ? ( 1 + $MATCH->to( ( 1 + $MATCH->to() ) ) ) : 0 ) && (
                                        do {
                                            my $m2 = $grammar->angle_quoted( $str, $MATCH->to() );
                                            do {
                                                if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'angle_quoted'} = $m2; 1 }
                                                else     {0}
                                                }
                                        }
                                        && (( ( '>' eq substr( $str, $MATCH->to(), 1 ) ) ? ( 1 + $MATCH->to( ( 1 + $MATCH->to() ) ) ) : 0 ) && do {
                                                my $ret = sub {
                                                    my $List__ = \@_;
                                                    do { [] };
                                                    do { return ( [ Val::Buf->new( 'buf' => ( "" . $MATCH->{'ident'} ), ), Val::Buf->new( 'buf' => ( "" . $MATCH->{'angle_quoted'} ), ) ] ) };
                                                    '974^213';
                                                    }
                                                    ->();
                                                do {
                                                    if ( ( $ret ne '974^213' ) ) { $MATCH->capture($ret); $MATCH->bool(1); return ($MATCH) }
                                                    else                         { }
                                                };
                                                1;
                                            }
                                        )
                                    )
                                )
                            )
                        );
                    }
                    || (do {
                            $MATCH->to($pos1);
                            (   ( ( ':' eq substr( $str, $MATCH->to(), 1 ) ) ? ( 1 + $MATCH->to( ( 1 + $MATCH->to() ) ) ) : 0 ) && (
                                    do {
                                        my $m2 = $grammar->ident( $str, $MATCH->to() );
                                        do {
                                            if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'ident'} = $m2; 1 }
                                            else     {0}
                                            }
                                    }
                                    && do {
                                        my $ret = sub {
                                            my $List__ = \@_;
                                            do { [] };
                                            do { return ( [ Val::Buf->new( 'buf' => ( "" . $MATCH->{'ident'} ), ), Val::Bit->new( 'bit' => 1, ) ] ) };
                                            '974^213';
                                            }
                                            ->();
                                        do {
                                            if ( ( $ret ne '974^213' ) ) { $MATCH->capture($ret); $MATCH->bool(1); return ($MATCH) }
                                            else                         { }
                                        };
                                        1;
                                    }
                                )
                            );
                        }
                        || do {
                            $MATCH->to($pos1);
                            (   ( ( ':' eq substr( $str, $MATCH->to(), 1 ) ) ? ( 1 + $MATCH->to( ( 1 + $MATCH->to() ) ) ) : 0 ) && (
                                    do {
                                        my $m2 = $grammar->sigil( $str, $MATCH->to() );
                                        do {
                                            if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'sigil'} = $m2; 1 }
                                            else     {0}
                                            }
                                    }
                                    && (do {
                                            my $m2 = $grammar->ident( $str, $MATCH->to() );
                                            do {
                                                if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'ident'} = $m2; 1 }
                                                else     {0}
                                                }
                                        }
                                        && do {
                                            my $ret = sub {
                                                my $List__ = \@_;
                                                do { [] };
                                                do { return ( [ Val::Buf->new( 'buf' => ( "" . $MATCH->{'ident'} ), ), Var->new( 'sigil' => ( "" . ${ $MATCH->{'sigil'} } ), 'twigil' => '', 'name' => ${ $MATCH->{'ident'} }, 'namespace' => [], ) ] ) };
                                                '974^213';
                                                }
                                                ->();
                                            do {
                                                if ( ( $ret ne '974^213' ) ) { $MATCH->capture($ret); $MATCH->bool(1); return ($MATCH) }
                                                else                         { }
                                            };
                                            1;
                                        }
                                    )
                                )
                            );
                        }
                    )
                    )
            );
            }
    );
    return ($MATCH);
}

sub exp_mapping {
    my $grammar = shift;
    my $List__  = \@_;
    my $str;
    my $pos;
    do { $str = $List__->[0]; $pos = $List__->[1]; [ $str, $pos ] };
    my $MATCH;
    $MATCH = MiniPerl6::Perl5::Match->new( 'str' => $str, 'from' => $pos, 'to' => $pos, 'bool' => 1, );
    $MATCH->bool(
        do {
            my $pos1 = $MATCH->to();
            (   do {
                    (   do {
                            my $m2 = $grammar->pair( $str, $MATCH->to() );
                            do {
                                if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'pair'} = $m2; 1 }
                                else     {0}
                                }
                            }
                            && do {
                            my $pos1 = $MATCH->to();
                            (   do {
                                    (   do {
                                            my $m2 = $grammar->opt_ws( $str, $MATCH->to() );
                                            do {
                                                if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                                else     {0}
                                                }
                                            }
                                            && (
                                            ( ( ',' eq substr( $str, $MATCH->to(), 1 ) ) ? ( 1 + $MATCH->to( ( 1 + $MATCH->to() ) ) ) : 0 ) && (
                                                do {
                                                    my $m2 = $grammar->opt_ws( $str, $MATCH->to() );
                                                    do {
                                                        if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                                        else     {0}
                                                        }
                                                }
                                                && (do {
                                                        my $m2 = $grammar->exp_mapping( $str, $MATCH->to() );
                                                        do {
                                                            if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'exp_mapping'} = $m2; 1 }
                                                            else     {0}
                                                            }
                                                    }
                                                    && do {
                                                        my $ret = sub {
                                                            my $List__ = \@_;
                                                            do { [] };
                                                            do { return ( [ ${ $MATCH->{'pair'} }, @{ ${ $MATCH->{'exp_mapping'} } } ] ) };
                                                            '974^213';
                                                            }
                                                            ->();
                                                        do {
                                                            if ( ( $ret ne '974^213' ) ) { $MATCH->capture($ret); $MATCH->bool(1); return ($MATCH) }
                                                            else                         { }
                                                        };
                                                        1;
                                                    }
                                                )
                                            )
                                            )
                                    );
                                    }
                                    || do {
                                    $MATCH->to($pos1);
                                    (   do {
                                            my $m2 = $grammar->opt_ws( $str, $MATCH->to() );
                                            do {
                                                if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                                else     {0}
                                                }
                                            }
                                            && (
                                            do {
                                                my $pos1 = $MATCH->to();
                                                (   do {
                                                        (   ( ( ',' eq substr( $str, $MATCH->to(), 1 ) ) ? ( 1 + $MATCH->to( ( 1 + $MATCH->to() ) ) ) : 0 ) && do {
                                                                my $m2 = $grammar->opt_ws( $str, $MATCH->to() );
                                                                do {
                                                                    if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                                                    else     {0}
                                                                    }
                                                                }
                                                        );
                                                        }
                                                        || do { $MATCH->to($pos1); 1 }
                                                );
                                            }
                                            && do {
                                                my $ret = sub {
                                                    my $List__ = \@_;
                                                    do { [] };
                                                    do { return ( [ ${ $MATCH->{'pair'} } ] ) };
                                                    '974^213';
                                                    }
                                                    ->();
                                                do {
                                                    if ( ( $ret ne '974^213' ) ) { $MATCH->capture($ret); $MATCH->bool(1); return ($MATCH) }
                                                    else                         { }
                                                };
                                                1;
                                            }
                                            )
                                    );
                                    }
                            );
                            }
                    );
                    }
                    || do {
                    $MATCH->to($pos1);
                    do {
                        my $ret = sub {
                            my $List__ = \@_;
                            do { [] };
                            do { return ( [] ) };
                            '974^213';
                            }
                            ->();
                        do {
                            if ( ( $ret ne '974^213' ) ) { $MATCH->capture($ret); $MATCH->bool(1); return ($MATCH) }
                            else                         { }
                        };
                        1;
                        }
                    }
            );
            }
    );
    return ($MATCH);
}

sub exp_parameter_list {
    my $grammar = shift;
    my $List__  = \@_;
    my $str;
    my $pos;
    do { $str = $List__->[0]; $pos = $List__->[1]; [ $str, $pos ] };
    my $MATCH;
    $MATCH = MiniPerl6::Perl5::Match->new( 'str' => $str, 'from' => $pos, 'to' => $pos, 'bool' => 1, );
    $MATCH->bool(
        do {
            my $pos1 = $MATCH->to();
            (   do {
                    (   do {
                            my $m2 = $grammar->pair( $str, $MATCH->to() );
                            do {
                                if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'pair'} = $m2; 1 }
                                else     {0}
                                }
                            }
                            && do {
                            my $pos1 = $MATCH->to();
                            (   do {
                                    (   do {
                                            my $m2 = $grammar->opt_ws( $str, $MATCH->to() );
                                            do {
                                                if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                                else     {0}
                                                }
                                            }
                                            && (
                                            ( ( ',' eq substr( $str, $MATCH->to(), 1 ) ) ? ( 1 + $MATCH->to( ( 1 + $MATCH->to() ) ) ) : 0 ) && (
                                                do {
                                                    my $m2 = $grammar->opt_ws( $str, $MATCH->to() );
                                                    do {
                                                        if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                                        else     {0}
                                                        }
                                                }
                                                && (do {
                                                        my $m2 = $grammar->exp_parameter_list( $str, $MATCH->to() );
                                                        do {
                                                            if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'exp_parameter_list'} = $m2; 1 }
                                                            else     {0}
                                                            }
                                                    }
                                                    && do {
                                                        my $ret = sub {
                                                            my $List__ = \@_;
                                                            do { [] };
                                                            do { return ( [ Lit::NamedArgument->new( 'key' => ${ $MATCH->{'pair'} }->[0], 'value' => ${ $MATCH->{'pair'} }->[1], ), @{ ${ $MATCH->{'exp_parameter_list'} } } ] ) };
                                                            '974^213';
                                                            }
                                                            ->();
                                                        do {
                                                            if ( ( $ret ne '974^213' ) ) { $MATCH->capture($ret); $MATCH->bool(1); return ($MATCH) }
                                                            else                         { }
                                                        };
                                                        1;
                                                    }
                                                )
                                            )
                                            )
                                    );
                                    }
                                    || do {
                                    $MATCH->to($pos1);
                                    (   do {
                                            my $m2 = $grammar->opt_ws( $str, $MATCH->to() );
                                            do {
                                                if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                                else     {0}
                                                }
                                            }
                                            && (
                                            do {
                                                my $pos1 = $MATCH->to();
                                                (   do {
                                                        (   ( ( ',' eq substr( $str, $MATCH->to(), 1 ) ) ? ( 1 + $MATCH->to( ( 1 + $MATCH->to() ) ) ) : 0 ) && do {
                                                                my $m2 = $grammar->opt_ws( $str, $MATCH->to() );
                                                                do {
                                                                    if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                                                    else     {0}
                                                                    }
                                                                }
                                                        );
                                                        }
                                                        || do { $MATCH->to($pos1); 1 }
                                                );
                                            }
                                            && do {
                                                my $ret = sub {
                                                    my $List__ = \@_;
                                                    do { [] };
                                                    do { return ( [ Lit::NamedArgument->new( 'key' => ${ $MATCH->{'pair'} }->[0], 'value' => ${ $MATCH->{'pair'} }->[1], ) ] ) };
                                                    '974^213';
                                                    }
                                                    ->();
                                                do {
                                                    if ( ( $ret ne '974^213' ) ) { $MATCH->capture($ret); $MATCH->bool(1); return ($MATCH) }
                                                    else                         { }
                                                };
                                                1;
                                            }
                                            )
                                    );
                                    }
                            );
                            }
                    );
                    }
                    || (
                    do {
                        $MATCH->to($pos1);
                        (   do {
                                my $m2 = $grammar->exp( $str, $MATCH->to() );
                                do {
                                    if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'exp'} = $m2; 1 }
                                    else     {0}
                                    }
                                }
                                && do {
                                my $pos1 = $MATCH->to();
                                (   do {
                                        (   do {
                                                my $m2 = $grammar->opt_ws( $str, $MATCH->to() );
                                                do {
                                                    if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                                    else     {0}
                                                    }
                                                }
                                                && (
                                                ( ( ',' eq substr( $str, $MATCH->to(), 1 ) ) ? ( 1 + $MATCH->to( ( 1 + $MATCH->to() ) ) ) : 0 ) && (
                                                    do {
                                                        my $m2 = $grammar->opt_ws( $str, $MATCH->to() );
                                                        do {
                                                            if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                                            else     {0}
                                                            }
                                                    }
                                                    && (do {
                                                            my $m2 = $grammar->exp_parameter_list( $str, $MATCH->to() );
                                                            do {
                                                                if ($m2) { $MATCH->to( $m2->to() ); $MATCH->{'exp_parameter_list'} = $m2; 1 }
                                                                else     {0}
                                                                }
                                                        }
                                                        && do {
                                                            my $ret = sub {
                                                                my $List__ = \@_;
                                                                do { [] };
                                                                do { return ( [ ${ $MATCH->{'exp'} }, @{ ${ $MATCH->{'exp_parameter_list'} } } ] ) };
                                                                '974^213';
                                                                }
                                                                ->();
                                                            do {
                                                                if ( ( $ret ne '974^213' ) ) { $MATCH->capture($ret); $MATCH->bool(1); return ($MATCH) }
                                                                else                         { }
                                                            };
                                                            1;
                                                        }
                                                    )
                                                )
                                                )
                                        );
                                        }
                                        || do {
                                        $MATCH->to($pos1);
                                        (   do {
                                                my $m2 = $grammar->opt_ws( $str, $MATCH->to() );
                                                do {
                                                    if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                                    else     {0}
                                                    }
                                                }
                                                && (
                                                do {
                                                    my $pos1 = $MATCH->to();
                                                    (   do {
                                                            (   ( ( ',' eq substr( $str, $MATCH->to(), 1 ) ) ? ( 1 + $MATCH->to( ( 1 + $MATCH->to() ) ) ) : 0 ) && do {
                                                                    my $m2 = $grammar->opt_ws( $str, $MATCH->to() );
                                                                    do {
                                                                        if ($m2) { $MATCH->to( $m2->to() ); 1 }
                                                                        else     {0}
                                                                        }
                                                                    }
                                                            );
                                                            }
                                                            || do { $MATCH->to($pos1); 1 }
                                                    );
                                                }
                                                && do {
                                                    my $ret = sub {
                                                        my $List__ = \@_;
                                                        do { [] };
                                                        do { return ( [ ${ $MATCH->{'exp'} } ] ) };
                                                        '974^213';
                                                        }
                                                        ->();
                                                    do {
                                                        if ( ( $ret ne '974^213' ) ) { $MATCH->capture($ret); $MATCH->bool(1); return ($MATCH) }
                                                        else                         { }
                                                    };
                                                    1;
                                                }
                                                )
                                        );
                                        }
                                );
                                }
                        );
                    }
                    || do {
                        $MATCH->to($pos1);
                        do {
                            my $ret = sub {
                                my $List__ = \@_;
                                do { [] };
                                do { return ( [] ) };
                                '974^213';
                                }
                                ->();
                            do {
                                if ( ( $ret ne '974^213' ) ) { $MATCH->capture($ret); $MATCH->bool(1); return ($MATCH) }
                                else                         { }
                            };
                            1;
                            }
                    }
                    )
            );
            }
    );
    return ($MATCH);
}

1;
