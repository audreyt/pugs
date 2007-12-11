# Do not edit this file - Generated by MiniPerl6
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;

package KindaPerl6::Visitor::MetaClass;
sub new { shift; bless {@_}, "KindaPerl6::Visitor::MetaClass" }

sub visit {
    my $self   = shift;
    my $List__ = \@_;
    my $node;
    my $node_name;
    do { $node = $List__->[0]; $node_name = $List__->[1]; [ $node, $node_name ] };
    do {
        if ( ( $node_name eq 'CompUnit' ) ) {
            my $module = [];
            do {
                if ( ( $node->unit_type() eq 'role' ) ) { push( @{$module}, Call->new( 'hyper' => '', 'arguments' => [ Val::Buf->new( 'buf' => $node->name(), ) ], 'method' => 'new', 'invocant' => Proto->new( 'name' => 'KindaPerl6::Role', ), ) ) }
                else {
                    my $metaclass = 'Class';
                    my $trait;
                    do {
                        if ( $node->traits() ) {
                            do {
                                for my $trait ( @{ $node->traits() } ) {
                                    do {
                                        if ( ( $trait->[0] eq 'meta' ) ) { $metaclass = $trait->[1] }
                                        else                             { }
                                        }
                                }
                                }
                        }
                        else { }
                    };
                    my $metaobject = Call->new( 'hyper' => '', 'arguments' => [ Val::Buf->new( 'buf' => $node->name(), ) ], 'method' => 'new', 'invocant' => Proto->new( 'name' => $metaclass, ), );
                    my $body = $node->body();
                    my $pad;
                    do {
                        if ($body) { $pad = $body->pad() }
                        else       { }
                    };
                    push(
                        @{$module},
                        If->new(
                            'cond' => Apply->new( 'arguments' => [ Proto->new( 'name' => $node->name(), ) ], 'code' => Var->new( 'name' => 'VAR_defined', 'twigil' => '', 'sigil' => '&', 'namespace' => [], ), ),
                            'body'      => Lit::Code->new( 'body' => [], 'sig' => Sig->new( 'invocant' => '', 'positional' => [], ), 'pad' => $pad, 'state' => {}, ),
                            'otherwise' => Lit::Code->new(
                                'body' => [ Bind->new( 'parameters' => Proto->new( 'name' => $node->name(), ), 'arguments' => Call->new( 'invocant' => $metaobject, 'method' => 'PROTOTYPE', 'hyper' => '', ), ) ],
                                'sig'   => Sig->new( 'invocant' => '', 'positional' => [], ),
                                'pad'   => $pad,
                                'state' => {},
                            ),
                        )
                    );
                }
            };
            my $trait;
            do {
                if ( $node->traits() ) {
                    do {
                        for my $trait ( @{ $node->traits() } ) {
                            do {
                                if ( ( $trait->[0] eq 'does' ) ) {
                                    push(
                                        @{$module},
                                        Call->new(
                                            'hyper'     => '',
                                            'arguments' => [ Val::Buf->new( 'buf' => $trait->[1], ) ],
                                            'method'    => 'add_role',
                                            'invocant'  => Call->new( 'hyper' => '', 'arguments' => [], 'method' => 'HOW', 'invocant' => Proto->new( 'name' => $node->name(), ), ),
                                        )
                                    );
                                }
                                else {
                                    do {
                                        if ( ( $trait->[0] eq 'is' ) ) {
                                            push(
                                                @{$module},
                                                Call->new(
                                                    'hyper'     => '',
                                                    'arguments' => [ Call->new( 'hyper' => '', 'arguments' => [], 'method' => 'HOW', 'invocant' => Proto->new( 'name' => $trait->[1], ), ) ],
                                                    'method'    => 'add_parent',
                                                    'invocant'  => Call->new( 'hyper' => '', 'arguments' => [], 'method' => 'HOW', 'invocant' => Proto->new( 'name' => $node->name(), ), ),
                                                )
                                            );
                                        }
                                        else {
                                            do {
                                                if   ( ( $trait->[0] eq 'meta' ) ) { }
                                                else                               { die( 'unknown class trait: ', $trait->[0] ) }
                                                }
                                        }
                                        }
                                }
                                }
                        }
                        }
                }
                else { }
            };
            my $item;
            do {
                if ($node) {
                    do {
                        if ( $node->body() ) {
                            do {
                                if ( $node->body()->body() ) {
                                    do {
                                        for my $item ( @{ $node->body()->body() } ) {
                                            do {
                                                if ( Main::isa( $item, 'Method' ) ) {
                                                    push(
                                                        @{$module},
                                                        Call->new(
                                                            'hyper'     => '',
                                                            'arguments' => [ Val::Buf->new( 'buf' => $item->name(), ), $item ],
                                                            'method'    => 'add_method',
                                                            'invocant'  => Call->new( 'hyper' => '', 'arguments' => [], 'method' => 'HOW', 'invocant' => Proto->new( 'name' => $node->name(), ), ),
                                                        )
                                                    );
                                                }
                                                else { }
                                            };
                                            do {
                                                if ( ( Main::isa( $item, 'Decl' ) && ( $item->decl() eq 'has' ) ) ) {
                                                    push(
                                                        @{$module},
                                                        Call->new(
                                                            'hyper'     => '',
                                                            'arguments' => [ Val::Buf->new( 'buf' => $item->var()->name(), ) ],
                                                            'method'    => 'add_attribute',
                                                            'invocant'  => Call->new( 'hyper' => '', 'arguments' => [], 'method' => 'HOW', 'invocant' => Proto->new( 'name' => $node->name(), ), ),
                                                        )
                                                    );
                                                }
                                                else { }
                                                }
                                        }
                                        }
                                }
                                else { }
                                }
                        }
                        else { }
                        }
                }
                else { }
            };
            my $item;
            do {
                if ($node) {
                    do {
                        if ( $node->body() ) {
                            do {
                                if ( $node->body()->body() ) {
                                    do {
                                        for my $item ( @{ $node->body()->body() } ) {
                                            do {
                                                if ( ( Main::isa( $item, 'Method' ) || ( Main::isa( $item, 'Decl' ) && ( $item->decl() eq 'has' ) ) ) ) { }
                                                else {
                                                    do {
                                                        if ( ( $module ? 0 : 1 ) ) { $module = [] }
                                                        else                       { }
                                                    };
                                                    push( @{$module}, $item );
                                                }
                                                }
                                        }
                                        }
                                }
                                else { }
                                }
                        }
                        else { }
                    };
                    my $body = $node->body();
                    my $pad;
                    do {
                        if ($body) { $pad = $body->pad() }
                        else       { }
                    };
                    return ( CompUnit->new( 'unit_type' => 'module', 'name' => $node->name(), 'body' => Lit::Code->new( 'pad' => $pad, 'state' => {}, 'sig' => Sig->new( 'invocant' => (undef), 'positional' => [], ), 'body' => $module, ), ) );
                }
                else { }
                }
        }
        else { }
    };
    return ( (undef) );
}

1;
