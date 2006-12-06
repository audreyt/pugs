# Do not edit this file - Generated by MiniPerl6
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;
package CompUnit; sub new { shift; bless { @_ }, "CompUnit" } sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub attributes { @_ == 1 ? ( $_[0]->{attributes} ) : ( $_[0]->{attributes} = $_[1] ) }; sub methods { @_ == 1 ? ( $_[0]->{methods} ) : ( $_[0]->{methods} = $_[1] ) }; sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) }; sub emit { my $self = $_[0]; my  $a = $_[0]->{body}; my  $s = ('.namespace [ "' . ($_[0]->{name} . ('" ] ' . (Main::newline() . ('.sub _ :main' . (Main::newline() . ('.end' . (Main::newline() . (Main::newline() . ('.sub "_class_vars_"' . Main::newline())))))))))); do { for my $item ( @{$a} ) { do { if ((Main::isa($item, 'Decl') && ($item->decl() ne 'has'))) { $s = ($s . $item->emit()) } else {  } } } }; $s = ($s . ('.end' . (Main::newline() . Main::newline()))); do { for my $item ( @{$a} ) { do { if ((Main::isa($item, 'Sub') || Main::isa($item, 'Method'))) { $s = ($s . $item->emit()) } else {  } } } }; do { for my $item ( @{$a} ) { do { if ((Main::isa($item, 'Decl') && ($item->decl() eq 'has'))) { my  $name = $item->var()->name();$s = ($s . ('.sub "' . ($name . ('" :method' . (Main::newline() . ('  .param pmc val      :optional' . (Main::newline() . ('  .param int has_val  :opt_flag' . (Main::newline() . ('  unless has_val goto ifelse' . (Main::newline() . ('  setattribute self, "' . ($name . ('", val' . (Main::newline() . ('  goto ifend' . (Main::newline() . ('ifelse:' . (Main::newline() . ('  val = getattribute self, "' . ($name . ('"' . (Main::newline() . ('ifend:' . (Main::newline() . ('  .return(val)' . (Main::newline() . ('.end' . (Main::newline() . Main::newline()))))))))))))))))))))))))))))) } else {  } } } }; $s = ($s . ('.sub _ :anon :load :init :outer("_class_vars_")' . (Main::newline() . ('  .local pmc self' . (Main::newline() . ('  newclass self, "' . ($_[0]->{name} . ('"' . Main::newline())))))))); do { for my $item ( @{$a} ) { do { if ((Main::isa($item, 'Decl') && ($item->decl() eq 'has'))) { $s = ($s . $item->emit()) } else {  } };do { if ((Main::isa($item, 'Decl') || (Main::isa($item, 'Sub') || Main::isa($item, 'Method')))) {  } else { $s = ($s . $item->emit()) } } } }; $s = ($s . ('.end' . (Main::newline() . Main::newline()))); return($s) }
;
package Val::Int; sub new { shift; bless { @_ }, "Val::Int" } sub int { @_ == 1 ? ( $_[0]->{int} ) : ( $_[0]->{int} = $_[1] ) }; sub emit { my $self = $_[0]; ('  $P0 = new .Integer' . (Main::newline() . ('  $P0 = ' . ($_[0]->{int} . Main::newline())))) }
;
package Val::Bit; sub new { shift; bless { @_ }, "Val::Bit" } sub bit { @_ == 1 ? ( $_[0]->{bit} ) : ( $_[0]->{bit} = $_[1] ) }; sub emit { my $self = $_[0]; ('  $P0 = new .Integer' . (Main::newline() . ('  $P0 = ' . ($_[0]->{bit} . Main::newline())))) }
;
package Val::Num; sub new { shift; bless { @_ }, "Val::Num" } sub num { @_ == 1 ? ( $_[0]->{num} ) : ( $_[0]->{num} = $_[1] ) }; sub emit { my $self = $_[0]; ('  $P0 = new .Float' . (Main::newline() . ('  $P0 = ' . ($_[0]->{num} . Main::newline())))) }
;
package Val::Buf; sub new { shift; bless { @_ }, "Val::Buf" } sub buf { @_ == 1 ? ( $_[0]->{buf} ) : ( $_[0]->{buf} = $_[1] ) }; sub emit { my $self = $_[0]; ('  $P0 = new .String' . (Main::newline() . ('  $P0 = \'' . ($_[0]->{buf} . ('\'' . Main::newline()))))) }
;
package Val::Undef; sub new { shift; bless { @_ }, "Val::Undef" } sub emit { my $self = $_[0]; ('  $P0 = new .Undef' . Main::newline()) }
;
package Val::Object; sub new { shift; bless { @_ }, "Val::Object" } sub class { @_ == 1 ? ( $_[0]->{class} ) : ( $_[0]->{class} = $_[1] ) }; sub fields { @_ == 1 ? ( $_[0]->{fields} ) : ( $_[0]->{fields} = $_[1] ) }; sub emit { my $self = $_[0]; die('Val::Object - not used yet') }
;
package Lit::Seq; sub new { shift; bless { @_ }, "Lit::Seq" } sub seq { @_ == 1 ? ( $_[0]->{seq} ) : ( $_[0]->{seq} = $_[1] ) }; sub emit { my $self = $_[0]; die('Lit::Seq - not used yet') }
;
package Lit::Array; sub new { shift; bless { @_ }, "Lit::Array" } sub array { @_ == 1 ? ( $_[0]->{array} ) : ( $_[0]->{array} = $_[1] ) }; sub emit { my $self = $_[0]; my  $a = $_[0]->{array}; my  $s = ('  save $P1' . (Main::newline() . ('  $P1 = new .ResizablePMCArray' . Main::newline()))); do { for my $item ( @{$a} ) { $s = ($s . $item->emit());$s = ($s . ('  push $P1, $P0' . Main->newline())) } }; my  $s = ($s . ('  $P0 = $P1' . (Main::newline() . ('  restore $P1' . Main::newline())))); return($s) }
;
package Lit::Hash; sub new { shift; bless { @_ }, "Lit::Hash" } sub hash { @_ == 1 ? ( $_[0]->{hash} ) : ( $_[0]->{hash} = $_[1] ) }; sub emit { my $self = $_[0]; my  $a = $_[0]->{hash}; my  $s = ('  save $P1' . (Main::newline() . ('  save $P2' . (Main::newline() . ('  $P1 = new .Hash' . Main::newline()))))); do { for my $item ( @{$a} ) { $s = ($s . $item->[0]->emit());$s = ($s . ('  $P2 = $P0' . Main->newline()));$s = ($s . $item->[1]->emit());$s = ($s . ('  set $P1[$P2], $P0' . Main->newline())) } }; my  $s = ($s . ('  $P0 = $P1' . (Main::newline() . ('  restore $P2' . (Main::newline() . ('  restore $P1' . Main::newline())))))); return($s) }
;
package Lit::Code; sub new { shift; bless { @_ }, "Lit::Code" } sub emit { my $self = $_[0]; die('Lit::Code - not used yet') }
;
package Lit::Object; sub new { shift; bless { @_ }, "Lit::Object" } sub class { @_ == 1 ? ( $_[0]->{class} ) : ( $_[0]->{class} = $_[1] ) }; sub fields { @_ == 1 ? ( $_[0]->{fields} ) : ( $_[0]->{fields} = $_[1] ) }; sub emit { my $self = $_[0]; my  $fields = $_[0]->{fields}; my  $str = ''; $str = ('  save $P1' . (Main::newline() . ('  save $S2' . (Main::newline() . ('  $P1 = new "' . ($_[0]->{class} . ('"' . Main::newline()))))))); do { for my $field ( @{$fields} ) { $str = ($str . ($field->[0]->emit() . ('  $S2 = $P0' . (Main::newline() . ($field->[1]->emit() . ('  setattribute $P1, $S2, $P0' . Main::newline())))))) } }; $str = ($str . ('  $P0 = $P1' . (Main::newline() . ('  restore $S2' . (Main::newline() . ('  restore $P1' . Main::newline())))))); $str }
;
package Index; sub new { shift; bless { @_ }, "Index" } sub obj { @_ == 1 ? ( $_[0]->{obj} ) : ( $_[0]->{obj} = $_[1] ) }; sub index { @_ == 1 ? ( $_[0]->{index} ) : ( $_[0]->{index} = $_[1] ) }; sub emit { my $self = $_[0]; my  $s = ('  save $P1' . Main::newline()); $s = ($s . $_[0]->{obj}->emit()); $s = ($s . ('  $P1 = $P0' . Main->newline())); $s = ($s . $_[0]->{index}->emit()); $s = ($s . ('  $P0 = $P1[$P0]' . Main->newline())); my  $s = ($s . ('  restore $P1' . Main::newline())); return($s) }
;
package Lookup; sub new { shift; bless { @_ }, "Lookup" } sub obj { @_ == 1 ? ( $_[0]->{obj} ) : ( $_[0]->{obj} = $_[1] ) }; sub index { @_ == 1 ? ( $_[0]->{index} ) : ( $_[0]->{index} = $_[1] ) }; sub emit { my $self = $_[0]; my  $s = ('  save $P1' . Main::newline()); $s = ($s . $_[0]->{obj}->emit()); $s = ($s . ('  $P1 = $P0' . Main->newline())); $s = ($s . $_[0]->{index}->emit()); $s = ($s . ('  $P0 = $P1[$P0]' . Main->newline())); my  $s = ($s . ('  restore $P1' . Main::newline())); return($s) }
;
package Var; sub new { shift; bless { @_ }, "Var" } sub sigil { @_ == 1 ? ( $_[0]->{sigil} ) : ( $_[0]->{sigil} = $_[1] ) }; sub twigil { @_ == 1 ? ( $_[0]->{twigil} ) : ( $_[0]->{twigil} = $_[1] ) }; sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub emit { my $self = $_[0]; (($_[0]->{twigil} eq '.') ? ('  $P0 = getattribute self, \'' . ($_[0]->{name} . ('\'' . Main::newline()))) : ('  $P0 = ' . ($self->full_name() . (' ' . Main::newline())))) }; sub name { my $self = $_[0]; $_[0]->{name} }; sub full_name { my $self = $_[0]; my  $table = { '$' => 'scalar_','@' => 'list_','%' => 'hash_','&' => 'code_', }; (($_[0]->{twigil} eq '.') ? $_[0]->{name} : (($_[0]->{name} eq '/') ? ($table->{$_[0]->{sigil}} . 'MATCH') : ($table->{$_[0]->{sigil}} . $_[0]->{name}))) }
;
package Bind; sub new { shift; bless { @_ }, "Bind" } sub parameters { @_ == 1 ? ( $_[0]->{parameters} ) : ( $_[0]->{parameters} = $_[1] ) }; sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) }; sub emit { my $self = $_[0]; do { if (Main::isa($_[0]->{parameters}, 'Lit::Array')) { my  $a = $_[0]->{parameters}->array();my  $b = $_[0]->{arguments}->array();my  $str = '';my  $i = 0;do { for my $var ( @{$a} ) { my  $bind = Bind->new( 'parameters' => $var,'arguments' => $b->[$i], );$str = ($str . $bind->emit());$i = ($i + 1) } };return(($str . $_[0]->{parameters}->emit())) } else {  } }; do { if (Main::isa($_[0]->{parameters}, 'Lit::Hash')) { my  $a = $_[0]->{parameters}->hash();my  $b = $_[0]->{arguments}->hash();my  $str = '';my  $i = 0;my  $arg;do { for my $var ( @{$a} ) { $arg = Val::Undef->new(  );do { for my $var2 ( @{$b} ) { do { if (($var2->[0]->buf() eq $var->[0]->buf())) { $arg = $var2->[1] } else {  } } } };my  $bind = Bind->new( 'parameters' => $var->[1],'arguments' => $arg, );$str = ($str . (' ' . ($bind->emit() . '')));$i = ($i + 1) } };return(($str . ($_[0]->{parameters}->emit() . ''))) } else {  } }; do { if (Main::isa($_[0]->{parameters}, 'Var')) { return(($_[0]->{arguments}->emit() . ('  ' . ($_[0]->{parameters}->full_name() . (' = $P0' . Main::newline()))))) } else {  } }; do { if (Main::isa($_[0]->{parameters}, 'Decl')) { return(($_[0]->{arguments}->emit() . ('  .local pmc ' . ($_[0]->{parameters}->var()->full_name() . (Main::newline() . ('  ' . ($_[0]->{parameters}->var()->full_name() . (' = $P0' . (Main::newline() . ('  .lex \'' . ($_[0]->{parameters}->var()->full_name() . ('\', $P0' . Main::newline())))))))))))) } else {  } }; do { if (Main::isa($_[0]->{parameters}, 'Lookup')) { my  $param = $_[0]->{parameters};my  $obj = $param->obj();my  $index = $param->index();return(($_[0]->{arguments}->emit() . ('  save $P2' . (Main::newline() . ('  $P2 = $P0' . (Main::newline() . ('  save $P1' . (Main::newline() . ($obj->emit() . ('  $P1 = $P0' . (Main::newline() . ($index->emit() . ('  $P1[$P0] = $P2' . (Main::newline() . ('  restore $P1' . (Main::newline() . ('  restore $P2' . Main::newline()))))))))))))))))) } else {  } }; do { if (Main::isa($_[0]->{parameters}, 'Index')) { my  $param = $_[0]->{parameters};my  $obj = $param->obj();my  $index = $param->index();return(($_[0]->{arguments}->emit() . ('  save $P2' . (Main::newline() . ('  $P2 = $P0' . (Main::newline() . ('  save $P1' . (Main::newline() . ($obj->emit() . ('  $P1 = $P0' . (Main::newline() . ($index->emit() . ('  $P1[$P0] = $P2' . (Main::newline() . ('  restore $P1' . (Main::newline() . ('  restore $P2' . Main::newline()))))))))))))))))) } else {  } }; die(('Not implemented binding: ' . ($_[0]->{parameters} . (Main::newline() . $_[0]->{parameters}->emit())))) }
;
package Proto; sub new { shift; bless { @_ }, "Proto" } sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub emit { my $self = $_[0]; ("" . $_[0]->{name}) }
;
package Call; sub new { shift; bless { @_ }, "Call" } sub invocant { @_ == 1 ? ( $_[0]->{invocant} ) : ( $_[0]->{invocant} = $_[1] ) }; sub hyper { @_ == 1 ? ( $_[0]->{hyper} ) : ( $_[0]->{hyper} = $_[1] ) }; sub method { @_ == 1 ? ( $_[0]->{method} ) : ( $_[0]->{method} = $_[1] ) }; sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) }; sub emit { my $self = $_[0]; do { if ((($_[0]->{method} eq 'perl') || (($_[0]->{method} eq 'yaml') || (($_[0]->{method} eq 'say') || (($_[0]->{method} eq 'join') || (($_[0]->{method} eq 'chars') || ($_[0]->{method} eq 'isa'))))))) { do { if ($_[0]->{hyper}) { return(('[ map { Main::' . ($_[0]->{method} . ('( $_, ' . (', ' . (Main::join([ map { $_->emit() } @{ $_[0]->{arguments} } ], '') . (')' . (' } @{ ' . ($_[0]->{invocant}->emit() . ' } ]'))))))))) } else { return(('Main::' . ($_[0]->{method} . ('(' . ($_[0]->{invocant}->emit() . (', ' . (Main::join([ map { $_->emit() } @{ $_[0]->{arguments} } ], '') . ')'))))))) } } } else {  } }; my  $meth = $_[0]->{method}; do { if (($meth eq 'postcircumfix:<( )>')) { $meth = '' } else {  } }; my  $call = ('->' . ($meth . ('(' . (Main::join([ map { $_->emit() } @{ $_[0]->{arguments} } ], '') . ')')))); do { if ($_[0]->{hyper}) { return(('[ map { $_' . ($call . (' } @{ ' . ($_[0]->{invocant}->emit() . ' } ]'))))) } else {  } }; my  $List_args = $_[0]->{arguments}; my  $str = ''; my  $ii = 10; do { for my $arg ( @{$List_args} ) { $str = ($str . ('  save $P' . ($ii . Main::newline())));$ii = ($ii + 1) } }; my  $i = 10; do { for my $arg ( @{$List_args} ) { $str = ($str . ($arg->emit() . ('  $P' . ($i . (' = $P0' . Main::newline())))));$i = ($i + 1) } }; $str = ($str . ('  $P0 = ' . ($_[0]->{invocant}->emit() . (Main::newline() . ('  $P0 = $P0.' . ($meth . '(')))))); $i = 0; my  $List_p; do { for my $arg ( @{$List_args} ) { $List_p->[$i] = ('$P' . ($i + 10));$i = ($i + 1) } }; $str = ($str . (Main::join($List_p, ', ') . (')' . Main::newline()))); do { for my $arg ( @{$List_args} ) { $ii = ($ii - 1);$str = ($str . ('  restore $P' . ($ii . Main::newline()))) } }; return($str) }
;
package Apply; sub new { shift; bless { @_ }, "Apply" } sub code { @_ == 1 ? ( $_[0]->{code} ) : ( $_[0]->{code} = $_[1] ) }; sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) }; my  $label = 100; sub emit { my $self = $_[0]; my  $code = $_[0]->{code}; do { if (($code eq 'say')) { return((Main::join([ map { $_->emit() } @{ $_[0]->{arguments} } ], ('  print $P0' . Main::newline())) . ('  print $P0' . (Main::newline() . ('  print "\n"' . Main::newline()))))) } else {  } }; do { if (($code eq 'print')) { return((Main::join([ map { $_->emit() } @{ $_[0]->{arguments} } ], ('  print $P0' . Main::newline())) . ('  print $P0' . Main::newline()))) } else {  } }; do { if (($code eq 'array')) { return(('TODO @{' . (Main::join([ map { $_->emit() } @{ $_[0]->{arguments} } ], ' ') . '}'))) } else {  } }; do { if (($code eq 'prefix:<~>')) { return(($_[0]->{arguments}->[0]->emit() . ('  $S0 = $P0' . (Main::newline() . ('  $P0 = $S0' . Main::newline()))))) } else {  } }; do { if (($code eq 'prefix:<!>')) { return(If->new( 'cond' => $_[0]->{arguments}->[0],'body' => [Val::Bit->new( 'bit' => 0, )],'otherwise' => [Val::Bit->new( 'bit' => 1, )], )->emit()) } else {  } }; do { if (($code eq 'prefix:<?>')) { return(If->new( 'cond' => $_[0]->{arguments}->[0],'body' => [Val::Bit->new( 'bit' => 1, )],'otherwise' => [Val::Bit->new( 'bit' => 0, )], )->emit()) } else {  } }; do { if (($code eq 'prefix:<$>')) { return(('TODO ${' . (Main::join([ map { $_->emit() } @{ $_[0]->{arguments} } ], ' ') . '}'))) } else {  } }; do { if (($code eq 'prefix:<@>')) { return(('TODO @{' . (Main::join([ map { $_->emit() } @{ $_[0]->{arguments} } ], ' ') . '}'))) } else {  } }; do { if (($code eq 'prefix:<%>')) { return(('TODO %{' . (Main::join([ map { $_->emit() } @{ $_[0]->{arguments} } ], ' ') . '}'))) } else {  } }; do { if (($code eq 'infix:<~>')) { return(($_[0]->{arguments}->[0]->emit() . ('  $S0 = $P0' . (Main::newline() . ('  save $S0' . (Main::newline() . ($_[0]->{arguments}->[1]->emit() . ('  $S1 = $P0' . (Main::newline() . ('  restore $S0' . (Main::newline() . ('  $S0 = concat $S0, $S1' . (Main::newline() . ('  $P0 = $S0' . Main::newline())))))))))))))) } else {  } }; do { if (($code eq 'infix:<+>')) { return(('  save $P1' . (Main::newline() . ($_[0]->{arguments}->[0]->emit() . ('  $P1 = $P0' . (Main::newline() . ($_[0]->{arguments}->[1]->emit() . ('  $P0 = $P1 + $P0' . (Main::newline() . ('  restore $P1' . Main::newline())))))))))) } else {  } }; do { if (($code eq 'infix:<->')) { return(('  save $P1' . (Main::newline() . ($_[0]->{arguments}->[0]->emit() . ('  $P1 = $P0' . (Main::newline() . ($_[0]->{arguments}->[1]->emit() . ('  $P0 = $P1 - $P0' . (Main::newline() . ('  restore $P1' . Main::newline())))))))))) } else {  } }; do { if (($code eq 'infix:<&&>')) { return(If->new( 'cond' => $_[0]->{arguments}->[0],'body' => [$_[0]->{arguments}->[1]],'otherwise' => [], )->emit()) } else {  } }; do { if (($code eq 'infix:<||>')) { return(If->new( 'cond' => $_[0]->{arguments}->[0],'body' => [],'otherwise' => [$_[0]->{arguments}->[1]], )->emit()) } else {  } }; do { if (($code eq 'infix:<eq>')) { $label = ($label + 1);my  $id = $label;return(($_[0]->{arguments}->[0]->emit() . ('  $S0 = $P0' . (Main::newline() . ('  save $S0' . (Main::newline() . ($_[0]->{arguments}->[1]->emit() . ('  $S1 = $P0' . (Main::newline() . ('  restore $S0' . (Main::newline() . ('  if $S0 == $S1 goto eq' . ($id . (Main::newline() . ('  $P0 = 0' . (Main::newline() . ('  goto eq_end' . ($id . (Main::newline() . ('eq' . ($id . (':' . (Main::newline() . ('  $P0 = 1' . (Main::newline() . ('eq_end' . ($id . (':' . Main::newline())))))))))))))))))))))))))))) } else {  } }; do { if (($code eq 'infix:<ne>')) { $label = ($label + 1);my  $id = $label;return(($_[0]->{arguments}->[0]->emit() . ('  $S0 = $P0' . (Main::newline() . ('  save $S0' . (Main::newline() . ($_[0]->{arguments}->[1]->emit() . ('  $S1 = $P0' . (Main::newline() . ('  restore $S0' . (Main::newline() . ('  if $S0 == $S1 goto eq' . ($id . (Main::newline() . ('  $P0 = 1' . (Main::newline() . ('  goto eq_end' . ($id . (Main::newline() . ('eq' . ($id . (':' . (Main::newline() . ('  $P0 = 0' . (Main::newline() . ('eq_end' . ($id . (':' . Main::newline())))))))))))))))))))))))))))) } else {  } }; do { if (($code eq 'infix:<==>')) { $label = ($label + 1);my  $id = $label;return(('  save $P1' . (Main::newline() . ($_[0]->{arguments}->[0]->emit() . ('  $P1 = $P0' . (Main::newline() . ($_[0]->{arguments}->[1]->emit() . ('  if $P0 == $P1 goto eq' . ($id . (Main::newline() . ('  $P0 = 0' . (Main::newline() . ('  goto eq_end' . ($id . (Main::newline() . ('eq' . ($id . (':' . (Main::newline() . ('  $P0 = 1' . (Main::newline() . ('eq_end' . ($id . (':' . (Main::newline() . ('  restore $P1' . Main::newline())))))))))))))))))))))))))) } else {  } }; do { if (($code eq 'infix:<!=>')) { $label = ($label + 1);my  $id = $label;return(('  save $P1' . (Main::newline() . ($_[0]->{arguments}->[0]->emit() . ('  $P1 = $P0' . (Main::newline() . ($_[0]->{arguments}->[1]->emit() . ('  if $P0 == $P1 goto eq' . ($id . (Main::newline() . ('  $P0 = 1' . (Main::newline() . ('  goto eq_end' . ($id . (Main::newline() . ('eq' . ($id . (':' . (Main::newline() . ('  $P0 = 0' . (Main::newline() . ('eq_end' . ($id . (':' . (Main::newline() . ('  restore $P1' . Main::newline())))))))))))))))))))))))))) } else {  } }; do { if (($code eq 'ternary:<?? !!>')) { return(If->new( 'cond' => $_[0]->{arguments}->[0],'body' => [$_[0]->{arguments}->[1]],'otherwise' => [$_[0]->{arguments}->[2]], )->emit()) } else {  } }; do { if (($code eq 'defined')) { return(($_[0]->{arguments}->[0]->emit() . ('  $I0 = defined $P0' . (Main::newline() . ('  $P0 = $I0' . Main::newline()))))) } else {  } }; do { if (($code eq 'substr')) { return(($_[0]->{arguments}->[0]->emit() . ('  $S0 = $P0' . (Main::newline() . ('  save $S0' . (Main::newline() . ($_[0]->{arguments}->[1]->emit() . ('  $I0 = $P0' . (Main::newline() . ('  save $I0' . (Main::newline() . ($_[0]->{arguments}->[2]->emit() . ('  $I1 = $P0' . (Main::newline() . ('  restore $I0' . (Main::newline() . ('  restore $S0' . (Main::newline() . ('  $S0 = substr $S0, $I0, $I1' . (Main::newline() . ('  $P0 = $S0' . Main::newline()))))))))))))))))))))) } else {  } }; my  $List_args = $_[0]->{arguments}; my  $str = ''; my  $ii = 10; do { for my $arg ( @{$List_args} ) { $str = ($str . ('  save $P' . ($ii . Main::newline())));$ii = ($ii + 1) } }; my  $i = 10; do { for my $arg ( @{$List_args} ) { $str = ($str . ($arg->emit() . ('  $P' . ($i . (' = $P0' . Main::newline())))));$i = ($i + 1) } }; $str = ($str . ('  $P0 = ' . ($_[0]->{code} . '('))); $i = 0; my  $List_p; do { for my $arg ( @{$List_args} ) { $List_p->[$i] = ('$P' . ($i + 10));$i = ($i + 1) } }; $str = ($str . (Main::join($List_p, ', ') . (')' . Main::newline()))); do { for my $arg ( @{$List_args} ) { $ii = ($ii - 1);$str = ($str . ('  restore $P' . ($ii . Main::newline()))) } }; return($str) }
;
package Return; sub new { shift; bless { @_ }, "Return" } sub result { @_ == 1 ? ( $_[0]->{result} ) : ( $_[0]->{result} = $_[1] ) }; sub emit { my $self = $_[0]; ($_[0]->{result}->emit() . ('  .return( $P0 )' . Main::newline())) }
;
package If; sub new { shift; bless { @_ }, "If" } sub cond { @_ == 1 ? ( $_[0]->{cond} ) : ( $_[0]->{cond} = $_[1] ) }; sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) }; sub otherwise { @_ == 1 ? ( $_[0]->{otherwise} ) : ( $_[0]->{otherwise} = $_[1] ) }; my  $label = 100; sub emit { my $self = $_[0]; $label = ($label + 1); my  $id = $label; return(($_[0]->{cond}->emit() . ('  unless $P0 goto ifelse' . ($id . (Main::newline() . (Main::join([ map { $_->emit() } @{ $_[0]->{body} } ], '') . ('  goto ifend' . ($id . (Main::newline() . ('ifelse' . ($id . (':' . (Main::newline() . (Main::join([ map { $_->emit() } @{ $_[0]->{otherwise} } ], '') . ('ifend' . ($id . (':' . Main::newline()))))))))))))))))) }
;
package For; sub new { shift; bless { @_ }, "For" } sub cond { @_ == 1 ? ( $_[0]->{cond} ) : ( $_[0]->{cond} = $_[1] ) }; sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) }; sub topic { @_ == 1 ? ( $_[0]->{topic} ) : ( $_[0]->{topic} = $_[1] ) }; my  $label = 100; sub emit { my $self = $_[0]; my  $cond = $_[0]->{cond}; $label = ($label + 1); my  $id = $label; do { if ((Main::isa($cond, 'Var') && ($cond->sigil() ne '@'))) { $cond = Lit::Array->new( 'array' => [$cond], ) } else {  } }; return(('' . ($cond->emit() . ('  save $P1' . (Main::newline() . ('  save $P2' . (Main::newline() . ('  $P1 = new .Iterator, $P0' . (Main::newline() . (' test_iter' . ($id . (':' . (Main::newline() . ('  unless $P1 goto iter_done' . ($id . (Main::newline() . ('  $P2 = shift $P1' . (Main::newline() . ('  store_lex \'' . ($_[0]->{topic}->full_name() . ('\', $P2' . (Main::newline() . (Main::join([ map { $_->emit() } @{ $_[0]->{body} } ], '') . ('  goto test_iter' . ($id . (Main::newline() . (' iter_done' . ($id . (':' . (Main::newline() . ('  restore $P2' . (Main::newline() . ('  restore $P1' . (Main::newline() . '')))))))))))))))))))))))))))))))))) }
;
package Decl; sub new { shift; bless { @_ }, "Decl" } sub decl { @_ == 1 ? ( $_[0]->{decl} ) : ( $_[0]->{decl} = $_[1] ) }; sub type { @_ == 1 ? ( $_[0]->{type} ) : ( $_[0]->{type} = $_[1] ) }; sub var { @_ == 1 ? ( $_[0]->{var} ) : ( $_[0]->{var} = $_[1] ) }; sub emit { my $self = $_[0]; my  $decl = $_[0]->{decl}; my  $name = $_[0]->{var}->name(); (($decl eq 'has') ? ('  addattribute self, "' . ($name . ('"' . Main::newline()))) : ('  .local pmc ' . ($_[0]->{var}->full_name() . (' ' . (Main::newline() . ('  .lex \'' . ($_[0]->{var}->full_name() . ('\', ' . ($_[0]->{var}->full_name() . (' ' . Main::newline())))))))))) }
;
package Sig; sub new { shift; bless { @_ }, "Sig" } sub invocant { @_ == 1 ? ( $_[0]->{invocant} ) : ( $_[0]->{invocant} = $_[1] ) }; sub positional { @_ == 1 ? ( $_[0]->{positional} ) : ( $_[0]->{positional} = $_[1] ) }; sub named { @_ == 1 ? ( $_[0]->{named} ) : ( $_[0]->{named} = $_[1] ) }; sub emit { my $self = $_[0]; ' print \'Signature - TODO\'; die \'Signature - TODO\'; ' }; sub invocant { my $self = $_[0]; $_[0]->{invocant} }; sub positional { my $self = $_[0]; $_[0]->{positional} }
;
package Method; sub new { shift; bless { @_ }, "Method" } sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub sig { @_ == 1 ? ( $_[0]->{sig} ) : ( $_[0]->{sig} = $_[1] ) }; sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) }; sub emit { my $self = $_[0]; my  $sig = $_[0]->{sig}; my  $invocant = $sig->invocant(); my  $pos = $sig->positional(); my  $str = ''; my  $i = 0; do { for my $field ( @{$pos} ) { $str = ($str . ('  $P0 = params[' . ($i . (']' . (Main::newline() . ('  .lex \'' . ($field->full_name() . ('\', $P0' . Main::newline()))))))));$i = ($i + 1) } }; return(('.sub "' . ($_[0]->{name} . ('" :method :outer("_class_vars_")' . (Main::newline() . ('  .param pmc params  :slurpy' . (Main::newline() . ('  .lex \'' . ($invocant->full_name() . ('\', self' . (Main::newline() . ($str . (Main::join([ map { $_->emit() } @{ $_[0]->{block} } ], '') . ('.end' . (Main::newline() . Main::newline()))))))))))))))) }
;
package Sub; sub new { shift; bless { @_ }, "Sub" } sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub sig { @_ == 1 ? ( $_[0]->{sig} ) : ( $_[0]->{sig} = $_[1] ) }; sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) }; sub emit { my $self = $_[0]; my  $sig = $_[0]->{sig}; my  $invocant = $sig->invocant(); my  $pos = $sig->positional(); my  $str = ''; my  $i = 0; do { for my $field ( @{$pos} ) { $str = ($str . ('  $P0 = params[' . ($i . (']' . (Main::newline() . ('  .lex \'' . ($field->full_name() . ('\', $P0' . Main::newline()))))))));$i = ($i + 1) } }; return(('.sub "' . ($_[0]->{name} . ('" :outer("_class_vars_")' . (Main::newline() . ('  .param pmc params  :slurpy' . (Main::newline() . ($str . (Main::join([ map { $_->emit() } @{ $_[0]->{block} } ], '') . ('.end' . (Main::newline() . Main::newline()))))))))))) }
;
package Do; sub new { shift; bless { @_ }, "Do" } sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) }; sub emit { my $self = $_[0]; Main::join([ map { $_->emit() } @{ $_[0]->{block} } ], '') }
;
package Use; sub new { shift; bless { @_ }, "Use" } sub mod { @_ == 1 ? ( $_[0]->{mod} ) : ( $_[0]->{mod} = $_[1] ) }; sub emit { my $self = $_[0]; ('  .include "' . ($_[0]->{mod} . ('"' . Main::newline()))) }
;
1;
