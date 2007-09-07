# Do not edit this file - Generated by MiniPerl6
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;
package CompUnit;
sub new { shift; bless { @_ }, "CompUnit" }
sub unit_type { @_ == 1 ? ( $_[0]->{unit_type} ) : ( $_[0]->{unit_type} = $_[1] ) };
sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) };
sub traits { @_ == 1 ? ( $_[0]->{traits} ) : ( $_[0]->{traits} = $_[1] ) };
sub attributes { @_ == 1 ? ( $_[0]->{attributes} ) : ( $_[0]->{attributes} = $_[1] ) };
sub methods { @_ == 1 ? ( $_[0]->{methods} ) : ( $_[0]->{methods} = $_[1] ) };
sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'CompUnit', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'unit_type' => $self->{unit_type},'name' => $self->{name},'traits' => $self->{traits},'attributes' => $self->{attributes},'methods' => $self->{methods},'body' => $self->{body}, } }


;
package Val::Int;
sub new { shift; bless { @_ }, "Val::Int" }
sub int { @_ == 1 ? ( $_[0]->{int} ) : ( $_[0]->{int} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Val::Int', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'int' => $self->{int}, } }


;
package Val::Bit;
sub new { shift; bless { @_ }, "Val::Bit" }
sub bit { @_ == 1 ? ( $_[0]->{bit} ) : ( $_[0]->{bit} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Val::Bit', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'bit' => $self->{bit}, } }


;
package Val::Num;
sub new { shift; bless { @_ }, "Val::Num" }
sub num { @_ == 1 ? ( $_[0]->{num} ) : ( $_[0]->{num} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Val::Num', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'num' => $self->{num}, } }


;
package Val::Buf;
sub new { shift; bless { @_ }, "Val::Buf" }
sub buf { @_ == 1 ? ( $_[0]->{buf} ) : ( $_[0]->{buf} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Val::Buf', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'buf' => $self->{buf}, } }


;
package Val::Undef;
sub new { shift; bless { @_ }, "Val::Undef" }
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Val::Undef', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; {  } }


;
package Val::Object;
sub new { shift; bless { @_ }, "Val::Object" }
sub class { @_ == 1 ? ( $_[0]->{class} ) : ( $_[0]->{class} = $_[1] ) };
sub fields { @_ == 1 ? ( $_[0]->{fields} ) : ( $_[0]->{fields} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Val::Object', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'class' => $self->{class},'fields' => $self->{fields}, } }


;
package Lit::Seq;
sub new { shift; bless { @_ }, "Lit::Seq" }
sub seq { @_ == 1 ? ( $_[0]->{seq} ) : ( $_[0]->{seq} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Lit::Seq', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'seq' => $self->{seq}, } }


;
package Lit::Array;
sub new { shift; bless { @_ }, "Lit::Array" }
sub array { @_ == 1 ? ( $_[0]->{array} ) : ( $_[0]->{array} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Lit::Array', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'array' => $self->{array}, } }


;
package Lit::Hash;
sub new { shift; bless { @_ }, "Lit::Hash" }
sub hash { @_ == 1 ? ( $_[0]->{hash} ) : ( $_[0]->{hash} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Lit::Hash', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'hash' => $self->{hash}, } }


;
package Lit::Pair;
sub new { shift; bless { @_ }, "Lit::Pair" }
sub key { @_ == 1 ? ( $_[0]->{key} ) : ( $_[0]->{key} = $_[1] ) };
sub value { @_ == 1 ? ( $_[0]->{value} ) : ( $_[0]->{value} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Lit::Pair', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'key' => $self->{key},'value' => $self->{value}, } }


;
package Lit::NamedArgument;
sub new { shift; bless { @_ }, "Lit::NamedArgument" }
sub key { @_ == 1 ? ( $_[0]->{key} ) : ( $_[0]->{key} = $_[1] ) };
sub value { @_ == 1 ? ( $_[0]->{value} ) : ( $_[0]->{value} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Lit::NamedArgument', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'key' => $self->{key},'value' => $self->{value}, } }


;
package Lit::Code;
sub new { shift; bless { @_ }, "Lit::Code" }
sub pad { @_ == 1 ? ( $_[0]->{pad} ) : ( $_[0]->{pad} = $_[1] ) };
sub state { @_ == 1 ? ( $_[0]->{state} ) : ( $_[0]->{state} = $_[1] ) };
sub sig { @_ == 1 ? ( $_[0]->{sig} ) : ( $_[0]->{sig} = $_[1] ) };
sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Lit::Code', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'pad' => $self->{pad},'state' => $self->{state},'sig' => $self->{sig},'body' => $self->{body}, } }


;
package Lit::Object;
sub new { shift; bless { @_ }, "Lit::Object" }
sub class { @_ == 1 ? ( $_[0]->{class} ) : ( $_[0]->{class} = $_[1] ) };
sub fields { @_ == 1 ? ( $_[0]->{fields} ) : ( $_[0]->{fields} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Lit::Object', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'class' => $self->{class},'fields' => $self->{fields}, } }


;
package Index;
sub new { shift; bless { @_ }, "Index" }
sub obj { @_ == 1 ? ( $_[0]->{obj} ) : ( $_[0]->{obj} = $_[1] ) };
sub index { @_ == 1 ? ( $_[0]->{index} ) : ( $_[0]->{index} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Index', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'obj' => $self->{obj},'index' => $self->{index}, } }


;
package Lookup;
sub new { shift; bless { @_ }, "Lookup" }
sub obj { @_ == 1 ? ( $_[0]->{obj} ) : ( $_[0]->{obj} = $_[1] ) };
sub index { @_ == 1 ? ( $_[0]->{index} ) : ( $_[0]->{index} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Lookup', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'obj' => $self->{obj},'index' => $self->{index}, } }


;
package Var;
sub new { shift; bless { @_ }, "Var" }
sub sigil { @_ == 1 ? ( $_[0]->{sigil} ) : ( $_[0]->{sigil} = $_[1] ) };
sub twigil { @_ == 1 ? ( $_[0]->{twigil} ) : ( $_[0]->{twigil} = $_[1] ) };
sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Var', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'sigil' => $self->{sigil},'twigil' => $self->{twigil},'name' => $self->{name}, } }


;
package Bind;
sub new { shift; bless { @_ }, "Bind" }
sub parameters { @_ == 1 ? ( $_[0]->{parameters} ) : ( $_[0]->{parameters} = $_[1] ) };
sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Bind', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'parameters' => $self->{parameters},'arguments' => $self->{arguments}, } }


;
package Assign;
sub new { shift; bless { @_ }, "Assign" }
sub parameters { @_ == 1 ? ( $_[0]->{parameters} ) : ( $_[0]->{parameters} = $_[1] ) };
sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Assign', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'parameters' => $self->{parameters},'arguments' => $self->{arguments}, } }


;
package Proto;
sub new { shift; bless { @_ }, "Proto" }
sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Proto', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'name' => $self->{name}, } }


;
package Call;
sub new { shift; bless { @_ }, "Call" }
sub invocant { @_ == 1 ? ( $_[0]->{invocant} ) : ( $_[0]->{invocant} = $_[1] ) };
sub hyper { @_ == 1 ? ( $_[0]->{hyper} ) : ( $_[0]->{hyper} = $_[1] ) };
sub method { @_ == 1 ? ( $_[0]->{method} ) : ( $_[0]->{method} = $_[1] ) };
sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Call', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'invocant' => $self->{invocant},'hyper' => $self->{hyper},'method' => $self->{method},'arguments' => $self->{arguments}, } }


;
package Apply;
sub new { shift; bless { @_ }, "Apply" }
sub code { @_ == 1 ? ( $_[0]->{code} ) : ( $_[0]->{code} = $_[1] ) };
sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Apply', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'code' => $self->{code},'arguments' => $self->{arguments}, } }


;
package Return;
sub new { shift; bless { @_ }, "Return" }
sub result { @_ == 1 ? ( $_[0]->{result} ) : ( $_[0]->{result} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Return', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'result' => $self->{result}, } }


;
package If;
sub new { shift; bless { @_ }, "If" }
sub cond { @_ == 1 ? ( $_[0]->{cond} ) : ( $_[0]->{cond} = $_[1] ) };
sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) };
sub otherwise { @_ == 1 ? ( $_[0]->{otherwise} ) : ( $_[0]->{otherwise} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'If', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'cond' => $self->{cond},'body' => $self->{body},'otherwise' => $self->{otherwise}, } }


;
package For;
sub new { shift; bless { @_ }, "For" }
sub cond { @_ == 1 ? ( $_[0]->{cond} ) : ( $_[0]->{cond} = $_[1] ) };
sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) };
sub topic { @_ == 1 ? ( $_[0]->{topic} ) : ( $_[0]->{topic} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'For', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'cond' => $self->{cond},'body' => $self->{body},'topic' => $self->{topic}, } }


;
package Decl;
sub new { shift; bless { @_ }, "Decl" }
sub decl { @_ == 1 ? ( $_[0]->{decl} ) : ( $_[0]->{decl} = $_[1] ) };
sub type { @_ == 1 ? ( $_[0]->{type} ) : ( $_[0]->{type} = $_[1] ) };
sub var { @_ == 1 ? ( $_[0]->{var} ) : ( $_[0]->{var} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Decl', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'decl' => $self->{decl},'type' => $self->{type},'var' => $self->{var}, } }


;
package Sig;
sub new { shift; bless { @_ }, "Sig" }
sub invocant { @_ == 1 ? ( $_[0]->{invocant} ) : ( $_[0]->{invocant} = $_[1] ) };
sub positional { @_ == 1 ? ( $_[0]->{positional} ) : ( $_[0]->{positional} = $_[1] ) };
sub named { @_ == 1 ? ( $_[0]->{named} ) : ( $_[0]->{named} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Sig', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'invocant' => $self->{invocant},'positional' => $self->{positional},'named' => $self->{named}, } }


;
package Capture;
sub new { shift; bless { @_ }, "Capture" }
sub invocant { @_ == 1 ? ( $_[0]->{invocant} ) : ( $_[0]->{invocant} = $_[1] ) };
sub array { @_ == 1 ? ( $_[0]->{array} ) : ( $_[0]->{array} = $_[1] ) };
sub hash { @_ == 1 ? ( $_[0]->{hash} ) : ( $_[0]->{hash} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Capture', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'invocant' => $self->{invocant},'array' => $self->{array},'hash' => $self->{hash}, } }


;
package Subset;
sub new { shift; bless { @_ }, "Subset" }
sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) };
sub base_class { @_ == 1 ? ( $_[0]->{base_class} ) : ( $_[0]->{base_class} = $_[1] ) };
sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Subset', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'name' => $self->{name},'base_class' => $self->{base_class},'block' => $self->{block}, } }


;
package Method;
sub new { shift; bless { @_ }, "Method" }
sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) };
sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Method', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'name' => $self->{name},'block' => $self->{block}, } }


;
package Sub;
sub new { shift; bless { @_ }, "Sub" }
sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) };
sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Sub', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'name' => $self->{name},'block' => $self->{block}, } }


;
package Token;
sub new { shift; bless { @_ }, "Token" }
sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) };
sub regex { @_ == 1 ? ( $_[0]->{regex} ) : ( $_[0]->{regex} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Token', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'name' => $self->{name},'regex' => $self->{regex}, } }


;
package Do;
sub new { shift; bless { @_ }, "Do" }
sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Do', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'block' => $self->{block}, } }


;
package BEGIN;
sub new { shift; bless { @_ }, "BEGIN" }
sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'BEGIN', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'block' => $self->{block}, } }


;
package Use;
sub new { shift; bless { @_ }, "Use" }
sub mod { @_ == 1 ? ( $_[0]->{mod} ) : ( $_[0]->{mod} = $_[1] ) };
sub perl5 { @_ == 1 ? ( $_[0]->{perl5} ) : ( $_[0]->{perl5} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Use', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'mod' => $self->{mod},'perl5' => $self->{perl5}, } }


;
package Rule;
sub new { shift; bless { @_ }, "Rule" }
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; {  } }


;
package Rule::Quantifier;
sub new { shift; bless { @_ }, "Rule::Quantifier" }
sub term { @_ == 1 ? ( $_[0]->{term} ) : ( $_[0]->{term} = $_[1] ) };
sub quant { @_ == 1 ? ( $_[0]->{quant} ) : ( $_[0]->{quant} = $_[1] ) };
sub greedy { @_ == 1 ? ( $_[0]->{greedy} ) : ( $_[0]->{greedy} = $_[1] ) };
sub ws1 { @_ == 1 ? ( $_[0]->{ws1} ) : ( $_[0]->{ws1} = $_[1] ) };
sub ws2 { @_ == 1 ? ( $_[0]->{ws2} ) : ( $_[0]->{ws2} = $_[1] ) };
sub ws3 { @_ == 1 ? ( $_[0]->{ws3} ) : ( $_[0]->{ws3} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::Quantifier', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'term' => $self->{term},'quant' => $self->{quant},'greedy' => $self->{greedy},'ws1' => $self->{ws1},'ws2' => $self->{ws2},'ws3' => $self->{ws3}, } }


;
package Rule::Or;
sub new { shift; bless { @_ }, "Rule::Or" }
sub or { @_ == 1 ? ( $_[0]->{or} ) : ( $_[0]->{or} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::Or', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'or' => $self->{or}, } }


;
package Rule::Concat;
sub new { shift; bless { @_ }, "Rule::Concat" }
sub concat { @_ == 1 ? ( $_[0]->{concat} ) : ( $_[0]->{concat} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::Concat', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'concat' => $self->{concat}, } }


;
package Rule::Subrule;
sub new { shift; bless { @_ }, "Rule::Subrule" }
sub metasyntax { @_ == 1 ? ( $_[0]->{metasyntax} ) : ( $_[0]->{metasyntax} = $_[1] ) };
sub ident { @_ == 1 ? ( $_[0]->{ident} ) : ( $_[0]->{ident} = $_[1] ) };
sub capture_to_array { @_ == 1 ? ( $_[0]->{capture_to_array} ) : ( $_[0]->{capture_to_array} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::Subrule', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'metasyntax' => $self->{metasyntax},'ident' => $self->{ident},'capture_to_array' => $self->{capture_to_array}, } }


;
package Rule::SubruleNoCapture;
sub new { shift; bless { @_ }, "Rule::SubruleNoCapture" }
sub metasyntax { @_ == 1 ? ( $_[0]->{metasyntax} ) : ( $_[0]->{metasyntax} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::SubruleNoCapture', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'metasyntax' => $self->{metasyntax}, } }


;
package Rule::Var;
sub new { shift; bless { @_ }, "Rule::Var" }
sub sigil { @_ == 1 ? ( $_[0]->{sigil} ) : ( $_[0]->{sigil} = $_[1] ) };
sub twigil { @_ == 1 ? ( $_[0]->{twigil} ) : ( $_[0]->{twigil} = $_[1] ) };
sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::Var', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'sigil' => $self->{sigil},'twigil' => $self->{twigil},'name' => $self->{name}, } }


;
package Rule::Constant;
sub new { shift; bless { @_ }, "Rule::Constant" }
sub constant { @_ == 1 ? ( $_[0]->{constant} ) : ( $_[0]->{constant} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::Constant', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'constant' => $self->{constant}, } }


;
package Rule::Dot;
sub new { shift; bless { @_ }, "Rule::Dot" }
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::Dot', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; {  } }


;
package Rule::SpecialChar;
sub new { shift; bless { @_ }, "Rule::SpecialChar" }
sub char { @_ == 1 ? ( $_[0]->{char} ) : ( $_[0]->{char} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::SpecialChar', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'char' => $self->{char}, } }


;
package Rule::Block;
sub new { shift; bless { @_ }, "Rule::Block" }
sub closure { @_ == 1 ? ( $_[0]->{closure} ) : ( $_[0]->{closure} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::Block', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'closure' => $self->{closure}, } }


;
package Rule::InterpolateVar;
sub new { shift; bless { @_ }, "Rule::InterpolateVar" }
sub var { @_ == 1 ? ( $_[0]->{var} ) : ( $_[0]->{var} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::InterpolateVar', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'var' => $self->{var}, } }


;
package Rule::NamedCapture;
sub new { shift; bless { @_ }, "Rule::NamedCapture" }
sub rule { @_ == 1 ? ( $_[0]->{rule} ) : ( $_[0]->{rule} = $_[1] ) };
sub ident { @_ == 1 ? ( $_[0]->{ident} ) : ( $_[0]->{ident} = $_[1] ) };
sub capture_to_array { @_ == 1 ? ( $_[0]->{capture_to_array} ) : ( $_[0]->{capture_to_array} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::NamedCapture', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'rule' => $self->{rule},'ident' => $self->{ident},'capture_to_array' => $self->{capture_to_array}, } }


;
package Rule::Before;
sub new { shift; bless { @_ }, "Rule::Before" }
sub rule { @_ == 1 ? ( $_[0]->{rule} ) : ( $_[0]->{rule} = $_[1] ) };
sub assertion_modifier { @_ == 1 ? ( $_[0]->{assertion_modifier} ) : ( $_[0]->{assertion_modifier} = $_[1] ) };
sub capture_to_array { @_ == 1 ? ( $_[0]->{capture_to_array} ) : ( $_[0]->{capture_to_array} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::Before', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'rule' => $self->{rule},'capture_to_array' => $self->{capture_to_array},'assertion_modifier' => $self->{assertion_modifier}, } }


;
package Rule::After;
sub new { shift; bless { @_ }, "Rule::After" }
sub rule { @_ == 1 ? ( $_[0]->{rule} ) : ( $_[0]->{rule} = $_[1] ) };
sub assertion_modifier { @_ == 1 ? ( $_[0]->{assertion_modifier} ) : ( $_[0]->{assertion_modifier} = $_[1] ) };
sub capture_to_array { @_ == 1 ? ( $_[0]->{capture_to_array} ) : ( $_[0]->{capture_to_array} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::After', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'rule' => $self->{rule},'capture_to_array' => $self->{capture_to_array},'assertion_modifier' => $self->{assertion_modifier}, } }


;
package Rule::NegateCharClass;
sub new { shift; bless { @_ }, "Rule::NegateCharClass" }
sub chars { @_ == 1 ? ( $_[0]->{chars} ) : ( $_[0]->{chars} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::NegateCharClass', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'chars' => $self->{chars}, } }


;
package Rule::CharClass;
sub new { shift; bless { @_ }, "Rule::CharClass" }
sub chars { @_ == 1 ? ( $_[0]->{chars} ) : ( $_[0]->{chars} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::CharClass', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'chars' => $self->{chars}, } }


;
package Rule::Capture;
sub new { shift; bless { @_ }, "Rule::Capture" }
sub rule { @_ == 1 ? ( $_[0]->{rule} ) : ( $_[0]->{rule} = $_[1] ) };
sub position { @_ == 1 ? ( $_[0]->{position} ) : ( $_[0]->{position} = $_[1] ) };
sub capture_to_array { @_ == 1 ? ( $_[0]->{capture_to_array} ) : ( $_[0]->{capture_to_array} = $_[1] ) };
sub emit { my $self = shift; my $List__ = \@_; my $visitor; my $path; do {  $visitor = $List__->[0];  $path = $List__->[1]; [$visitor, $path] }; KindaPerl6::Traverse::visit($visitor, $self, 'Rule::Capture', $path) };
sub attribs { my $self = shift; my $List__ = \@_; do { [] }; { 'rule' => $self->{rule},'position' => $self->{position},'capture_to_array' => $self->{capture_to_array}, } }


;
1;
