package Pugs::Runtime::Rule;

# pX/Common/iterator_engine.pl - fglock
#
# some docs after the __END__

use strict;
use warnings;
#use Smart::Comments; for debugging, look also at Filtered-Comments.pm
use Data::Dumper;
use PadWalker qw( peek_my );  # peek_our ); ???

sub alternation {
    # alternation is first match (not longest).  though we need a 
    # separate longest match for tokens (putter on #perl6)
    # update: <%var> does longest match based on the keys length() (TimToady on #perl6)

    # note: the list in @$nodes can be modified at runtime
    my $nodes = shift;
    return sub {
        my $str   = $_[0];
        my $state = $_[1] ? [ @{$_[1]} ] : [ 0, 0 ];
        $_[3] = bless \{ bool => \0 }, 'Pugs::Runtime::Match::Ratchet';
        while ( $state->[0] <= $#$nodes ) {
            ### alternation string to match: "$str - (node,state)=@$state"
            $nodes->[ $state->[0] ]->( $str, $state->[1], $_[2], $_[3], @_[4,5,6,7] );
            # $match = $$match if ref($match) eq 'Pugs::Runtime::Match';
            if ( ${$_[3]}->{state} ) {
                $state->[1] = ${$_[3]}->{state};
            }
            else
            {
                $state->[0]++;
                $state->[1] = 0;
            }
            ${$_[3]}->{state} = $state;
            # print "alt: ",Dumper($_[3]);
            last if $_[3] || ${$_[3]}->{abort};
        }
    }
}

sub concat {
    # note: the list in @nodes can NOT be modified at runtime    
    return concat( +shift, concat( @_ ) )
        if @_ > 2;
    my @nodes = @_;
    return sub {
        my @state = $_[1] ? ( @{$_[1]} ) : ( 0, 0 );
        while (1) {
            
            $nodes[0]->( $_[0], $state[0], $_[2], $_[3], @_[4,5,6,7] );
            # $matches[0] = ${$matches[0]} if ref($matches[0]) eq 'Pugs::Runtime::Match';
            #print "concat 1: ", Dumper $_[3];
            return if ! $_[3] || ${$_[3]}->{abort};

            $_[3] = { match => [ $_[3] ] };
            # $_[3]{capture} = $_[3]{match}[0]{capture};
            #print "Matched concat 0, tree:", Dumper($_[2]);

            $nodes[1]->( $_[0], $state[1], $_[2], $_[3]{match}[1], 
                         $_[4], $_[3]{match}[0]->to, @_[6,7] );
            #print "concat 2: ", Dumper $_[3];
            # $matches[1] = ${$matches[1]} if ref($matches[1]) eq 'Pugs::Runtime::Match';
            if ( ! $_[3]{match}[1] && ! ${$_[3]{match}[1]}->{abort} ) {
                if ( ! defined( ${$_[3]{match}[1]}->{state} ) ) {
                    return unless defined ${$_[3]{match}[0]}->{state};
                    @state = ( ${$_[3]{match}[0]}->{state}, 0 );
                }
                ### backtracking - state: @state
                next;
            }
            #print "Matched concat 1, tree:", Dumper($_[2]) if defined $_[2];

            my $succ;
            if ( ! defined( ${$_[3]{match}[1]}->{state} ) ) {
                $succ = [ ${$_[3]{match}[0]}->{state}, 0 ] if defined ${$_[3]{match}[0]}->{state};
            }
            else {
                $succ = [ $_[3]{match}[0], ${$_[3]{match}[1]}->{state} ];
            }
            # print Dumper $_[3];
            $_[3] = bless \{
                bool  => \$_[3]{match}[1]->bool,
                str   => \$_[0],
                from  => \$_[3]{match}[0]->from,
                to    => \$_[3]{match}[1]->to,
                named => { %{$_[3]{match}[0]}, %{$_[3]{match}[1]} },
                match => [ @{$_[3]{match}[0]}, @{$_[3]{match}[1]} ],
                capture => ${$_[3]{match}[1]}->{capture},
                state   => $succ,
                abort   => ${$_[3]{match}[1]}->{abort},
            }, 'Pugs::Runtime::Match::Ratchet';
            # print "concat: ", Dumper $_[3];
            return;
        }
    }
}

sub constant { 
    my $const = shift;
    my $lconst = length( $const );
    no warnings qw( uninitialized );
    return sub {
        #print "Pos: $_[5] - ", length($_[6])-length($_[0]), "\n";
        #print "Runtime::Rule::constant: $const at $_[5]\n";
        my $bool = $const eq substr( $_[0], $_[5], $lconst );
        $_[3] = bless \{ 
                bool  => \$bool,
                str   => \$_[0],
                from  => \(0 + $_[5]),
                to    => \($_[5] + $lconst),
                named => {},
                match => [],
            }, 'Pugs::Runtime::Match::Ratchet'
    }
}

sub perl5 {
    my $rx = qr(^($_[0]))s;
    no warnings qw( uninitialized );
    return sub {
        my $bool = substr( $_[0], $_[5] ) =~ m/$rx/;
        $_[3] = bless \{ 
                bool  => \$bool,
                str   => \$_[0],
                from  => \(0 + $_[5]),
                to    => \($_[5] + length $1),
                named => {},
                match => [],
            }, 'Pugs::Runtime::Match::Ratchet'
    };
}

sub null {
    return sub {
        $_[3] = bless \{ 
                bool  => \1,
                str   => \$_[0],
                from  => \(0 + $_[5]),
                to    => \(0 + $_[5]),
                named => {},
                match => [],
            }, 'Pugs::Runtime::Match::Ratchet'
    }
};

sub capture {
    # return a labeled capture
    my $label = shift;
    my $node = shift;
    sub {
        my $match;
        $node->( @_[0,1,2], $match, @_[4,5,6,7] );
        $_[3] = bless \{ 
                bool  => \( $match->bool ),
                str   => \$_[0],
                from  => \( $match->from ),
                to    => \( $match->to ),
                named => { $label => $match },
                match => [],
            }, 'Pugs::Runtime::Match::Ratchet';
    }
}

sub before { 
    my $op = shift;
    return sub {
        my $match;
        $op->( @_[0,1,2], $match, @_[4,5,6,7] );
        $_[3] = bless \{ 
                bool  => \( $match->bool ),
                str   => \$_[0],
                from  => \( $match->from ),
                to    => \( $match->from ),
                named => {},
                match => [],
            }, 'Pugs::Runtime::Match::Ratchet';
    };
}

# ------- higher-order ruleops

sub optional {
    return alternation( [ $_[0], null() ] );
}

sub null_or_optional {
    return alternation( [ null(), $_[0] ] );
}

sub greedy_plus { 
    my $node = shift;
    my $alt;
    $alt = concat( 
        $node, 
        optional( sub{ goto $alt } ),  
    );
    return $alt;
}

sub greedy_star { 
    my $node = shift;
    return optional( greedy_plus( $node ) );
}

sub non_greedy_star { 
    my $node = shift;
    alternation( [ 
        null(),
        non_greedy_plus( $node ) 
    ] );
}

sub non_greedy_plus { 
    my $node = shift;
    # XXX - needs optimization for faster backtracking, less stack usage
    return sub {
        my $state = $_[1] || [ undef, $node ];
        $state->[1]->( $_[0], undef, $_[2], $_[3], @_[4..7] );
        #return unless $_[3];
        ${$_[3]}->{state} = [
            ${$_[3]}->{state},
            concat( $node, $state->[1] ),
        ];
        # print "non_greedy_plus ", Dumper $_[3];
    }
}

# interface to the internal rule functions
# - creates a 'capture', unless it detects a 'return block'
sub rule_wrapper {
    my ( $str, $match ) = @_;
    $match = $$match if ref($match) eq 'Pugs::Runtime::Match';
    return unless $match->{bool};
    if ( $match->{return} ) {
        #warn 'pre-return: ', Dumper( $match );
        my %match2 = %$match;
        $match2{capture} = $match->{return}( 
            Pugs::Runtime::Match->new( $match ) 
        );
        #warn "return ",ref($match2{capture});
        #warn 'post-return: ', Dumper( $match2{capture} );
        delete $match->{return};
        delete $match->{abort};
        delete $match2{return};
        delete $match2{abort};
        #warn "Return Object: ", Dumper( \%match2 );
        return \%match2;
    }
    #warn "Return String";
    # print Dumper( $match );
    my $len = length( $match->{tail} );
    my $head = $len ? substr($str, 0, -$len) : $str;
    $match->{capture} = $head;
    delete $match->{abort};
    return $match;
}

# not a 'rule node'
# gets a variable from the user's pad
# this is used by the <$var> rule
sub get_variable {
    my $name = shift;
    
    local $@;
    my($idx, $pad) = 0;
    while(eval { $pad = peek_my($idx) }) {
        $idx++, next
          unless exists $pad->{$name};

        #print "NAME $name $pad->{$name}\n";
        return ${ $pad->{$name} } if $name =~ /^\$/;
        return $pad->{$name};  # arrayref/hashref
    }
    die "Couldn't find '$name' in surrounding lexical scope.";
}

sub _preprocess_hash {
    my $h = shift;
    if ( ref($h) eq 'CODE') {
        return sub {
            $h->();
            return { 
                bool => 1, 
                match => '', 
                #tail => $_[0] 
            };
        };
    } 
    if ( UNIVERSAL::isa( $h, 'Pugs::Compiler::Regex') ) {
        #print "compiling subrule\n";
        #return $h->code;
        return sub { 
            #print "into subrule - $_[0] - grammar $_[4]\n"; 
            #print $h->code;
            my $match = $h->match( $_[0], $_[4], { p => 1 } );
            #print "match: ",$match->(),"\n";
            return $_[3] = $$match;
        };
    }
    # fail is number != 1 
    if ( $h =~ /^(\d+)$/ ) {
        return sub{} unless $1 == 1;
        return sub{ { 
            bool => 1, match => '', 
            #tail => $_[0] 
        } };
    }
    # subrule
    warn "uncompiled subrule: $h - not implemented";
    return sub {};
}

# see commit #9783 for an alternate implementation
sub hash {
    my %hash = %{shift()};
    #print "HASH: @{[ %hash ]}\n";
    my @keys = sort {length $b <=> length $a } keys %hash;
    #print "hash keys: @keys\n";
    @keys = map {
        concat(
            constant( $_ ),
            _preprocess_hash( $hash{$_} ),
        )
    } @keys;
    return alternation( \@keys );
}

sub end_of_string {
    return sub {
        return $_[3] = { 
            bool  => ($_[0] eq ''),
            match => '',
            #tail  => $_[0],
        };
    };
}

1;

__END__

# XXX - optimization - pass the string index around, 
# XXX - weaken self-referential things

=pod

A "rule" function gets as argument a list:

0 - a string to match 
1 - an optional "continuation"
2 - a partially built match tree
3 - a leaf pointer in the match tree
4 - a grammar name
5 - pos 
#6 - the whole string to match - TODO - unify with $_[0]
7 - argument list - <subrule($x,$y)>

it modifies argument #3 to:

    { bool => 0 } - match failed

or to a hashref containing:

    bool  - an "assertion" (true/false)
    from  - string pointer for start of this match
    to    - string pointer for next match (end+1)
    match - positional submatches
    named - named submatches
    capture - return'ed things
    
    state - a "continuation" or undef
    abort - the match was stopped by a { return } or a fail(),
           and it should not backtrack or whatever

Continuations are used for backtracking.

A "ruleop" function gets some arguments and returns a "rule".

=cut

=for later
# experimental!
sub try { 
    my $op = shift;
    return sub {
        my $match = $op->( @_ );
        ### abortable match...
        $match->{abort} = 0;
        return $match;
    };
};

# experimental!
sub abort { 
    my $op = shift;
    return sub {
        #print __PACKAGE__ . "->abort\n";
        #print caller;
        my $match = $op->( @_ );
        ### aborting match: $match
        $match->{abort} = 1;
        return $match;
    };
};

sub fail { 
    return abort( 
        sub {
            return { bool => \0 };
        } 
    );
};

# experimental!
sub negate { 
    my $op = shift;
    return sub {
        #my $str = $_[0];
        my $match = $op->( @_ );
        return if $match->{bool};
        return { bool => \1,
                 #tail => $_[0],
               }
    };
};
=cut

# experimental!

=for example
    # adds an 'before' or 'after' sub call, which may print a debug message 
    wrap( { 
            before => sub { print "matching variable: $_[0]\n" },
            after  => sub { $_[0]->{bool} ? print "matched\n" : print "no match\n" },
        },
        \&variable
    )
=cut

=for later
sub wrap {
    my $debug = shift;
    my $node = shift;
    sub {
        $debug->{before}( @_ ) if $debug->{before};
        my $match = $node->( @_ );
        $debug->{after}( $match, @_ ) if $debug->{after};
        return $match;
    }
}
=cut

