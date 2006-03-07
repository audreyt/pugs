# generated file - do not edit!
package grammar1;
*{'non_capturing_group'} = 
       ruleop::concat(
         ruleop::constant( "\[" )
       ,
         \&{'grammar1::rule'}
       ,
         ruleop::constant( "\]" )
       ,
       )
;
    push @rule_terms, \&non_capturing_group;
*{'closure_rule'} = 

    sub { 
        my $rule = 
         ruleop::capture( 'code', \&{'grammar1::code'} )
       ,
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { closure =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    unshift @rule_terms, \&closure_rule;
*{'variable_rule'} = 

    sub { 
        my $rule = 
         ruleop::capture( 'variable', \&{'grammar1::variable'} )
       ,
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { variable =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    unshift @rule_terms, \&variable_rule;
*{'runtime_alternation'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::constant( "\<" )
       ,
         ruleop::capture( 'variable', \&{'grammar1::variable'} )
       ,
         ruleop::constant( "\>" )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { runtime_alternation =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    unshift @rule_terms, \&runtime_alternation;
*{'named_capture'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::constant( "\$" )
       ,
         ruleop::capture( 'ident', \&{'grammar1::ident'} )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::constant( "\:" )
       ,
         ruleop::constant( "\=" )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::constant( "\(" )
       ,
         ruleop::capture( 'rule', \&{'grammar1::rule'} )
       ,
         ruleop::constant( "\)" )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { named_capture =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    unshift @rule_terms, \&named_capture;
*{'immediate_statement_rule'} = 
       ruleop::concat(
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::alternation( \@grammar1::statements )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
       )
;
*{'grammar'} = 
         ruleop::greedy_star(
             ruleop::capture( 'immediate_statement_exec', \&{'grammar1::immediate_statement_exec'} )
           ,
         )
       ,
;
*{'rule_decl'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::constant( "rule" )
       ,
         ruleop::capture( 'ws', \&{'grammar1::ws'} )
       ,
         ruleop::capture( 'ident', \&{'grammar1::ident'} )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::constant( "\{" )
       ,
         ruleop::capture( 'rule', \&{'grammar1::rule'} )
       ,
         ruleop::constant( "\}" )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { rule_decl =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    push @grammar1::statements, \&rule_decl;
*{'grammar_name'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::constant( "grammar" )
       ,
         ruleop::capture( 'ws', \&{'grammar1::ws'} )
       ,
         ruleop::capture( 'ident', \&{'grammar1::ident'} )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::constant( "\;" )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { grammar_name =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    push @statements, \&grammar_name;
*{'_push'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::capture( 'op', 
             ruleop::alternation( [
                   ruleop::constant( "push" )
                 ,
                   ruleop::constant( "unshift" )
                 ,
             ] )
           ,
         )
       ,
         ruleop::capture( 'ws', \&{'grammar1::ws'} )
       ,
         ruleop::capture( 'variable', \&{'grammar1::variable'} )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::constant( "\," )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::capture( 'code', 
             ruleop::non_greedy_star(
                 \&{'grammar1::any'}
               ,
             )
           ,
         )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::constant( "\;" )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { _push =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    push @statements, \&_push;
*{'pod'} = 
       ruleop::concat(
         ruleop::constant( "\=" )
       ,
             ruleop::alternation( [
                   ruleop::constant( "pod" )
                 ,
                   ruleop::constant( "head1" )
                 ,
                   ruleop::constant( "kwid" )
                 ,
                   ruleop::constant( "for" )
                 ,
             ] )
           ,
       ,
         ruleop::non_greedy_star(
             \&{'grammar1::any'}
           ,
         )
       ,
         ruleop::constant( "\=" )
       ,
         ruleop::constant( "cut" )
       ,
       )
;
    push @statements, \&pod;
*{'term1'} = 
         ruleop::alternation( \@grammar1::terms )
       ,
;
*{'list'} = 
       ruleop::concat(
         ruleop::greedy_star(
               ruleop::concat(
                 ruleop::capture( 'term1', \&{'grammar1::term1'} )
               ,
                 ruleop::optional(
                     \&{'grammar1::ws'}
                   ,
                 )
               ,
                 ruleop::constant( "\," )
               ,
                 ruleop::optional(
                     \&{'grammar1::ws'}
                   ,
                 )
               ,
               )
           ,
         )
       ,
         ruleop::optional(
             ruleop::capture( 'term1', \&{'grammar1::term1'} )
           ,
         )
       ,
       )
;
*{'block'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::constant( "\{" )
       ,
         ruleop::capture( 'list', 
             ruleop::greedy_star(
                   ruleop::concat(
                     ruleop::optional(
                         \&{'grammar1::ws'}
                       ,
                     )
                   ,
                     ruleop::alternation( \@grammar1::statements )
                   ,
                   )
               ,
             )
           ,
         )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::constant( "\}" )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { block =>  match::get( $_[0], '$()<list>' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    push @statements, \&block;
*{'macro_decl'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::constant( "macro" )
       ,
         \&{'grammar1::ws'}
       ,
         ruleop::capture( 'prefix', 
             ruleop::capture( 'word', \&{'grammar1::word'} )
           ,
         )
       ,
         ruleop::constant( "\:" )
       ,
         ruleop::constant( "\<" )
       ,
         ruleop::capture( 'id', 
             ruleop::non_greedy_star(
                 \&{'grammar1::any'}
               ,
             )
           ,
         )
       ,
         ruleop::constant( "\>" )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::constant( "\(" )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::capture( 'list', \&{'grammar1::list'} )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::constant( "\)" )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::constant( "is" )
       ,
         \&{'grammar1::ws'}
       ,
         ruleop::constant( "parsed" )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::constant( "\(" )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::constant( "\/" )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::capture( 'rule', \&{'grammar1::rule'} )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::constant( "\/" )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::constant( "\)" )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::capture( 'code', \&{'grammar1::code'} )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { macro =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    push @statements, \&macro_decl;
    push @terms, \&variable;
    push @terms, \&literal;
*{'_print'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::capture( 'op', 
             ruleop::alternation( [
                   ruleop::constant( "print" )
                 ,
                   ruleop::constant( "say" )
                 ,
                   ruleop::constant( "warn" )
                 ,
                   ruleop::constant( "die" )
                 ,
             ] )
           ,
         )
       ,
         ruleop::capture( 'ws', \&{'grammar1::ws'} )
       ,
         ruleop::capture( 'list', \&{'grammar1::list'} )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::constant( "\;" )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { _print =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    push @statements, \&_print;
*{'_my'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::capture( 'op', 
             ruleop::alternation( [
                   ruleop::constant( "my" )
                 ,
                   ruleop::constant( "our" )
                 ,
                   ruleop::constant( "local" )
                 ,
             ] )
           ,
         )
       ,
         ruleop::capture( 'ws', \&{'grammar1::ws'} )
       ,
         ruleop::capture( 'variable', \&{'grammar1::variable'} )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::constant( "\;" )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { _my =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    push @statements, \&_my;
*{'_simple_statement'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::capture( 'op', 
           ruleop::concat(
             ruleop::alternation( [
                   ruleop::constant( "die" )
                 ,
                   ruleop::constant( "\." )
                 ,
             ] )
           ,
             ruleop::constant( "\." )
           ,
             ruleop::constant( "\." )
           ,
           )
         )
       ,
         ruleop::constant( "\;" )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { _simple_statement =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    push @statements, \&_simple_statement;
*{'sub_decl'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::constant( "sub" )
       ,
         \&{'grammar1::ws'}
       ,
         ruleop::capture( 'fix', 
             ruleop::alternation( [
                   ruleop::constant( "infix" )
                 ,
                   ruleop::constant( "prefix" )
                 ,
                   ruleop::constant( "postfix" )
                 ,
             ] )
           ,
         )
       ,
         ruleop::constant( "\:" )
       ,
         ruleop::constant( "\<" )
       ,
         ruleop::capture( 'id', 
             ruleop::non_greedy_star(
                 \&{'grammar1::any'}
               ,
             )
           ,
         )
       ,
         ruleop::constant( "\>" )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::capture( 'block', \&{'grammar1::block'} )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { sub_decl =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    push @statements, \&sub_decl;
*{'term2'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::capture( 'term1', 
             ruleop::capture( 'term1', \&{'grammar1::term1'} )
           ,
         )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::capture( 'op', 
             ruleop::alternation( \@grammar1::ops )
           ,
         )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::capture( 'term2', 
             ruleop::capture( 'term1', \&{'grammar1::term1'} )
           ,
         )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { sub_application_term =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
*{'sub_application'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::capture( 'term1', 
             ruleop::alternation( [
                   ruleop::capture( 'term1', \&{'grammar1::term1'} )
                 ,
                   ruleop::capture( 'term2', \&{'grammar1::term2'} )
                 ,
             ] )
           ,
         )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::capture( 'op', 
             ruleop::alternation( \@grammar1::ops )
           ,
         )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::capture( 'term2', 
             ruleop::alternation( [
                   ruleop::capture( 'term1', \&{'grammar1::term1'} )
                 ,
                   ruleop::capture( 'term2', \&{'grammar1::term2'} )
                 ,
             ] )
           ,
         )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::constant( "\;" )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { sub_application =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    push @statements, \&sub_application;
*{'eval_perl5'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::constant( "eval" )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::constant( "\(" )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::capture( 'literal', \&{'grammar1::literal'} )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::constant( "\," )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::constant( "\:" )
       ,
         ruleop::constant( "lang" )
       ,
         ruleop::constant( "\<" )
       ,
         ruleop::constant( "perl5" )
       ,
         ruleop::constant( "\>" )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::constant( "\)" )
       ,
         ruleop::optional(
             ruleop::capture( 'ws', \&{'grammar1::ws'} )
           ,
         )
       ,
         ruleop::constant( "\;" )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { eval_perl5 =>  match::get( $_[0], '$<literal>' )  } }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    push @statements, \&eval_perl5;
*{'_return'} = 

    sub { 
        my $rule = 
       ruleop::concat(
         ruleop::constant( "return" )
       ,
         \&{'grammar1::ws'}
       ,
         ruleop::capture( 'val', 
             ruleop::alternation( [
                   ruleop::capture( 'term1', \&{'grammar1::term1'} )
                 ,
                   ruleop::capture( 'term2', \&{'grammar1::term2'} )
                 ,
             ] )
           ,
         )
       ,
         ruleop::optional(
             \&{'grammar1::ws'}
           ,
         )
       ,
         ruleop::constant( "\;" )
       ,
       )
    ;
        my $match = $rule->( @_ );
        return unless $match;
        my $capture_block = sub { return { _return =>  match::get( $_[0], '$()' )  ,} }       ,
; 
        #use Data::Dumper;
        #print "capture was: ", Dumper( $match->{capture} );
        return { 
            %$match,
            capture => [ $capture_block->( $match ) ],
        }; 
    }
;
    push @statements, \&_return;
