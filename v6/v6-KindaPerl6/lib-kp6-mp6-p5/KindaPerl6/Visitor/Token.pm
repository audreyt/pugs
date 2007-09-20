# Do not edit this file - Generated by MiniPerl6
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;
package KindaPerl6::Visitor::Token;
sub new { shift; bless { @_ }, "KindaPerl6::Visitor::Token" }
sub visit { my $self = shift; my $List__ = \@_; my $node; my $node_name; do {  $node = $List__->[0];  $node_name = $List__->[1]; [$node, $node_name] }; do { if (($node_name eq 'Token')) { my  $perl6_source = $node->regex()->emit_token();my  $source = ('method ' . ($node->name() . (' ( $str, $pos ) { ' . ('if (%*ENV{"KP6_TOKEN_DEBUGGER"}) { say ">>> token ' . ($node->name() . (' at " ~ $pos ~ " of (" ~ $str ~ ")"; };' . ('if (!(defined($str))) { $str = $_; };  my $MATCH;' . ('$MATCH = Match.new(); $MATCH.match_str = $str; $MATCH.from = $pos; $MATCH.to = ($pos + 0); $MATCH.bool = 1; ' . ('$MATCH.bool = ' . ($perl6_source . ('; ' . ('if (%*ENV{"KP6_TOKEN_DEBUGGER"}) { if ($MATCH.bool) { say "<<< token ' . ($node->name() . (' returned true to ("~$MATCH.to~")"; } else {say "<<< token ' . ($node->name() . (' returned false "; } };' . 'return $MATCH }'))))))))))))))));my  $ast = KindaPerl6::Grammar->term($source);return(${$ast}) } else {  } }; 0 }


;
package Rule;
sub new { shift; bless { @_ }, "Rule" }
sub constant { my $List__ = \@_; my $str; do {  $str = $List__->[0]; [$str] }; my  $len = Main::chars($str, ); do { if (($str eq Main::backslash())) { $str = (Main::backslash() . Main::backslash()) } else {  } }; do { if (($str eq Main::singlequote())) { $str = (Main::backslash() . Main::singlequote()) } else {  } }; do { if ($len) { ('do {if (length($str) <  ' . ($len . (') {(0)} else { if (' . (Main::singlequote() . ($str . (Main::singlequote() . (' eq substr($str, $MATCH.to, ' . ($len . (')) {' . ('$MATCH.to = (' . ($len . ' + $MATCH.to);  1;} else {(0)}}}'))))))))))) } else { return('1') } } }


;
package Rule::Quantifier;
sub new { shift; bless { @_ }, "Rule::Quantifier" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; $self->{term}->emit_token() }


;
package Rule::Or;
sub new { shift; bless { @_ }, "Rule::Or" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; ('do { ' . ('my $pos1 = ($MATCH.to + 0); do{ ' . (Main::join([ map { $_->emit_token() } @{ $self->{or} } ], '} || do { $MATCH.to = ($pos1 + 0); ') . '} }'))) }


;
package Rule::Concat;
sub new { shift; bless { @_ }, "Rule::Concat" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; ('(' . (Main::join([ map { $_->emit_token() } @{ $self->{concat} } ], ' && ') . ')')) }


;
package Rule::Subrule;
sub new { shift; bless { @_ }, "Rule::Subrule" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; do { if ((substr($self->{metasyntax}, 0, 1) eq Main::singlequote())) { return(Rule::constant(substr(substr($self->{metasyntax}, 1), 0, (Main::chars($self->{metasyntax}, ) - 2)))) } else {  } }; my  $meth = ((1 + index($self->{metasyntax}, '.')) ? $self->{metasyntax} : ('self.' . $self->{metasyntax})); return(('do { ' . ('my $m2 = ' . ($meth . ('($str, $MATCH.to); ' . ('if $m2 { $MATCH.to = ($m2.to + 0); $MATCH{\'' . ($self->{metasyntax} . ('\'} = $m2; 1 } else { 0 } ' . '}')))))))) }


;
package Rule::SubruleNoCapture;
sub new { shift; bless { @_ }, "Rule::SubruleNoCapture" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; my  $meth = ((1 + index($self->{metasyntax}, '.')) ? $self->{metasyntax} : ('self.' . $self->{metasyntax})); ('do { ' . ('my $m2 = ' . ($meth . ('($str, $MATCH.to); ' . ('if $m2 { $MATCH.to = ($m2.to + 0); 1 } else { 0 } ' . '}'))))) }


;
package Rule::Var;
sub new { shift; bless { @_ }, "Rule::Var" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; my  $table = { '$' => '$','@' => '$List_','%' => '$Hash_','&' => '$Code_', }; ($table->{$self->{sigil}} . $self->{name}) }


;
package Rule::Constant;
sub new { shift; bless { @_ }, "Rule::Constant" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; my  $str = $self->{constant}; Rule::constant($str) }


;
package Rule::Dot;
sub new { shift; bless { @_ }, "Rule::Dot" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; ('do { if (\'\' ne substr( $str, $MATCH.to, 1 )) {' . ('   ($MATCH.to = (1 + $MATCH.to )); 1 } else {' . ('   0 } ' . '}'))) }


;
package Rule::SpecialChar;
sub new { shift; bless { @_ }, "Rule::SpecialChar" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; my  $char = $self->{char}; do { if (($char eq 'n')) { my  $rul = Rule::SubruleNoCapture->new( 'metasyntax' => 'newline', );$rul = $rul->emit_token();return($rul) } else {  } }; do { if (($char eq 'N')) { my  $rul = Rule::SubruleNoCapture->new( 'metasyntax' => 'not_newline', );$rul = $rul->emit_token();return($rul) } else {  } }; do { if (($char eq 'd')) { my  $rul = Rule::SubruleNoCapture->new( 'metasyntax' => 'digit', );$rul = $rul->emit_token();return($rul) } else {  } }; do { if (($char eq 's')) { my  $rul = Rule::SubruleNoCapture->new( 'metasyntax' => 'space', );$rul = $rul->emit_token();return($rul) } else {  } }; return(Rule::constant($char)) }


;
package Rule::Block;
sub new { shift; bless { @_ }, "Rule::Block" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; return(('do { ' . ('my $ret = self.' . ($self->{closure} . ('($MATCH);' . ('if $ret ne "sTrNgE V4l" {' . ('if (%*ENV{"KP6_TOKEN_DEBUGGER"}) { say "<<< some closure returing... " }; ' . ('$MATCH.result = $ret; ' . ('$MATCH.bool = 1; ' . ('return $MATCH;' . ('};' . ('1' . '}')))))))))))) }


;
package Rule::InterpolateVar;
sub new { shift; bless { @_ }, "Rule::InterpolateVar" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; Main::say(('# TODO: interpolate var ' . ($self->{var}->emit_token() . ''))); die() }


;
package Rule::NamedCapture;
sub new { shift; bless { @_ }, "Rule::NamedCapture" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; Main::say(('# TODO: named capture ' . ($self->{ident} . (' := ' . ($self->{rule}->emit_token() . ''))))); die() }


;
package Rule::Before;
sub new { shift; bless { @_ }, "Rule::Before" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; do { if (($self->{assertion_modifier} eq '!')) { return(('do { ' . ('my $MATCH; ' . ('$MATCH = Match.new(); $MATCH.match_str = $str; $MATCH.from = $pos; $MATCH.to = ($pos + 0); $MATCH.bool = 1; ' . ('$MATCH.bool = !(' . ($self->{rule}->emit_token() . ('); $MATCH.to = ($MATCH.from + 0); ' . ('$MATCH.bool; ' . '}')))))))) } else { return(('do { ' . ('my $MATCH; ' . ('$MATCH = Match.new(); $MATCH.match_str = $str; $MATCH.from = $pos; $MATCH.to = ($pos + 0); $MATCH.bool = 1; ' . ('$MATCH.bool =  ' . ($self->{rule}->emit_token() . ('; $MATCH.to = ($MATCH.from + 0); ' . ('$MATCH.bool; ' . '}')))))))) } } }


;
package Rule::NegateCharClass;
sub new { shift; bless { @_ }, "Rule::NegateCharClass" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; Main::say('TODO NegateCharClass'); die() }


;
package Rule::CharClass;
sub new { shift; bless { @_ }, "Rule::CharClass" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; Main::say('TODO CharClass'); die() }


;
package Rule::Capture;
sub new { shift; bless { @_ }, "Rule::Capture" }
sub emit_token { my $self = shift; my $List__ = \@_; do { [] }; Main::say('TODO RuleCapture'); die() }


;
1;
