# Do not edit this file - Generated by MiniPerl6
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;
package KindaPerl6::Visitor::EmitPerl6; sub new { shift; bless { @_ }, "KindaPerl6::Visitor::EmitPerl6" } sub visit { my $self = shift; my $List__ = \@_; my $node; do {  $node = $List__->[0]; [$node] }; $node->emit_perl6() }
;
package CompUnit; sub new { shift; bless { @_ }, "CompUnit" } sub unit_type { @_ == 1 ? ( $_[0]->{unit_type} ) : ( $_[0]->{unit_type} = $_[1] ) }; sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub attributes { @_ == 1 ? ( $_[0]->{attributes} ) : ( $_[0]->{attributes} = $_[1] ) }; sub methods { @_ == 1 ? ( $_[0]->{methods} ) : ( $_[0]->{methods} = $_[1] ) }; sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ('{ module ' . ($self->{name} . ('; ' . ($self->{body}->emit_perl6() . (' }' . Main::newline()))))) }
;
package Val::Int; sub new { shift; bless { @_ }, "Val::Int" } sub int { @_ == 1 ? ( $_[0]->{int} ) : ( $_[0]->{int} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; $self->{int} }
;
package Val::Bit; sub new { shift; bless { @_ }, "Val::Bit" } sub bit { @_ == 1 ? ( $_[0]->{bit} ) : ( $_[0]->{bit} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; $self->{bit} }
;
package Val::Num; sub new { shift; bless { @_ }, "Val::Num" } sub num { @_ == 1 ? ( $_[0]->{num} ) : ( $_[0]->{num} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; $self->{num} }
;
package Val::Buf; sub new { shift; bless { @_ }, "Val::Buf" } sub buf { @_ == 1 ? ( $_[0]->{buf} ) : ( $_[0]->{buf} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ('\'' . ($self->{buf} . '\'')) }
;
package Val::Undef; sub new { shift; bless { @_ }, "Val::Undef" } sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; '(undef)' }
;
package Val::Object; sub new { shift; bless { @_ }, "Val::Object" } sub class { @_ == 1 ? ( $_[0]->{class} ) : ( $_[0]->{class} = $_[1] ) }; sub fields { @_ == 1 ? ( $_[0]->{fields} ) : ( $_[0]->{fields} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ('::' . (Main::perl($self->{class}, ) . ('(' . (Main::perl($self->{fields}, ) . ')')))) }
;
package Native::Buf; sub new { shift; bless { @_ }, "Native::Buf" } sub buf { @_ == 1 ? ( $_[0]->{buf} ) : ( $_[0]->{buf} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ('\'' . ($self->{buf} . '\'')) }
;
package Lit::Seq; sub new { shift; bless { @_ }, "Lit::Seq" } sub seq { @_ == 1 ? ( $_[0]->{seq} ) : ( $_[0]->{seq} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ('(' . (Main::join([ map { $_->emit_perl6() } @{ $self->{seq} } ], ', ') . ')')) }
;
package Lit::Array; sub new { shift; bless { @_ }, "Lit::Array" } sub array { @_ == 1 ? ( $_[0]->{array} ) : ( $_[0]->{array} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ('[' . (Main::join([ map { $_->emit_perl6() } @{ $self->{array} } ], ', ') . ']')) }
;
package Lit::Hash; sub new { shift; bless { @_ }, "Lit::Hash" } sub hash { @_ == 1 ? ( $_[0]->{hash} ) : ( $_[0]->{hash} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; my  $fields = $self->{hash}; my  $str = ''; do { for my $field ( @{$fields} ) { $str = ($str . ($field->[0]->emit_perl6() . (' => ' . ($field->[1]->emit_perl6() . ',')))) } }; ('{ ' . ($str . ' }')) }
;
package Lit::Code; sub new { shift; bless { @_ }, "Lit::Code" } sub pad { @_ == 1 ? ( $_[0]->{pad} ) : ( $_[0]->{pad} = $_[1] ) }; sub state { @_ == 1 ? ( $_[0]->{state} ) : ( $_[0]->{state} = $_[1] ) }; sub sig { @_ == 1 ? ( $_[0]->{sig} ) : ( $_[0]->{sig} = $_[1] ) }; sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; my  $s; do { for my $name ( @{$self->{pad}->variable_names()} ) { my  $decl = Decl->new( 'decl' => 'my','type' => '','var' => Var->new( 'sigil' => '','twigil' => '','name' => $name, ), );$s = ($s . ($name->emit_perl6() . '; ')) } }; return(($s . Main::join([ map { $_->emit_perl6() } @{ $self->{body} } ], '; '))) }
;
package Lit::Object; sub new { shift; bless { @_ }, "Lit::Object" } sub class { @_ == 1 ? ( $_[0]->{class} ) : ( $_[0]->{class} = $_[1] ) }; sub fields { @_ == 1 ? ( $_[0]->{fields} ) : ( $_[0]->{fields} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; my  $fields = $self->{fields}; my  $str = ''; do { for my $field ( @{$fields} ) { $str = ($str . ($field->[0]->emit_perl6() . (' => ' . ($field->[1]->emit_perl6() . ',')))) } }; ($self->{class} . ('.new( ' . ($str . ' )'))) }
;
package Index; sub new { shift; bless { @_ }, "Index" } sub obj { @_ == 1 ? ( $_[0]->{obj} ) : ( $_[0]->{obj} = $_[1] ) }; sub index { @_ == 1 ? ( $_[0]->{index} ) : ( $_[0]->{index} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ($self->{obj}->emit_perl6() . ('[' . ($self->{index}->emit_perl6() . ']'))) }
;
package Lookup; sub new { shift; bless { @_ }, "Lookup" } sub obj { @_ == 1 ? ( $_[0]->{obj} ) : ( $_[0]->{obj} = $_[1] ) }; sub index { @_ == 1 ? ( $_[0]->{index} ) : ( $_[0]->{index} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ($self->{obj}->emit_perl6() . ('{' . ($self->{index}->emit_perl6() . '}'))) }
;
package Assign; sub new { shift; bless { @_ }, "Assign" } sub parameters { @_ == 1 ? ( $_[0]->{parameters} ) : ( $_[0]->{parameters} = $_[1] ) }; sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ($self->{parameters}->emit_perl6() . (' = ' . ($self->{arguments}->emit_perl6() . ''))) }
;
package Var; sub new { shift; bless { @_ }, "Var" } sub sigil { @_ == 1 ? ( $_[0]->{sigil} ) : ( $_[0]->{sigil} = $_[1] ) }; sub twigil { @_ == 1 ? ( $_[0]->{twigil} ) : ( $_[0]->{twigil} = $_[1] ) }; sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; my  $table = { '$' => '$','@' => '$List_','%' => '$Hash_','&' => '$Code_', }; do { if (($self->{twigil} eq '.')) { return(('$self->{' . ($self->{name} . '}'))) } else {  } }; do { if (($self->{name} eq '/')) { return(($table->{$self->{sigil}} . 'MATCH')) } else {  } }; return(Main::mangle_name($self->{sigil}, $self->{twigil}, $self->{name})) }
;
package Bind; sub new { shift; bless { @_ }, "Bind" } sub parameters { @_ == 1 ? ( $_[0]->{parameters} ) : ( $_[0]->{parameters} = $_[1] ) }; sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ($self->{parameters}->emit_perl6() . (' := ' . ($self->{arguments}->emit_perl6() . ''))) }
;
package Proto; sub new { shift; bless { @_ }, "Proto" } sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ("" . $self->{name}) }
;
package Call; sub new { shift; bless { @_ }, "Call" } sub invocant { @_ == 1 ? ( $_[0]->{invocant} ) : ( $_[0]->{invocant} = $_[1] ) }; sub hyper { @_ == 1 ? ( $_[0]->{hyper} ) : ( $_[0]->{hyper} = $_[1] ) }; sub method { @_ == 1 ? ( $_[0]->{method} ) : ( $_[0]->{method} = $_[1] ) }; sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; my  $invocant; do { if (Main::isa($self->{invocant}, 'Str')) { $invocant = ('$::Class_' . $self->{invocant}) } else { do { if (Main::isa($self->{invocant}, 'Val::Buf')) { $invocant = ('$::Class_' . $self->{invocant}->buf()) } else { $invocant = $self->{invocant}->emit_perl6() } } } }; do { if (($invocant eq 'self')) { $invocant = '$self' } else {  } }; do { if ((($self->{method} eq 'perl') || (($self->{method} eq 'yaml') || (($self->{method} eq 'say') || (($self->{method} eq 'join') || (($self->{method} eq 'chars') || ($self->{method} eq 'isa'))))))) { do { if ($self->{hyper}) { return(('[ map { Main::' . ($self->{method} . ('( $_, ' . (', ' . (Main::join([ map { $_->emit_perl6() } @{ $self->{arguments} } ], ', ') . (')' . (' } @{ ' . ($invocant . ' } ]'))))))))) } else { return(('Main::' . ($self->{method} . ('(' . ($invocant . (', ' . (Main::join([ map { $_->emit_perl6() } @{ $self->{arguments} } ], ', ') . ')'))))))) } } } else {  } }; my  $meth = $self->{method}; do { if (($meth eq 'postcircumfix:<( )>')) { $meth = '' } else {  } }; my  $call = Main::join([ map { $_->emit_perl6() } @{ $self->{arguments} } ], ', '); do { if ($self->{hyper}) { ('[ map { $_' . ('->' . ($meth . ('(' . ($call . (') } @{ ' . ($invocant . ' } ]'))))))) } else { ('(' . ($invocant . ('->FETCH->{_role_methods}{' . ($meth . ('}' . (' ? ' . ($invocant . ('->FETCH->{_role_methods}{' . ($meth . ('}{code}' . ('(' . ($invocant . ('->FETCH, ' . ($call . (')' . (' : ' . ($invocant . ('->FETCH->' . ($meth . ('(' . ($call . (')' . ')')))))))))))))))))))))) } } }
;
package Apply; sub new { shift; bless { @_ }, "Apply" } sub code { @_ == 1 ? ( $_[0]->{code} ) : ( $_[0]->{code} = $_[1] ) }; sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; return(('(' . ($self->{code}->emit_perl6() . (')(' . (Main::join([ map { $_->emit_perl6() } @{ $self->{arguments} } ], ', ') . ')'))))) }
;
package Return; sub new { shift; bless { @_ }, "Return" } sub result { @_ == 1 ? ( $_[0]->{result} ) : ( $_[0]->{result} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; return(('return(' . ($self->{result}->emit_perl6() . ')'))) }
;
package If; sub new { shift; bless { @_ }, "If" } sub cond { @_ == 1 ? ( $_[0]->{cond} ) : ( $_[0]->{cond} = $_[1] ) }; sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) }; sub otherwise { @_ == 1 ? ( $_[0]->{otherwise} ) : ( $_[0]->{otherwise} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ('do { if ( ${' . ($self->{cond}->emit_perl6() . ('->FETCH} ) { ' . ($self->{body}->emit_perl6() . (' } ' . (($self->{otherwise} ? (' else { ' . ($self->{otherwise}->emit_perl6() . ' }')) : '') . ' }')))))) }
;
package For; sub new { shift; bless { @_ }, "For" } sub cond { @_ == 1 ? ( $_[0]->{cond} ) : ( $_[0]->{cond} = $_[1] ) }; sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) }; sub topic { @_ == 1 ? ( $_[0]->{topic} ) : ( $_[0]->{topic} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; my  $cond = $self->{cond}; do { if ((Main::isa($cond, 'Var') && ($cond->sigil() eq '@'))) { $cond = Apply->new( 'code' => 'prefix:<@>','arguments' => [$cond], ) } else {  } }; ('do { for my ' . ($self->{topic}->emit_perl6() . (' ( ' . ($cond->emit_perl6() . (' ) { ' . ($self->{body}->emit_perl6() . ' } }')))))) }
;
package Decl; sub new { shift; bless { @_ }, "Decl" } sub decl { @_ == 1 ? ( $_[0]->{decl} ) : ( $_[0]->{decl} = $_[1] ) }; sub type { @_ == 1 ? ( $_[0]->{type} ) : ( $_[0]->{type} = $_[1] ) }; sub var { @_ == 1 ? ( $_[0]->{var} ) : ( $_[0]->{var} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; return(($self->{decl} . (' ' . ($self->{type} . (' ' . $self->{var}->emit_perl6()))))) }
;
package Sig; sub new { shift; bless { @_ }, "Sig" } sub invocant { @_ == 1 ? ( $_[0]->{invocant} ) : ( $_[0]->{invocant} = $_[1] ) }; sub positional { @_ == 1 ? ( $_[0]->{positional} ) : ( $_[0]->{positional} = $_[1] ) }; sub named { @_ == 1 ? ( $_[0]->{named} ) : ( $_[0]->{named} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ' print \'Signature - TODO\'; die \'Signature - TODO\'; ' }; sub invocant { my $self = shift; my $List__ = \@_; do { [] }; $self->{invocant} }; sub positional { my $self = shift; my $List__ = \@_; do { [] }; $self->{positional} }
;
package Method; sub new { shift; bless { @_ }, "Method" } sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; my  $sig = $self->{block}->sig(); my  $invocant = $sig->invocant(); my  $pos = $sig->positional(); my  $str = 'my $List__ = \@_; '; my  $pos = $sig->positional(); do { for my $field ( @{$pos} ) { $str = ($str . ('my ' . ($field->emit_perl6() . '; '))) } }; my  $bind = Bind->new( 'parameters' => Lit::Array->new( 'array' => $sig->positional(), ),'arguments' => Var->new( 'sigil' => '@','twigil' => '','name' => '_', ), ); $str = ($str . ($bind->emit_perl6() . '; ')); ('sub ' . ($self->{name} . (' { ' . ('my ' . ($invocant->emit_perl6() . (' = shift; ' . ($str . ($self->{block}->emit_perl6() . ' }')))))))) }
;
package Sub; sub new { shift; bless { @_ }, "Sub" } sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; my  $sig = $self->{block}->sig(); my  $pos = $sig->positional(); my  $str = 'my $List__ = \@_; '; my  $pos = $sig->positional(); do { if (@{$pos}) { do { for my $field ( @{$pos} ) { $str = ($str . ('my ' . ($field->emit_perl6() . '; '))) } };my  $bind = Bind->new( 'parameters' => Lit::Array->new( 'array' => $sig->positional(), ),'arguments' => Var->new( 'sigil' => '@','twigil' => '','name' => '_', ), );$str = ($str . ($bind->emit_perl6() . '; ')) } else {  } }; my  $code = ('sub { ' . ($str . ($self->{block}->emit_perl6() . ' }'))); do { if ($self->{name}) { return(('$Code_' . ($self->{name} . (' :=  ' . ($code . ''))))) } else {  } }; return($code) }
;
package Do; sub new { shift; bless { @_ }, "Do" } sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ('do { ' . ($self->{block}->emit_perl6() . ' }')) }
;
package BEGIN; sub new { shift; bless { @_ }, "BEGIN" } sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ('BEGIN { ' . ($self->{block}->emit_perl6() . ' }')) }
;
package Use; sub new { shift; bless { @_ }, "Use" } sub mod { @_ == 1 ? ( $_[0]->{mod} ) : ( $_[0]->{mod} = $_[1] ) }; sub emit_perl6 { my $self = shift; my $List__ = \@_; do { [] }; ('use ' . $self->{mod}) }
;
1;
