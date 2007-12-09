{ package KindaPerl6::Visitor::ExtractRuleBlock; 
# Do not edit this file - Perl 5 generated by KindaPerl6
# AUTHORS, COPYRIGHT: Please look at the source file.
use v5;
use strict;
no strict "vars";
use constant KP6_DISABLE_INSECURE_CODE => 0;
use KindaPerl6::Runtime::Perl5::Runtime;
my $_MODIFIED; INIT { $_MODIFIED = {} }
INIT { $_ = ::DISPATCH($::Scalar, "new", { modified => $_MODIFIED, name => "$_" } ); }
do {my $count; $count = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$count' } )  unless defined $count; INIT { $count = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$count' } ) }
;
do { if (::DISPATCH(::DISPATCH(::DISPATCH(  ( $GLOBAL::Code_VAR_defined = $GLOBAL::Code_VAR_defined || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY', $::KindaPerl6::Visitor::ExtractRuleBlock )
,"true"),"p5landish") ) { }  else { do {my $count; $count = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$count' } )  unless defined $count; INIT { $count = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$count' } ) }
;
do {::MODIFIED($::KindaPerl6::Visitor::ExtractRuleBlock);
$::KindaPerl6::Visitor::ExtractRuleBlock = ::DISPATCH( ::DISPATCH( $::Class, 'new', ::DISPATCH( $::Str, 'new', 'KindaPerl6::Visitor::ExtractRuleBlock' )
 )
, 'PROTOTYPE',  )
}} } }
; ::DISPATCH( ::DISPATCH( $::KindaPerl6::Visitor::ExtractRuleBlock, 'HOW',  )
, 'add_method', ::DISPATCH( $::Str, 'new', 'visit' )
, ::DISPATCH( $::Code, 'new', { code => sub { 
# emit_declarations
my  $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } ) ; 
;
my $node; $node = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node' } )  unless defined $node; INIT { $node = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node' } ) }
;
my $node_name; $node_name = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node_name' } )  unless defined $node_name; INIT { $node_name = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node_name' } ) }
;
my $path; $path = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$path' } )  unless defined $path; INIT { $path = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$path' } ) }
;

# get $self
$self = shift; 
# emit_arguments
my $CAPTURE; $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } )  unless defined $CAPTURE; INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
my  $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } ) ; 
::DISPATCH_VAR($CAPTURE,"STORE",::CAPTURIZE(\@_));::DISPATCH_VAR( $List__, 'STORE', ::DISPATCH( $CAPTURE, 'array',  )
 )
;do {::MODIFIED($Hash__);
$Hash__ = ::DISPATCH( $CAPTURE, 'hash',  )
};{ my $_param_index = 0;  if ( ::DISPATCH( $GLOBAL::Code_exists,  'APPLY',  ::DISPATCH(  $Hash__, 'LOOKUP',  ::DISPATCH( $::Str, 'new', 'node' )  ) )->{_value}  )  { do {::MODIFIED($node);
$node = ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'node' )
 )
} }  elsif ( ::DISPATCH( $GLOBAL::Code_exists,  'APPLY',  ::DISPATCH(  $List__, 'INDEX',  ::DISPATCH( $::Int, 'new', $_param_index )  ) )->{_value}  )  { $node = ::DISPATCH(  $List__, 'INDEX',  ::DISPATCH( $::Int, 'new', $_param_index++ )  );  }  if ( ::DISPATCH( $GLOBAL::Code_exists,  'APPLY',  ::DISPATCH(  $Hash__, 'LOOKUP',  ::DISPATCH( $::Str, 'new', 'node_name' )  ) )->{_value}  )  { do {::MODIFIED($node_name);
$node_name = ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'node_name' )
 )
} }  elsif ( ::DISPATCH( $GLOBAL::Code_exists,  'APPLY',  ::DISPATCH(  $List__, 'INDEX',  ::DISPATCH( $::Int, 'new', $_param_index )  ) )->{_value}  )  { $node_name = ::DISPATCH(  $List__, 'INDEX',  ::DISPATCH( $::Int, 'new', $_param_index++ )  );  }  if ( ::DISPATCH( $GLOBAL::Code_exists,  'APPLY',  ::DISPATCH(  $Hash__, 'LOOKUP',  ::DISPATCH( $::Str, 'new', 'path' )  ) )->{_value}  )  { do {::MODIFIED($path);
$path = ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'path' )
 )
} }  elsif ( ::DISPATCH( $GLOBAL::Code_exists,  'APPLY',  ::DISPATCH(  $List__, 'INDEX',  ::DISPATCH( $::Int, 'new', $_param_index )  ) )->{_value}  )  { $path = ::DISPATCH(  $List__, 'INDEX',  ::DISPATCH( $::Int, 'new', $_param_index++ )  );  } } 
# emit_body
do { if (::DISPATCH(::DISPATCH(::DISPATCH(  ( $GLOBAL::Code_infix_58__60_eq_62_ = $GLOBAL::Code_infix_58__60_eq_62_ || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY', $node_name, ::DISPATCH( $::Str, 'new', 'Rule::Block' )
 )
,"true"),"p5landish") ) { do {my $comp_unit; $comp_unit = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$comp_unit' } )  unless defined $comp_unit; INIT { $comp_unit = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$comp_unit' } ) }
;
my $name; $name = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$name' } )  unless defined $name; INIT { $name = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$name' } ) }
;
use Data::Dumper; do {::MODIFIED($comp_unit);
$comp_unit = ::DISPATCH( $path, 'INDEX', ::DISPATCH(  ( $GLOBAL::Code_infix_58__60__45__62_ = $GLOBAL::Code_infix_58__60__45__62_ || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY', ::DISPATCH( $::Int, 'new', 0 )
, ::DISPATCH( $::Int, 'new', 1 )
 )
 )
}; do {::MODIFIED($count);
$count = ::DISPATCH(  ( $GLOBAL::Code_infix_58__60__43__62_ = $GLOBAL::Code_infix_58__60__43__62_ || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY', $count, ::DISPATCH( $::Int, 'new', 1 )
 )
}; do {::MODIFIED($name);
$name = ::DISPATCH(  ( $GLOBAL::Code_infix_58__60__126__62_ = $GLOBAL::Code_infix_58__60__126__62_ || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY', ::DISPATCH( $::Str, 'new', '__rule_block' )
, ::DISPATCH(  ( $GLOBAL::Code_infix_58__60__126__62_ = $GLOBAL::Code_infix_58__60__126__62_ || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY', $count, ::DISPATCH(  ( $GLOBAL::Code_infix_58__60__126__62_ = $GLOBAL::Code_infix_58__60__126__62_ || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY', ::DISPATCH( $::Str, 'new', '_' )
,  ( $COMPILER::source_md5 = $COMPILER::source_md5 || ::DISPATCH( $::Scalar, "new", )  ) 
 )
 )
 )
}; ::DISPATCH(  ( $GLOBAL::Code_push = $GLOBAL::Code_push || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY', ::DISPATCH(  ( $GLOBAL::Code_prefix_58__60__64__62_ = $GLOBAL::Code_prefix_58__60__64__62_ || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY', ::DISPATCH( ::DISPATCH( $comp_unit, 'body',  )
, 'body',  )
 )
, ::DISPATCH( $::Method, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'block' )
, value           => ::DISPATCH( $::Lit::Code, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'body' )
, value           => ::DISPATCH( ::DISPATCH( $node, 'closure',  )
, 'body',  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'sig' )
, value           => ::DISPATCH( $::Sig, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'invocant' )
, value           => ::DISPATCH( $::Str, 'new', '' )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'positional' )
, value           => ::DISPATCH( $::Array, 'new', { _array => [::DISPATCH( $::Lit::SigArgument, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'key' )
, value           => ::DISPATCH( $::Var, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'namespace' )
, value           => ::DISPATCH( $::Array, 'new', { _array => [] }
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'name' )
, value           => ::DISPATCH( $::Str, 'new', 'MATCH' )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'twigil' )
, value           => ::DISPATCH( $::Str, 'new', '' )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'sigil' )
, value           => ::DISPATCH( $::Str, 'new', '$' )
,  } ),  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'value' )
, value           => $::Undef,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'type' )
, value           => ::DISPATCH( $::Str, 'new', '' )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'is_multidimensional' )
, value           => ::DISPATCH( $::Val::Bit, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'bit' )
, value           => ::DISPATCH( $::Str, 'new', '0' )
,  } ),  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'is_slurpy' )
, value           => ::DISPATCH( $::Val::Bit, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'bit' )
, value           => ::DISPATCH( $::Str, 'new', '0' )
,  } ),  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'is_optional' )
, value           => ::DISPATCH( $::Val::Bit, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'bit' )
, value           => ::DISPATCH( $::Str, 'new', '0' )
,  } ),  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'is_named_only' )
, value           => ::DISPATCH( $::Val::Bit, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'bit' )
, value           => ::DISPATCH( $::Str, 'new', '0' )
,  } ),  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'is_copy' )
, value           => ::DISPATCH( $::Val::Bit, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'bit' )
, value           => ::DISPATCH( $::Str, 'new', '0' )
,  } ),  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'is_rw' )
, value           => ::DISPATCH( $::Val::Bit, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'bit' )
, value           => ::DISPATCH( $::Str, 'new', '0' )
,  } ),  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'has_default' )
, value           => ::DISPATCH( $::Val::Bit, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'bit' )
, value           => ::DISPATCH( $::Str, 'new', '0' )
,  } ),  )
,  } ),  )
] }
 )
,  } ),  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'pad' )
, value           => ::DISPATCH( $::Pad, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'lexicals' )
, value           => ::DISPATCH( $::Array, 'new', { _array => [::DISPATCH( $::Decl, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'decl' )
, value           => ::DISPATCH( $::Str, 'new', 'my' )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'var' )
, value           => ::DISPATCH( $::Var, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'namespace' )
, value           => ::DISPATCH( $::Array, 'new', { _array => [] }
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'name' )
, value           => ::DISPATCH( $::Str, 'new', '_' )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'twigil' )
, value           => ::DISPATCH( $::Str, 'new', '' )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'sigil' )
, value           => ::DISPATCH( $::Str, 'new', '@' )
,  } ),  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'type' )
, value           => ::DISPATCH( $::Str, 'new', '' )
,  } ),  )
, ::DISPATCH( $::Decl, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'decl' )
, value           => ::DISPATCH( $::Str, 'new', 'my' )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'var' )
, value           => ::DISPATCH( $::Var, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'namespace' )
, value           => ::DISPATCH( $::Array, 'new', { _array => [] }
 )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'name' )
, value           => ::DISPATCH( $::Str, 'new', 'MATCH' )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'twigil' )
, value           => ::DISPATCH( $::Str, 'new', '' )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'sigil' )
, value           => ::DISPATCH( $::Str, 'new', '$' )
,  } ),  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'type' )
, value           => ::DISPATCH( $::Str, 'new', '' )
,  } ),  )
] }
 )
,  } ),  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'state' )
, value           => ::DISPATCH( $::Hash, 'new', 
 )
,  } ),  )
,  } ), ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'name' )
, value           => $name,  } ),  )
 )
; ::DISPATCH(  ( $GLOBAL::Code_push = $GLOBAL::Code_push || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY', ::DISPATCH(  ( $GLOBAL::Code_prefix_58__60__64__62_ = $GLOBAL::Code_prefix_58__60__64__62_ || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY', ::DISPATCH( ::DISPATCH( $node, 'closure',  )
, 'body',  )
 )
, ::DISPATCH( $::Return, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'result' )
, value           => ::DISPATCH( $::Val::Buf, 'new', ::DISPATCH( $::NamedArgument, "new", { _argument_name_ => ::DISPATCH( $::Str, 'new', 'buf' )
, value           => ::DISPATCH( $::Str, 'new', 'sTrNgE V4l' )
,  } ),  )
,  } ),  )
 )
; ::DISPATCH( $node, 'closure', $name )
; return($node)
} }  else { ::DISPATCH($::Bit, "new", 0) } }
; ::DISPATCH( $::Int, 'new', 0 )
 }, signature => ::DISPATCH( $::Signature, "new", { invocant => $::Undef, array    => ::DISPATCH( $::List, "new", { _array => [ ::DISPATCH( $::Signature::Item, 'new', { sigil  => '$', twigil => '', name   => 'node', value  => $::Undef, has_default    => ::DISPATCH( $::Bit, 'new', 0 )
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
, ::DISPATCH( $::Signature::Item, 'new', { sigil  => '$', twigil => '', name   => 'path', value  => $::Undef, has_default    => ::DISPATCH( $::Bit, 'new', 0 )
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
; $count}
; 1 }
