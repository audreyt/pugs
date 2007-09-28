# Do not edit this file - Generated by MiniPerl6
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;
package KindaPerl6::Visitor::EmitTokenC;
sub new { shift; bless { @_ }, "KindaPerl6::Visitor::EmitTokenC" }
sub visit { my $self = shift; my $List__ = \@_; my $node; my $node_name; do {  $node = $List__->[0];  $node_name = $List__->[1]; [$node, $node_name] }; $node->emit_c() }


;
package Token;
sub new { shift; bless { @_ }, "Token" }
sub emit_c { my $self = shift; my $List__ = \@_; do { [] }; ('match* ' . (Main::mangle_ident(($KindaPerl6::Visitor::EmitPerl5::current_compunit . $self->{name})) . (' (char *str,int pos) {match* m = malloc(sizeof(match));m->match_str = str;m->from=pos;m->boolean = (' . ($self->{regex}->emit_c() . (');m->to = pos;return m;}' . Main::newline()))))) }


;
package CompUnit;
sub new { shift; bless { @_ }, "CompUnit" }
sub emit_c { my $self = shift; my $List__ = \@_; do { [] }; $self->{body}->emit_c() }


;
package Lit::Code;
sub new { shift; bless { @_ }, "Lit::Code" }
sub emit_c { my $self = shift; my $List__ = \@_; do { [] }; my  $source = ''; do { for my $node ( @{$self->{body}} ) { do { if (Main::isa($node, 'Token')) { $source = ($source . $node->emit_c()) } else {  } } } }; $source }


;
package Rule::Or;
sub new { shift; bless { @_ }, "Rule::Or" }
sub emit_c { my $self = shift; my $List__ = \@_; do { [] }; ('({int saved_pos=pos;' . (Main::join([ map { $_->emit_c() } @{ $self->{or} } ], '||') . '|| (pos=saved_pos,0);})')) }


;
package Rule::Concat;
sub new { shift; bless { @_ }, "Rule::Concat" }
sub emit_c { my $self = shift; my $List__ = \@_; do { [] }; ('(' . (Main::join([ map { $_->emit_c() } @{ $self->{concat} } ], '&&') . ')')) }


;
package Rule::Constant;
sub new { shift; bless { @_ }, "Rule::Constant" }
sub emit_c { my $self = shift; my $List__ = \@_; do { [] }; ('(strncmp("' . ($self->{constant} . ('",str+pos,' . (length($self->{constant}) . (') == 0 && (pos += ' . (length($self->{constant}) . '))')))))) }


;
package Rule::Block;
sub new { shift; bless { @_ }, "Rule::Block" }
sub emit_c { my $self = shift; my $List__ = \@_; do { [] }; ('printf("' . ($self->{closure} . '")')) }


;
package Rule::Subrule;
sub new { shift; bless { @_ }, "Rule::Subrule" }
sub emit_c { my $self = shift; my $List__ = \@_; do { [] }; ('({match* submatch=' . (Main::mangle_ident($self->{metasyntax}) . '(str,pos);pos = submatch->to;int boolean = submatch->boolean;free(submatch);boolean;})')) }


;
package Rule::SubruleNoCapture;
sub new { shift; bless { @_ }, "Rule::SubruleNoCapture" }
sub emit_c { my $self = shift; my $List__ = \@_; do { [] }; ('({match* submatch=' . (Main::mangle_ident($self->{metasyntax}) . '(str,pos);pos = submatch->to;int boolean = submatch->boolean;free(submatch);boolean;})')) }


;
package Rule::Dot;
sub new { shift; bless { @_ }, "Rule::Dot" }
sub emit_c { my $self = shift; my $List__ = \@_; do { [] }; 'printf("Rule::Dot stub")' }


;
package Rule::SpecialChar;
sub new { shift; bless { @_ }, "Rule::SpecialChar" }
sub emit_c { my $self = shift; my $List__ = \@_; do { [] }; 'printf("Rule::SpecialChar stub")' }


;
package Rule::Before;
sub new { shift; bless { @_ }, "Rule::Before" }
sub emit_c { my $self = shift; my $List__ = \@_; do { [] }; 'printf("Rule::Before stub")' }


;
1;
