{ package KindaPerl6::Visitor::ShortCircuit; 
# Do not edit this file - Perl 5 generated by KindaPerl6
use v5;
use strict;
no strict "vars";
use constant KP6_DISABLE_INSECURE_CODE => 0;
use KindaPerl6::Runtime::Perl5::Runtime;
my $_MODIFIED; INIT { $_MODIFIED = {} }
INIT { $_ = ::DISPATCH($::Scalar, "new", { modified => $_MODIFIED, name => "$_" } ); }
do { our $Code_new_pad = ::DISPATCH( $::Routine, 'new', { modified => $_MODIFIED, name => '$Code_new_pad' } ) ;
;
our $Code_thunk = ::DISPATCH( $::Routine, 'new', { modified => $_MODIFIED, name => '$Code_thunk' } ) ;
;
do { if (::DISPATCH(::DISPATCH(::DISPATCH( $GLOBAL::Code_VAR_defined, 'APPLY', $::KindaPerl6::Visitor::ShortCircuit )
,"true"),"p5landish") ) { }  else { do { our $Code_new_pad = ::DISPATCH( $::Routine, 'new', { modified => $_MODIFIED, name => '$Code_new_pad' } ) ;
;
our $Code_thunk = ::DISPATCH( $::Routine, 'new', { modified => $_MODIFIED, name => '$Code_thunk' } ) ;
;
do {::MODIFIED($::KindaPerl6::Visitor::ShortCircuit);
$::KindaPerl6::Visitor::ShortCircuit = ::DISPATCH( ::DISPATCH( $::Class, 'new', ::DISPATCH( $::Str, 'new', 'KindaPerl6::Visitor::ShortCircuit' )
 )
, 'PROTOTYPE',  )
} } } }
; ::DISPATCH( ::DISPATCH( $::KindaPerl6::Visitor::ShortCircuit, 'HOW',  )
, 'add_method', ::DISPATCH( $::Str, 'new', 'visit' )
, ::DISPATCH( $::Code, 'new', { code => sub { my $pass_thunks; $pass_thunks = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$pass_thunks' } )  unless defined $pass_thunks; INIT { $pass_thunks = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$pass_thunks' } ) }
;
my  $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } ) ; 
;
my $node; $node = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node' } )  unless defined $node; INIT { $node = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node' } ) }
;
my $node_name; $node_name = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node_name' } )  unless defined $node_name; INIT { $node_name = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node_name' } ) }
;
$self = shift; my $CAPTURE; $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } )  unless defined $CAPTURE; INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
::DISPATCH_VAR($CAPTURE,"STORE",::CAPTURIZE(\@_));do {::MODIFIED($List__);
$List__ = ::DISPATCH( $CAPTURE, 'array',  )
};do {::MODIFIED($Hash__);
$Hash__ = ::DISPATCH( $CAPTURE, 'hash',  )
};{ my $_param_index = 0;  if ( exists $Hash__->{_value}{_hash}{'node'} )  { do {::MODIFIED($node);
$node = ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'node' )
 )
} }  elsif ( exists $List__->{_value}{_array}[ $_param_index ] )  { $node = $List__->{_value}{_array}[ $_param_index++ ];  }  if ( exists $Hash__->{_value}{_hash}{'node_name'} )  { do {::MODIFIED($node_name);
$node_name = ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'node_name' )
 )
} }  elsif ( exists $List__->{_value}{_array}[ $_param_index ] )  { $node_name = $List__->{_value}{_array}[ $_param_index++ ];  } } do {::MODIFIED($pass_thunks);
$pass_thunks = ::DISPATCH( $::Hash, 'new', { _hash => { ::DISPATCH( $::Str, 'new', 'infix:<&&>' )
->{_value} => ::DISPATCH( $::Int, 'new', 1 )
,::DISPATCH( $::Str, 'new', 'infix:<||>' )
->{_value} => ::DISPATCH( $::Int, 'new', 1 )
,::DISPATCH( $::Str, 'new', 'infix:<//>' )
->{_value} => ::DISPATCH( $::Int, 'new', 1 )
, } }
 )
}; do { if (::DISPATCH(::DISPATCH(::DISPATCH( $GLOBAL::Code_infix_58__60__38__38__62_, 'APPLY', ::DISPATCH( $::Code, 'new', { code => sub { my $CAPTURE; $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } )  unless defined $CAPTURE; INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
::DISPATCH_VAR($CAPTURE,"STORE",::CAPTURIZE(\@_));do {::MODIFIED($List__);
$List__ = ::DISPATCH( $CAPTURE, 'array',  )
};do {::MODIFIED($Hash__);
$Hash__ = ::DISPATCH( $CAPTURE, 'hash',  )
};{ my $_param_index = 0; } ::DISPATCH( $GLOBAL::Code_infix_58__60_eq_62_, 'APPLY', $node_name, ::DISPATCH( $::Str, 'new', 'Apply' )
 )
 }, signature => ::DISPATCH( $::Signature, "new", { invocant => $::Undef, array    => ::DISPATCH( $::Array, "new", { _array => [  ] } ), return   => $::Undef, } )
,  } )
, ::DISPATCH( $::Code, 'new', { code => sub { my $CAPTURE; $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } )  unless defined $CAPTURE; INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
::DISPATCH_VAR($CAPTURE,"STORE",::CAPTURIZE(\@_));do {::MODIFIED($List__);
$List__ = ::DISPATCH( $CAPTURE, 'array',  )
};do {::MODIFIED($Hash__);
$Hash__ = ::DISPATCH( $CAPTURE, 'hash',  )
};{ my $_param_index = 0; } ::DISPATCH( $pass_thunks, 'LOOKUP', ::DISPATCH( ::DISPATCH( $node, 'code',  )
, 'name',  )
 )
 }, signature => ::DISPATCH( $::Signature, "new", { invocant => $::Undef, array    => ::DISPATCH( $::Array, "new", { _array => [  ] } ), return   => $::Undef, } )
,  } )
 )
,"true"),"p5landish") ) { do { my $left; $left = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$left' } )  unless defined $left; INIT { $left = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$left' } ) }
;
my $right; $right = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$right' } )  unless defined $right; INIT { $right = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$right' } ) }
;
do {::MODIFIED($left);
$left = ::DISPATCH( ::DISPATCH( ::DISPATCH( $node, 'arguments',  )
, 'INDEX', ::DISPATCH( $::Int, 'new', 0 )
 )
, 'emit', $self )
}; do {::MODIFIED($right);
$right = ::DISPATCH( ::DISPATCH( ::DISPATCH( $node, 'arguments',  )
, 'INDEX', ::DISPATCH( $::Int, 'new', 1 )
 )
, 'emit', $self )
}; return(::DISPATCH( $::Apply, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'code' )
, value           => ::DISPATCH( $node, 'code',  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'arguments' )
, value           => ::DISPATCH( $::Array, 'new', { _array => [::DISPATCH( $Code_thunk, 'APPLY', $left )
, ::DISPATCH( $Code_thunk, 'APPLY', $right )
] }
 )
,  } ),  )
)
 } }  else { ::DISPATCH($::Bit, "new", 0) } }
; return($::Undef)
 }, signature => ::DISPATCH( $::Signature, "new", { invocant => $::Undef, array    => ::DISPATCH( $::Array, "new", { _array => [ ::DISPATCH( $::Signature::Item, 'new', { sigil  => '$', twigil => '', name   => 'node', value  => $::Undef, has_default    => ::DISPATCH( $::Bit, 'new', 0 )
, is_named_only  => ::DISPATCH( $::Bit, 'new', 0 )
, is_optional    => ::DISPATCH( $::Bit, 'new', 0 )
, is_slurpy      => ::DISPATCH( $::Bit, 'new', 0 )
, is_multidimensional  => ::DISPATCH( $::Bit, 'new', 0 )
, is_rw          => ::DISPATCH( $::Bit, 'new', 0 )
, is_copy        => ::DISPATCH( $::Bit, 'new', 0 )
,  } )
, ::DISPATCH( $::Signature::Item, 'new', { sigil  => '$', twigil => '', name   => 'node_name', value  => $::Undef, has_default    => ::DISPATCH( $::Bit, 'new', 0 )
, is_named_only  => ::DISPATCH( $::Bit, 'new', 0 )
, is_optional    => ::DISPATCH( $::Bit, 'new', 0 )
, is_slurpy      => ::DISPATCH( $::Bit, 'new', 0 )
, is_multidimensional  => ::DISPATCH( $::Bit, 'new', 0 )
, is_rw          => ::DISPATCH( $::Bit, 'new', 0 )
, is_copy        => ::DISPATCH( $::Bit, 'new', 0 )
,  } )
,  ] } ), return   => $::Undef, } )
,  } )
 )
; do {::MODIFIED($Code_new_pad);
$Code_new_pad = ::DISPATCH( $::Code, 'new', { code => sub { my $pad; $pad = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$pad' } )  unless defined $pad; INIT { $pad = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$pad' } ) }
;
my  $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } ) ; 
;
my $CAPTURE; $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } )  unless defined $CAPTURE; INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
::DISPATCH_VAR($CAPTURE,"STORE",::CAPTURIZE(\@_));do {::MODIFIED($List__);
$List__ = ::DISPATCH( $CAPTURE, 'array',  )
};do {::MODIFIED($Hash__);
$Hash__ = ::DISPATCH( $CAPTURE, 'hash',  )
};{ my $_param_index = 0; } ::DISPATCH( $COMPILER::Code_add_pad, 'APPLY',  )
; do {::MODIFIED($pad);
$pad = ::DISPATCH( $COMPILER::Code_current_pad, 'APPLY',  )
}; ::DISPATCH( $COMPILER::Code_drop_pad, 'APPLY',  )
; return($pad)
 }, signature => ::DISPATCH( $::Signature, "new", { invocant => $::Undef, array    => ::DISPATCH( $::Array, "new", { _array => [  ] } ), return   => $::Undef, } )
,  } )
}; do {::MODIFIED($Code_thunk);
$Code_thunk = ::DISPATCH( $::Code, 'new', { code => sub { my  $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } ) ; 
;
my $value; $value = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$value' } )  unless defined $value; INIT { $value = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$value' } ) }
;
my $CAPTURE; $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } )  unless defined $CAPTURE; INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
::DISPATCH_VAR($CAPTURE,"STORE",::CAPTURIZE(\@_));do {::MODIFIED($List__);
$List__ = ::DISPATCH( $CAPTURE, 'array',  )
};do {::MODIFIED($Hash__);
$Hash__ = ::DISPATCH( $CAPTURE, 'hash',  )
};{ my $_param_index = 0;  if ( exists $Hash__->{_value}{_hash}{'value'} )  { do {::MODIFIED($value);
$value = ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'value' )
 )
} }  elsif ( exists $List__->{_value}{_array}[ $_param_index ] )  { $value = $List__->{_value}{_array}[ $_param_index++ ];  } } ::DISPATCH( $::Sub, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'block' )
, value           => ::DISPATCH( $::Lit::Code, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'pad' )
, value           => ::DISPATCH( $Code_new_pad, 'APPLY',  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'body' )
, value           => ::DISPATCH( $::Array, 'new', { _array => [$value] }
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'sig' )
, value           => ::DISPATCH( $::Sig, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'invocant' )
, value           => $::Undef,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'positional' )
, value           => ::DISPATCH( $::Array, 'new', { _array => [] }
 )
,  } ),  )
,  } ),  )
,  } ),  )
 }, signature => ::DISPATCH( $::Signature, "new", { invocant => $::Undef, array    => ::DISPATCH( $::Array, "new", { _array => [ ::DISPATCH( $::Signature::Item, 'new', { sigil  => '$', twigil => '', name   => 'value', value  => $::Undef, has_default    => ::DISPATCH( $::Bit, 'new', 0 )
, is_named_only  => ::DISPATCH( $::Bit, 'new', 0 )
, is_optional    => ::DISPATCH( $::Bit, 'new', 0 )
, is_slurpy      => ::DISPATCH( $::Bit, 'new', 0 )
, is_multidimensional  => ::DISPATCH( $::Bit, 'new', 0 )
, is_rw          => ::DISPATCH( $::Bit, 'new', 0 )
, is_copy        => ::DISPATCH( $::Bit, 'new', 0 )
,  } )
,  ] } ), return   => $::Undef, } )
,  } )
} }
; 1 }
