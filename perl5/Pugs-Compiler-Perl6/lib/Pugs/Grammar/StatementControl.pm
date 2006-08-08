﻿package Pugs::Grammar::StatementControl;
use strict;
use warnings;
use base qw(Pugs::Grammar::BaseCategory);

BEGIN {
    __PACKAGE__->add_rule(
        'for' =>  q( 
            # { print "statement for \n"; }
            <?ws> 
            $<exp1> := <Pugs::Grammar::Perl6.perl6_expression('no_blocks',0)> <?ws>?
            $<exp2> := <Pugs::Grammar::Perl6.block>        
            { return { 
                    statement => 'for',
                    exp1 => $_[0]{exp1}->(),
                    exp2 => $_[0]{exp2}->(),
            } }
        ) );
    __PACKAGE__->add_rule(
        'while' =>  q( 
            <?ws> 
            $<exp1> := <Pugs::Grammar::Perl6.perl6_expression('no_blocks',0)> <?ws>?
            $<exp2> := <Pugs::Grammar::Perl6.block>        
            { return { 
                    statement => 'while',
                    exp1 => $_[0]{exp1}->(),
                    exp2 => $_[0]{exp2}->(),
            } }
        ) );
    __PACKAGE__->add_rule(
        'until' =>  q( 
            <?ws> 
            $<exp1> := <Pugs::Grammar::Perl6.perl6_expression('no_blocks',0)> <?ws>?
            $<exp2> := <Pugs::Grammar::Perl6.block>        
            { return { 
                    statement => 'until',
                    exp1 => $_[0]{exp1}->(),
                    exp2 => $_[0]{exp2}->(),
            } }
        ) );
    __PACKAGE__->add_rule(
        'loop' =>  q( 
            <?ws> 
            [
              <'('> 
                $<exp1> := <Pugs::Grammar::Perl6.perl6_expression_or_null> <?ws>? <';'>
                $<exp2> := <Pugs::Grammar::Perl6.perl6_expression_or_null> <?ws>? <';'>
                $<exp3> := <Pugs::Grammar::Perl6.perl6_expression_or_null> <?ws>? 
              <')'> 
              <?ws>? $<content> := <Pugs::Grammar::Perl6.block>
              { return { statement => 'loop',
                     exp1      => $_[0]{exp1}->(),
                     exp2      => $_[0]{exp2}->(),
                     exp3      => $_[0]{exp3}->(),
                     content   => $_[0]{content}->() }
              }
            |
              <Pugs::Grammar::Perl6.block> <?ws>?
              { return { statement => 'loop',
                     content   => $_[0]{'Pugs::Grammar::Perl6.block'}->() }
              }
            |
              # XXX better error messages
              { return { die "invalid loop syntax" } }
           ]
        ) );
    __PACKAGE__->add_rule(
        'unless' =>  q( 
            <?ws> 
            $<exp1> := <Pugs::Grammar::Perl6.perl6_expression('no_blocks',0)> <?ws>?
            $<exp2> := <Pugs::Grammar::Perl6.block>        
        [
            <?ws>? else <?ws>? 
            $<exp3> := <Pugs::Grammar::Perl6.block>
                { return { 
                    statement => 'unless',
                    exp1 => $_[0]{exp1}->(),
                    exp2 => $_[0]{exp2}->(),
                    exp3 => $_[0]{exp3}->(),
                } }
        |
            <?ws>? elsif <?ws>? 
            $<exp3> := <Pugs::Grammar::Perl6.perl6_expression('no_blocks',0)> <?ws>?
            $<exp4> := <Pugs::Grammar::Perl6.block>
            [
                <?ws>? else <?ws>? 
                $<exp5> := <Pugs::Grammar::Perl6.block>
                { return { 
                    statement => 'unless',
                    exp1 => $_[0]{exp1}->(),
                    exp2 => $_[0]{exp2}->(),
                    exp3 => $_[0]{exp3}->(),
                    exp4 => $_[0]{exp4}->(),
                    exp5 => $_[0]{exp5}->(),
                } }
                
                # TODO: elsif ...
            |
                { return { 
                    statement => 'unless',
                    exp1 => $_[0]{exp1}->(),
                    exp2 => $_[0]{exp2}->(),
                    exp3 => $_[0]{exp3}->(),
                    exp4 => $_[0]{exp4}->(),
                } }
            ]
        |
            { return { 
                    statement => 'unless',
                    exp1 => $_[0]{exp1}->(),
                    exp2 => $_[0]{exp2}->(),
            } }
        ]
        ) );
    __PACKAGE__->add_rule(
        'if' =>  q( 
            <?ws> 
            $<exp1> := <Pugs::Grammar::Perl6.perl6_expression('no_blocks',0)> <?ws>?
            $<exp2> := <Pugs::Grammar::Perl6.block>        
        [
            <?ws>? else <?ws>? 
            $<exp3> := <Pugs::Grammar::Perl6.block>
                { return { 
                    statement => 'if',
                    exp1 => $_[0]{exp1}->(),
                    exp2 => $_[0]{exp2}->(),
                    exp3 => $_[0]{exp3}->(),
                } }
        |
            <?ws>? elsif <?ws>? 
            $<exp3> := <Pugs::Grammar::Perl6.perl6_expression('no_blocks',0)> <?ws>?
            $<exp4> := <Pugs::Grammar::Perl6.block>
            [
                <?ws>? else <?ws>? 
                $<exp5> := <Pugs::Grammar::Perl6.block>
                { return { 
                    statement => 'if',
                    exp1 => $_[0]{exp1}->(),
                    exp2 => $_[0]{exp2}->(),
                    exp3 => $_[0]{exp3}->(),
                    exp4 => $_[0]{exp4}->(),
                    exp5 => $_[0]{exp5}->(),
                } }
                
                # TODO: elsif ...
            |
                { return { 
                    statement => 'if',
                    exp1 => $_[0]{exp1}->(),
                    exp2 => $_[0]{exp2}->(),
                    exp3 => $_[0]{exp3}->(),
                    exp4 => $_[0]{exp4}->(),
                } }
            ]
        |
            { return { 
                    statement => 'if',
                    exp1 => $_[0]{exp1}->(),
                    exp2 => $_[0]{exp2}->(),
            } }
        ]
        ) );
    __PACKAGE__->add_rule(
        'repeat' =>  q( 
            <?ws> 
        [
          (while|until) <?ws>? <Pugs::Grammar::Perl6.perl6_expression('no_blocks',0)> <?ws>?
          <Pugs::Grammar::Perl6.block> <?ws>?
          { return { statement => 'repeat',
                     which     => $_[0][0]->(),
                     exp2      => $_[0]{'Pugs::Grammar::Perl6.perl6_expression'}->(),
                     postfix   => 1,
                     content   => $_[0]{'Pugs::Grammar::Perl6.block'}->() }
          }
        |
          <Pugs::Grammar::Perl6.block> <?ws>?
          (while|until) <?ws>? <Pugs::Grammar::Perl6.perl6_expression('no_blocks',0)> <?ws>?
          { return { statement => 'repeat',
                     which     => $_[0][0]->(),
                     exp2      => $_[0]{'Pugs::Grammar::Perl6.perl6_expression'}->(),
                     postfix   => 1,
                     content   => $_[0]{'Pugs::Grammar::Perl6.block'}->() }
          }
        |
            # XXX better error messages
            { return { die "invalid repeat syntax" } }
       ]
        ) );

    __PACKAGE__->recompile;
}


1;
