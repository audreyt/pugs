
use v6-alpha;

=begin

This visitor maps lexical variables into a Scope object (see Runtime::Perl6::Scope).

=end

class KindaPerl6::Visitor::Scope {

        my $table := {
            '$' => 'Scalar_',
            '@' => 'List_',
            '%' => 'Hash_',
            '&' => 'Code_',
        };

    method visit ( $node, $node_name ) {
    
        # TODO !!!
        
        return;
    
        if    ( $node_name eq 'Var' )
        {
            if @($node.namespace) {
                #say "global ", $node.name;
                # $X::Y::z -> %KP6<X::Y><Scalar_z>
                return ::Lookup(
                        obj => ::Lookup(
                            obj => ::Var(
                                namespace => [],
                                name      => 'KP6',
                                twigil    => '',
                                sigil     => '%',
                            ),
                            index => ::Val::Buf( buf => ($node.namespace).join('::'), ),
                        ),
                        index => ::Val::Buf( buf => ($table{$node.sigil} ~ $node.name), ),
                    );
                
            }
        };
        return;
    };

}
