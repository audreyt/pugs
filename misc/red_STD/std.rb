# A ruby transliteration of src/perl6/STD.pm
# Sources to crib from:
#  v6/v6-KindaPerl6/compiled/ruby-kp6-mp6/kp6_runtime.rb
#  misc/pX/Common/redsix/redsix
#  misc/pX/Common/yet_another_regex_engine/Regexp_ModuleA.pm (perhaps)
# We'll pay the pain of sticking with ruby 1.8 for now, since folks
# seem to have trouble finding the real 1.9.0.
#
# Notes
# 
#
require 'prelude'



class Perl < Grammar
    attr_accessor :ws_from,:ws_to

    def _TOP; _UNIT( $env_vars[:unitstopper] || "_EOS" ); end

    module PrecOp
        def precop_mumble(m)
            defaults.each{|k,v| m[k] = v if not m.key? k }
            $env_vars[:thisopH][:top] = m;
            if not m.key?(:transparent)
                $env_vars[:thisopH][:prec] = m[:prec];
                $env_vars[:thisopH][:assoc] = m[:assoc];
            end
            return m;
        end
    end
    prec_op(:hyper             ,{ :transparent =>1                           })
    prec_op(:term              ,{ :prec =>"z="                               })
    prec_op(:methodcall        ,{ :prec =>"y="                               })
    prec_op(:autoincrement     ,{ :prec =>"x="                               })
    prec_op(:exponentiation    ,{ :prec =>"w=", :assoc =>:right, :assign =>1 })
    prec_op(:symbolic_unary    ,{ :prec =>"v="                               })
    prec_op(:multiplicative    ,{ :prec =>"u=", :assoc =>:left,  :assign =>1 })
    prec_op(:additive          ,{ :prec =>"t=", :assoc =>:left,  :assign =>1 })
    prec_op(:replication       ,{ :prec =>"s=", :assoc =>:left,  :assign =>1 })
    prec_op(:concatenation     ,{ :prec =>"r=", :assoc =>:left,  :assign =>1 })
    prec_op(:junctive_and      ,{ :prec =>"q=", :assoc =>:list,  :assign =>1 })
    prec_op(:junctive_or       ,{ :prec =>"p=", :assoc =>:list,  :assign =>1 })
    prec_op(:named_unary       ,{ :prec =>"o=",                              })
    prec_op(:nonchaining       ,{ :prec =>"n=", :assoc =>:non                })
    prec_op(:chaining          ,{ :prec =>"m=", :assoc =>:chain, :bool =>1   })
    prec_op(:tight_and         ,{ :prec =>"l=", :assoc =>:left,  :assign =>1 })
    prec_op(:tight_or          ,{ :prec =>"k=", :assoc =>:left,  :assign =>1 })
    prec_op(:conditional       ,{ :prec =>"j=", :assoc =>:right,             })
    prec_op(:item_assignment   ,{ :prec =>"i=", :assoc =>:right              })
    prec_op(:loose_unary       ,{ :prec =>"h=",                              })
    prec_op(:comma             ,{ :prec =>"g=", :assoc =>:list,              })
    prec_op(:list_infix        ,{ :prec =>"f=", :assoc =>:list,  :assign =>1 })
    prec_op(:list_assignment   ,{ :prec =>"i=", :sub =>"e=", :assoc =>:right })
    prec_op(:list_prefix       ,{ :prec =>"e=",                              })
    prec_op(:loose_and         ,{ :prec =>"d=", :assoc =>:left,  :assign =>1 })
    prec_op(:loose_or          ,{ :prec =>"c=", :assoc =>:left,  :assign =>1 })
    prec_op(:LOOSEST           ,{ :prec =>"a=!",                             })
    prec_op(:terminator        ,{ :prec =>"a=", :assoc =>:list               })
    LOOSESTS = "a=!"
    LOOSESTH = { :prec =>"a=!" }

    proto_token_simple('category')
    proto_token_simple('sigil')
    proto_token_simple('twigil')
    proto_token_simple('special_variable')
    proto_token_simple('version')
    proto_token_simple('term')
    proto_token_simple('quote')
    proto_token_defequiv('prefix','symbolic_unary')
    proto_token_defequiv('infix','additive')
    proto_token_defequiv('postfix','autoincrement')
    proto_token_endsym('dotty',' <.unsp>? ')
    proto_token_simple('circumfix')
    proto_token_simple('postcircumfix')
    proto_token_simple('regex_metachar')
    proto_token_simple('regex_backslash')
    proto_token_simple('regex_assertion')
    proto_token_simple('regex_mod_internal')
    proto_token_simple('quote_mod')
    proto_token_simple('q_backslash')
    proto_token_simple('qq_backslash')
    proto_token_endsym('trait_verb',' \s+ <nofat> ')
    proto_token_endsym('trait_auxiliary',' \s+ <nofat> ')
    proto_token_gtgt_nofat('type_declarator')
    proto_token_gtgt_nofat('scope_declarator')
    proto_token_gtgt_nofat('package_declarator')
    proto_token_gtgt_nofat('routine_declarator')
    proto_rule_gtgt_nofat('statement_prefix')
    proto_rule_endsym('statement_control',' <nofat> <?before \s | \'#\'> ')
    proto_rule_gtgt_nofat('statement_mod_cond')
    proto_rule_gtgt_nofat('statement_mod_loop')
    proto_token_simple('infix_prefix_meta_operator')
    proto_token_simple('infix_postfix_meta_operator')
    proto_token_simple('infix_circumfixfix_meta_operator')
    proto_token_simple('postfix_prefix_meta_operator')
    proto_token_simple('prefix_postfix_meta_operator')
    proto_token_simple('prefix_circumfix_meta_operator')

    proto_token_simple('terminator') #R added

    def dot_ws
        pos == ws_to and return true
        after(/\w/) and before(/\w/) and return false
        ws_from = pos
        starTOK{ unsp || (seqTOK{@scanner.scan(/\v/); heredoc}) || unv }
        ws_to = pos
    end

    def unsp
    end
    def unv
    end

    def expect_infix
        (infix && starTOK{infix_postfix_meta_operator}) ||
            infix_prefix_meta_operator || infix_circumfix_meta_operator
    end

    def prefix; false; end
    def prefix_circumfix_meta_operator; false; end
    def expect_postfix; false; end
    def adverbs; false; end

    ## term
    #R...missing...
    def_tokens_simple :infix,:methodcall,%w{ . }
    def_tokens_simple :postfix,:methodcall,%w{ -> }
    def_tokens_simple :postfix,:autoincrement,%w{ ++ -- }
    def_tokens_simple :prefix,:autoincrement,%w{ ++ -- }
    def_tokens_simple :infix,:exponentiation,%w{ ** }
    def_tokens_simple :prefix,:symbolic_unary,%w{ ! + - ~ ? = * ** ~^ +^ ?^ ^ | }
    def_tokens_simple :infix,:multiplicative,%w{ * / % +& +< << >> +> ~&> ~< ~> }
    def_tokens_simple :infix,:additive,%w{ + - +| +^ ~| ~^ ?| ?^ }
    #R...missing...
    def_tokens_simple :infix,:loose_and,%w{ and andthen }
    def_tokens_simple :infix,:loose_or,%w{ or xor orelse }
    def_tokens_before :terminator,:terminator,%w{ ; <== ==> --> ) ] \} !! }


    #R regex - ##Q why is this a regex?
    def stdstopper
        (@scanner.eos? ||
#R         terminator || statement_mod_cond || statement_mod_loop ||
#R         cent.pos == env[:endstmt] ||
#R         cent.pos == env[:endargs]
#R         #    | <$+unitstopper> #R?
false #R
         )
    end

    def pop(a);a.pop;end
    def push(a,e);a.push(e);end
    def reverse(a);a.reverse;end
    def item(h);raise "what does item do?";end
    def _EXPR(seenS, preclimH=nil, stopS=nil, *fateA) #R Args reordered!
        hereS_workaround = self

        preclimH ||= LOOSESTH
        stopS ||= method(:stdstopper)

        $env_vars.scope_enter(:inquoteS,:prevopS,:thisopH);
        
        my preclimS = preclimH[:prec];
        $env_vars[:inquoteS] = 0
        #    my terminatorA = before(lambda{|s| stop(s) } );
        #    return () if not terminatorA.empty? and terminatorA[0].bool;
        termstackA = []
        opstackA = []

        #R push opstackA, termH;         # (just a sentinel value)
        push opstackA, rand  #R will this work?

        hereS = nil
        if seenS 
            hereS = seenS;
        else 
            my tA = [expect_term()];
            hereS = tA[0];
        end
        push termstackA, hereS;
        say "In EXPR, at ", hereS_workaround.pos;

        reduce = lambda {
            say "entering reduce, termstack == ", termstackA.length, " opstack == ", opstackA.length;
            my opS = pop(opstackA);
            case opS[:assoc] 
            when 'chain' 
                say "reducing chain";
                chainA = []
                push chainA, pop(termstackA);
                push chainA, opS;
                while not opstackA.empty? 
                    break if opS[:prec] != opstackA[-1][:prec];
                    push chainA, pop(termstackA);
                    push chainA, pop(opstackA)[:top];
                end
                push chainA, pop(termstackA);
                opS[:top][:chain] = reverse chainA;
                push termstackA, opS[:top];
            when 'list' 
                say "reducing list";
                listA = []
                push listA, pop(termstackA);
                while not opstackA.empty? 
                    break if opS[:top][:sym] != opstackA[-1][:top][:sym];
                    push listA, pop(termstackA);
                    pop(opstackA);
                end
                push listA, pop(termstackA);
                opS[:top][:list] = reverse listA;
                push termstackA, opS[:top];
            else
                say "reducing";
                listA = []
                say termstackA.length;

                #opS[:top][:right] = pop termstackA;
                #opS[:top][:left] = pop termstackA;

                my _opH = opS;   # XXX anti-pugs hack
                _opH[:top][:right] = pop termstackA;
                _opH[:top][:left] = pop termstackA;
                opS = _opH;

                push termstackA, opS[:top];
            end
        }

        while true 
            say "In while true, at ", hereS_workaround.pos;
            my terminatorA = hereS_workaround.before(lambda{|s| stop(s) } );
            my tS = terminatorA[0];
            break if tS and terminatorA[0].bool;
            thisopH = {}
            #        my infixA = [hereS_workaround.expect_tight_infix(preclimS)];
            my infixA = [hereS_workaround.expect_infix()];
            my infixS = infixA[0];
            hereS = infixS;
        
            # XXX might want to allow this in a declaration though
            if not infixS;  hereS_workaround.panic("Can't have two terms in a row"); end

            if not thisopH.key?(:prec) 
                say "No prec case in thisop!";
                thisopH = terminatorH;
            end
            thisprecS = thisopH[:prec];
            # substitute precedence for listops
            thisopH[:prec] = thisopH[:sub] if thisopH[:sub];
            
            # Does new infix (or terminator) force any reductions?
            while opstackA[-1][:prec] < thisprecS 
                reduce();
            end
            
            # Not much point in reducing the sentinels...
            break if thisprecS < LOOSESTS;
            
            # Equal precedence, so use associativity to decide.
            if opstackA[-1][:prec] == thisprecS 
                case thisopH[:assoc] 
                when 'non' ;   hereS_workaround.panic("\"#{infixS}\" is not associative")
                when 'left' ;  reduce()   # reduce immediately
                when 'right';  # just shift
                when 'chain';  # just shift
                when 'list'                # if op differs reduce else shift
                    reduce() if thisopH[:top][:sym] != opstackA[-1][:top][:sym];
                else
                    hereS_workaround.panic("Unknown associativity \"#{thisopH[:assoc]}\" for \"#{infixS}\"")
                end
            end
            push opstackA, item(thisopH);
            my terminatorA = [hereS_workaround.before(lambda{|s| stop(s) } )];
            if not terminatorA.empty? and terminatorA[0].bool 
                hereS_workaround.panic("#{infixS.perl()} is missing right term");
            end
            thisopH = {}
            my tA = [hereS_workaround.expect_term()];
            hereS = tA[0];
            push termstackA, hereS;
            say "after push: ", termstackA.length;
        end
        reduce() while termstackA.length > 1;
        termstackA == 1 or hereS_workaround.panic("Internal operator parser error, termstack == #{termstackA.length}");
        $env_vars.scope_leave
        return termstackA[0];
    end

    def expect_term
        b = pos
        # queue up the prefixes to interleave with postfixes
        pre = starTOK lambda{
            m = _match_from(pos)
            if prefix_ = prefix
                m[:prec] = prefix_[:prec]
            elsif precircum = prefix_circumfix_meta_operator
                m[:prec] = precircum[:prec]
            else
                return false
            end
            # XXX assuming no precedence change
            starTOK{prefix_postfix_meta_operator}
            dot_ws
            m
        }

        _noun = noun or return fail_at(b)

        # also queue up any postfixes, since adverbs could change things
        postfix = starTOK{expect_postfix}
        dot_ws
        quesTOK{adverbs}

        # now push ops over the noun according to precedence.
        #    { make $¢.nounphrase(:noun($<noun>), :pre(@<pre>), :post(@<post>)) }
        _match_from(b,{:noun=>_noun,:postfix=>postfix})
    end
    
    def noun
        #R (pair || package_declarator || scope_declarator || plurality_declarator ||
        #R  routine_declarator || regex_declarator || type_declarator || circumfix ||
        ( variable || value || subcall || capterm || sigterm || term || statement_prefix)
    end
    def variable; false; end
    def value; quote || number || version || fulltypename; end
    def quote; false; end
    def number; dec_number || integer || rad_number; end
    def integer
        _match_pat %r{
            0 ( b [01]+           ( _ [01]+ )*
              | o [0-7]+         ( _ [0-7]+ )*
              | x [0-9a-fA-F]+ ( _ [0-9a-fA-F]+ )*
              | d \d+               ( _ \d+)*
              | \d+(_\d+)*
              )
            | \d+(_\d+)*
        }x
    end
    def dec_number; false; end


    def heredoc
    end
end

p Perl.new(('42')).noun()
p Perl.new(('42')).expect_term()
p Perl.new(('+')).infix()
p Perl.new(('42'))._EXPR(false)

say "Starting...";
my $r = Perl.new(('42')).expect_infix();
say $r;
exit;
say "WHAT\t", $r.WHAT;
say "BOOL\t", $r.bool;
say "FROM\t", $r.from;
say "TO\t", $r.to;

## vim: expandtab sw=4
## Local Variables:
## ruby-indent-level: 4
## End:
