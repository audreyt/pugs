# Do not edit this file - Generated by MiniPerl6
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;
package KindaPerl6::Visitor::EmitAstHTML;
sub new { shift; bless { @_ }, "KindaPerl6::Visitor::EmitAstHTML" }
sub visit { my $self = shift; my $List__ = \@_; my $node; my $node_name; do {  $node = $List__->[0];  $node_name = $List__->[1]; [$node, $node_name] }; my  $result = ''; $result = ($result . ('<span class="' . (Main::mangle_ident($node_name) . '">'))); $result = ($result . ('::' . ($node_name . '( '))); my  $data = $node->attribs(); do { for my $item ( keys(%{$data}) ) { $result = ($result . (' ' . ($item . ' => ')));do { if (Main::isa($data->{$item}, 'Array')) { $result = ($result . '[ ');do { for my $subitem ( @{$data->{$item}} ) { do { if (Main::isa($subitem, 'Array')) { $result = ($result . ' [ ... ], ') } else { $result = ($result . ($subitem->emit($self) . ', ')) } } } };$result = ($result . ' ], ') } else { do { if (Main::isa($data->{$item}, 'Hash')) { $result = ($result . '{ ');do { for my $subitem ( keys(%{$data->{$item}}) ) { $result = ($result . ($subitem . (' => ' . ($data->{$item}->{$subitem}->emit($self) . ', ')))) } };$result = ($result . ' }, ') } else { do { if (Main::isa($data->{$item}, 'Str')) { $result = ($result . ('\'' . ($data->{$item} . '\', '))) } else { $result = ($result . ($data->{$item}->emit($self) . ', ')) } } } } } } } }; $result = ($result . ') '); $result = ($result . '</span>') }


;
1;
