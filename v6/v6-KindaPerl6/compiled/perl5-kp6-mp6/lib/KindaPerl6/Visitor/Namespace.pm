# Do not edit this file - Generated by MiniPerl6
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;

package KindaPerl6::Visitor::Namespace;
sub new { shift; bless {@_}, "KindaPerl6::Visitor::Namespace" }

sub visit {
    my $self   = shift;
    my $List__ = \@_;
    my $node;
    my $node_name;
    do { $node = $List__->[0]; $node_name = $List__->[1]; [ $node, $node_name ] };
    do {
        if ( ( $node_name eq 'Var' ) ) {
            do {
                if ( @{ $node->namespace() } ) {
                    return (
                        Call->new(
                            'invocant' => Call->new(
                                'invocant'  => Var->new( 'namespace'  => ['GLOBAL'],                     'name' => 'KP6', 'twigil' => '', 'sigil' => '%', ),
                                'arguments' => [ Val::Buf->new( 'buf' => Main::join( $node->namespace(), '::' ), ) ],
                                'method'    => 'LOOKUP',
                                'hyper'     => '',
                            ),
                            'arguments' => [ Val::Buf->new( 'buf' => ( $node->sigil() . $node->name() ), ) ],
                            'method'    => 'LOOKUP',
                            'hyper'     => '',
                        )
                    );
                }
                else { }
                }
        }
        else { }
    };
    return ( (undef) );
}

1;
