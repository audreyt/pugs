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
; do { use vars qw($_rule_control); $_rule_control = qr (?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'create', pos(), \$_ ]; $GLOBAL::_M2 = $GLOBAL::_M; })(?:(?:(?:(??{ eval '$_rule_ctrl_return' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "ctrl_return" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'ctrl_return' )
 )
 )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; }))|(?:(?:(??{ eval '$_rule_ctrl_leave' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "ctrl_leave" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'ctrl_leave' )
 )
 )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; }))|(?:(?:(??{ eval '$_rule_if' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "if" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'if' )
 )
 )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; }))|(?:(?:(??{ eval '$_rule_unless' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "unless" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'unless' )
 )
 )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; }))|(?:(?:(??{ eval '$_rule_when' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "when" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'when' )
 )
 )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; }))|(?:(?:(??{ eval '$_rule_for' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "for" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'for' )
 )
 )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; }))|(?:(?:(??{ eval '$_rule_while' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "while" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'while' )
 )
 )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; }))|(?:(?:(??{ eval '$_rule_apply' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "apply" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'apply' )
 )
 )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; })))(?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'to', pos() ]; $GLOBAL::_M2 = $GLOBAL::_M; }) x; 
::DISPATCH(::DISPATCH($::KindaPerl6::Grammar,"HOW"),"add_method", ::DISPATCH( $::Str, "new", "control" ), ::DISPATCH( $::Method, "new", { code => sub { local $GLOBAL::_Class = shift; undef $GLOBAL::_M2; ( ref($_) ? $_->{_dispatch}( $_, "Str" )->{_value} : $_ ) =~ /$_rule_control/; if ( $GLOBAL::_M2->[1] eq 'to' ) { Match::from_global_data( $GLOBAL::_M2 ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; } else { $MATCH = $GLOBAL::MATCH = Match->new(); } @Match::Matches = (); return $MATCH; } } ), ); } 
; do { use vars qw($_rule_block1); $_rule_block1 = qr (?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'create', pos(), \$_ ]; $GLOBAL::_M2 = $GLOBAL::_M; })(?:(?:\{(?:(??{ eval '$_rule_opt_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { ::DISPATCH( $COMPILER::Code_add_pad, 'APPLY',  )
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; })(?:(??{ eval '$_rule_exp_stmts' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "exp_stmts" ]; }))(?:(??{ eval '$_rule_opt_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))\}(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { my $env; $env = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$env' } )  unless defined $env; INIT { $env = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$env' } ) }
;
do {::MODIFIED($env);
$env = ::DISPATCH( $COMPILER::Code_current_pad, 'APPLY',  )
}; ::DISPATCH( $COMPILER::Code_drop_pad, 'APPLY',  )
; return(::DISPATCH( $::Lit::Code, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'pad' )
, value           => $env,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'state' )
, value           => ::DISPATCH( $::Hash, 'new', { _hash => {  } }
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'sig' )
, value           => ::DISPATCH( $::Sig, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'invocant' )
, value           => $::Undef,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'positional' )
, value           => ::DISPATCH( $::Array, 'new', { _array => [] }
 )
,  } ),  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'body' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'exp_stmts' )
 )
 )
,  } ),  )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; })))(?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'to', pos() ]; $GLOBAL::_M2 = $GLOBAL::_M; }) x; 
::DISPATCH(::DISPATCH($::KindaPerl6::Grammar,"HOW"),"add_method", ::DISPATCH( $::Str, "new", "block1" ), ::DISPATCH( $::Method, "new", { code => sub { local $GLOBAL::_Class = shift; undef $GLOBAL::_M2; ( ref($_) ? $_->{_dispatch}( $_, "Str" )->{_value} : $_ ) =~ /$_rule_block1/; if ( $GLOBAL::_M2->[1] eq 'to' ) { Match::from_global_data( $GLOBAL::_M2 ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; } else { $MATCH = $GLOBAL::MATCH = Match->new(); } @Match::Matches = (); return $MATCH; } } ), ); } 
; do { use vars qw($_rule_block2); $_rule_block2 = qr (?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'create', pos(), \$_ ]; $GLOBAL::_M2 = $GLOBAL::_M; })(?:(?:(?:(??{ eval '$_rule_block1' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "block1" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'block1' )
 )
 )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; })))(?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'to', pos() ]; $GLOBAL::_M2 = $GLOBAL::_M; }) x; 
::DISPATCH(::DISPATCH($::KindaPerl6::Grammar,"HOW"),"add_method", ::DISPATCH( $::Str, "new", "block2" ), ::DISPATCH( $::Method, "new", { code => sub { local $GLOBAL::_Class = shift; undef $GLOBAL::_M2; ( ref($_) ? $_->{_dispatch}( $_, "Str" )->{_value} : $_ ) =~ /$_rule_block2/; if ( $GLOBAL::_M2->[1] eq 'to' ) { Match::from_global_data( $GLOBAL::_M2 ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; } else { $MATCH = $GLOBAL::MATCH = Match->new(); } @Match::Matches = (); return $MATCH; } } ), ); } 
; do { use vars qw($_rule_if); $_rule_if = qr (?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'create', pos(), \$_ ]; $GLOBAL::_M2 = $GLOBAL::_M; })(?:(?:if(?:(??{ eval '$_rule_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_exp' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "exp" ]; }))(?:(??{ eval '$_rule_opt_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_block1' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "block1" ]; }))(?:(?:(?:(??{ eval '$_rule_opt_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))else(?:(??{ eval '$_rule_opt_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_block2' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "block2" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $::If, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'cond' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'exp' )
 )
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'body' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'block1' )
 )
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'otherwise' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'block2' )
 )
 )
,  } ),  )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; }))|(?:(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $::If, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'cond' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'exp' )
 )
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'body' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'block1' )
 )
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'otherwise' )
, value           => $::Undef,  } ),  )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; })))))(?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'to', pos() ]; $GLOBAL::_M2 = $GLOBAL::_M; }) x; 
::DISPATCH(::DISPATCH($::KindaPerl6::Grammar,"HOW"),"add_method", ::DISPATCH( $::Str, "new", "if" ), ::DISPATCH( $::Method, "new", { code => sub { local $GLOBAL::_Class = shift; undef $GLOBAL::_M2; ( ref($_) ? $_->{_dispatch}( $_, "Str" )->{_value} : $_ ) =~ /$_rule_if/; if ( $GLOBAL::_M2->[1] eq 'to' ) { Match::from_global_data( $GLOBAL::_M2 ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; } else { $MATCH = $GLOBAL::MATCH = Match->new(); } @Match::Matches = (); return $MATCH; } } ), ); } 
; do { use vars qw($_rule_unless); $_rule_unless = qr (?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'create', pos(), \$_ ]; $GLOBAL::_M2 = $GLOBAL::_M; })(?:(?:unless(?:(??{ eval '$_rule_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_exp' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "exp" ]; }))(?:(??{ eval '$_rule_opt_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_block1' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "block1" ]; }))(?:(?:(?:(??{ eval '$_rule_opt_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))else(?:(??{ eval '$_rule_opt_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_block2' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "block2" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $::If, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'cond' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'exp' )
 )
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'body' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'block2' )
 )
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'otherwise' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'block1' )
 )
 )
,  } ),  )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; }))|(?:(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $::If, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'cond' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'exp' )
 )
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'body' )
, value           => $::Undef,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'otherwise' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'block1' )
 )
 )
,  } ),  )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; })))))(?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'to', pos() ]; $GLOBAL::_M2 = $GLOBAL::_M; }) x; 
::DISPATCH(::DISPATCH($::KindaPerl6::Grammar,"HOW"),"add_method", ::DISPATCH( $::Str, "new", "unless" ), ::DISPATCH( $::Method, "new", { code => sub { local $GLOBAL::_Class = shift; undef $GLOBAL::_M2; ( ref($_) ? $_->{_dispatch}( $_, "Str" )->{_value} : $_ ) =~ /$_rule_unless/; if ( $GLOBAL::_M2->[1] eq 'to' ) { Match::from_global_data( $GLOBAL::_M2 ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; } else { $MATCH = $GLOBAL::MATCH = Match->new(); } @Match::Matches = (); return $MATCH; } } ), ); } 
; do { use vars qw($_rule_when); $_rule_when = qr (?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'create', pos(), \$_ ]; $GLOBAL::_M2 = $GLOBAL::_M; })(?:(?:when(?:(??{ eval '$_rule_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_exp_seq' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "exp_seq" ]; }))(?:(??{ eval '$_rule_opt_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_block1' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "block1" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $::When, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'parameters' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'exp_seq' )
 )
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'body' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'block1' )
 )
 )
,  } ),  )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; })))(?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'to', pos() ]; $GLOBAL::_M2 = $GLOBAL::_M; }) x; 
::DISPATCH(::DISPATCH($::KindaPerl6::Grammar,"HOW"),"add_method", ::DISPATCH( $::Str, "new", "when" ), ::DISPATCH( $::Method, "new", { code => sub { local $GLOBAL::_Class = shift; undef $GLOBAL::_M2; ( ref($_) ? $_->{_dispatch}( $_, "Str" )->{_value} : $_ ) =~ /$_rule_when/; if ( $GLOBAL::_M2->[1] eq 'to' ) { Match::from_global_data( $GLOBAL::_M2 ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; } else { $MATCH = $GLOBAL::MATCH = Match->new(); } @Match::Matches = (); return $MATCH; } } ), ); } 
; do { use vars qw($_rule_for); $_rule_for = qr (?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'create', pos(), \$_ ]; $GLOBAL::_M2 = $GLOBAL::_M; })(?:(?:for(?:(??{ eval '$_rule_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_exp' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "exp" ]; }))(?:(??{ eval '$_rule_opt_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_arrow_sub' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "arrow_sub" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $::Call, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'hyper' )
, value           => ::DISPATCH( $::Str, 'new', '' )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'arguments' )
, value           => ::DISPATCH( $::Array, 'new', { _array => [::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'arrow_sub' )
 )
 )
] }
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'method' )
, value           => ::DISPATCH( $::Str, 'new', 'for' )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'invocant' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'exp' )
 )
 )
,  } ),  )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; })))(?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'to', pos() ]; $GLOBAL::_M2 = $GLOBAL::_M; }) x; 
::DISPATCH(::DISPATCH($::KindaPerl6::Grammar,"HOW"),"add_method", ::DISPATCH( $::Str, "new", "for" ), ::DISPATCH( $::Method, "new", { code => sub { local $GLOBAL::_Class = shift; undef $GLOBAL::_M2; ( ref($_) ? $_->{_dispatch}( $_, "Str" )->{_value} : $_ ) =~ /$_rule_for/; if ( $GLOBAL::_M2->[1] eq 'to' ) { Match::from_global_data( $GLOBAL::_M2 ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; } else { $MATCH = $GLOBAL::MATCH = Match->new(); } @Match::Matches = (); return $MATCH; } } ), ); } 
; do { use vars qw($_rule_while); $_rule_while = qr (?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'create', pos(), \$_ ]; $GLOBAL::_M2 = $GLOBAL::_M; })(?:(?:while(?:(??{ eval '$_rule_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_exp' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "exp" ]; }))(?:(??{ eval '$_rule_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_block1' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "block1" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $::While, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'cond' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'exp' )
 )
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'body' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'block1' )
 )
 )
,  } ),  )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; })))(?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'to', pos() ]; $GLOBAL::_M2 = $GLOBAL::_M; }) x; 
::DISPATCH(::DISPATCH($::KindaPerl6::Grammar,"HOW"),"add_method", ::DISPATCH( $::Str, "new", "while" ), ::DISPATCH( $::Method, "new", { code => sub { local $GLOBAL::_Class = shift; undef $GLOBAL::_M2; ( ref($_) ? $_->{_dispatch}( $_, "Str" )->{_value} : $_ ) =~ /$_rule_while/; if ( $GLOBAL::_M2->[1] eq 'to' ) { Match::from_global_data( $GLOBAL::_M2 ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; } else { $MATCH = $GLOBAL::MATCH = Match->new(); } @Match::Matches = (); return $MATCH; } } ), ); } 
; do { use vars qw($_rule_ctrl_leave); $_rule_ctrl_leave = qr (?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'create', pos(), \$_ ]; $GLOBAL::_M2 = $GLOBAL::_M; })(?:(?:leave(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $::Leave, 'new',  )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; })))(?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'to', pos() ]; $GLOBAL::_M2 = $GLOBAL::_M; }) x; 
::DISPATCH(::DISPATCH($::KindaPerl6::Grammar,"HOW"),"add_method", ::DISPATCH( $::Str, "new", "ctrl_leave" ), ::DISPATCH( $::Method, "new", { code => sub { local $GLOBAL::_Class = shift; undef $GLOBAL::_M2; ( ref($_) ? $_->{_dispatch}( $_, "Str" )->{_value} : $_ ) =~ /$_rule_ctrl_leave/; if ( $GLOBAL::_M2->[1] eq 'to' ) { Match::from_global_data( $GLOBAL::_M2 ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; } else { $MATCH = $GLOBAL::MATCH = Match->new(); } @Match::Matches = (); return $MATCH; } } ), ); } 
; do { use vars qw($_rule_ctrl_return); $_rule_ctrl_return = qr (?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'create', pos(), \$_ ]; $GLOBAL::_M2 = $GLOBAL::_M; })(?:(?:return(?:(??{ eval '$_rule_ws' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "discard_capture" ]; }))(?:(??{ eval '$_rule_exp' })(?{ local $GLOBAL::_M = [ $GLOBAL::_M, "named_capture", "exp" ]; }))(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $::Return, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'result' )
, value           => ::DISPATCH( $GLOBAL::Code_prefix_58__60__36__62_, 'APPLY', ::DISPATCH( $MATCH, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'exp' )
 )
 )
,  } ),  )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; }))|(?:return(?{ local $GLOBAL::_M = $GLOBAL::_M; Match::from_global_data( $GLOBAL::_M ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; @Match::Matches = (); my $ret = ( sub {do { return(::DISPATCH( $::Return, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'result' )
, value           => ::DISPATCH( $::Val::Undef, 'new',  )
,  } ),  )
)
 }; "974^213" } )->();if ( $ret ne "974^213" ) {$GLOBAL::_M = [ [ @$GLOBAL::_M ], "result", $ret ]; }; })))(?{ local $GLOBAL::_M = [ $GLOBAL::_M, 'to', pos() ]; $GLOBAL::_M2 = $GLOBAL::_M; }) x; 
::DISPATCH(::DISPATCH($::KindaPerl6::Grammar,"HOW"),"add_method", ::DISPATCH( $::Str, "new", "ctrl_return" ), ::DISPATCH( $::Method, "new", { code => sub { local $GLOBAL::_Class = shift; undef $GLOBAL::_M2; ( ref($_) ? $_->{_dispatch}( $_, "Str" )->{_value} : $_ ) =~ /$_rule_ctrl_return/; if ( $GLOBAL::_M2->[1] eq 'to' ) { Match::from_global_data( $GLOBAL::_M2 ); $MATCH = $GLOBAL::MATCH = pop @Match::Matches; } else { $MATCH = $GLOBAL::MATCH = Match->new(); } @Match::Matches = (); return $MATCH; } } ), ); } 
 }
; 1 }
