{ package KindaPerl6::Grammar; 
# Do not edit this file - Perl 5 generated by KindaPerl6
use v5;
use strict;
no strict "vars";
use constant KP6_DISABLE_INSECURE_CODE => 0;
use KindaPerl6::Runtime::Perl5::Runtime;
my $_MODIFIED; INIT { $_MODIFIED = {} }
INIT { $_ = ::DISPATCH($::Scalar, "new", { modified => $_MODIFIED, name => "$_" } ); }
do { do { if (::DISPATCH(::DISPATCH(::DISPATCH( $GLOBAL::Code_VAR_defined, 'APPLY', $::KindaPerl6::Grammar )
,"true"),"p5landish") ) { }  else { do { do {::MODIFIED($::KindaPerl6::Grammar);
$::KindaPerl6::Grammar = ::DISPATCH( ::DISPATCH( $::Class, 'new', ::DISPATCH( $::Str, 'new', 'KindaPerl6::Grammar' )
 )
, 'PROTOTYPE',  )
} } } }
; do { use vars qw($_rule_token_p5_modifier); $_rule_token_p5_modifier = qr (?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'create', pos(), \$_ ]; $GLOBAL::_M2 = $GLOBAL::_M; })(?:(?::P5)|(?::Perl5))(?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'to', pos() ]; $GLOBAL::_M2 = $GLOBAL::_M; }) x; 
::DISPATCH(::DISPATCH($::KindaPerl6::Grammar,"HOW"),"add_method", ::DISPATCH( $::Str, "new", "token_p5_modifier" ), ::DISPATCH( $::Method, "new", { code => sub { local $GLOBAL::_Class = shift; undef $GLOBAL::_M2; ( ref($_) ? $_->{_dispatch}( $_, "Str" )->{_value} : $_ ) =~ /$_rule_token_p5_modifier/; if ( $GLOBAL::_M2->[1] eq 'to' ) { Match::from_global_data( $GLOBAL::_M2 ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; } else { $MATCH = $GLOBAL::MATCH = Match->new(); } @Match::Matches = (); return $MATCH; } } ), ); } 
; do { use vars qw($_rule_token_p5_body); $_rule_token_p5_body = qr (?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'create', pos(), \$_ ]; $GLOBAL::_M2 = $GLOBAL::_M; })(?:(?:\\(?:\n\r?|\r\n?|\X)(?:(??{ eval '$_rule_token_p5_body' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture_to_array", "token_p5_body" ]; })))|(?:(?!(?:(?:\})))(?:\n\r?|\r\n?|\X)(?:(??{ eval '$_rule_token_p5_body' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture_to_array", "token_p5_body" ]; })))|(?:(?:(??{ eval '$_rule_''' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "''" ]; }))))(?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'to', pos() ]; $GLOBAL::_M2 = $GLOBAL::_M; }) x; 
::DISPATCH(::DISPATCH($::KindaPerl6::Grammar,"HOW"),"add_method", ::DISPATCH( $::Str, "new", "token_p5_body" ), ::DISPATCH( $::Method, "new", { code => sub { local $GLOBAL::_Class = shift; undef $GLOBAL::_M2; ( ref($_) ? $_->{_dispatch}( $_, "Str" )->{_value} : $_ ) =~ /$_rule_token_p5_body/; if ( $GLOBAL::_M2->[1] eq 'to' ) { Match::from_global_data( $GLOBAL::_M2 ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; } else { $MATCH = $GLOBAL::MATCH = Match->new(); } @Match::Matches = (); return $MATCH; } } ), ); } 
; do { use vars qw($_rule_token_P5); $_rule_token_P5 = qr (?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'create', pos(), \$_ ]; $GLOBAL::_M2 = $GLOBAL::_M; })(?:(?:token(?:(??{ eval '$_rule_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_opt_name' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "opt_name" ]; }))(?:(??{ eval '$_rule_opt_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_token_p5_modifier' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "token_p5_modifier" ]; }))(?:(??{ eval '$_rule_opt_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))\{(?:(??{ eval '$_rule_token_p5_body' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "token_p5_body" ]; }))\}(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $::Token, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'name' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'opt_name' )
 )
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'regex' )
, value           => ::DISPATCH( $::P5Token, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'regex' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'token_p5_body' )
 )
 )
,  } ),  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'sym' )
, value           => $::Undef,  } ),  )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; })))(?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'to', pos() ]; $GLOBAL::_M2 = $GLOBAL::_M; }) x; 
::DISPATCH(::DISPATCH($::KindaPerl6::Grammar,"HOW"),"add_method", ::DISPATCH( $::Str, "new", "token_P5" ), ::DISPATCH( $::Method, "new", { code => sub { local $GLOBAL::_Class = shift; undef $GLOBAL::_M2; ( ref($_) ? $_->{_dispatch}( $_, "Str" )->{_value} : $_ ) =~ /$_rule_token_P5/; if ( $GLOBAL::_M2->[1] eq 'to' ) { Match::from_global_data( $GLOBAL::_M2 ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; } else { $MATCH = $GLOBAL::MATCH = Match->new(); } @Match::Matches = (); return $MATCH; } } ), ); } 
 }
; 1 }
