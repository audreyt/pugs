# Do not edit this file - Generated by MiniPerl6
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;
package KindaPerl6::Visitor::ExtractRuleBlock;
sub new { shift; bless { @_ }, "KindaPerl6::Visitor::ExtractRuleBlock" }
my  $count;
sub visit { my $self = shift; my $List__ = \@_; my $node; my $node_name; my $path; do {  $node = $List__->[0];  $node_name = $List__->[1];  $path = $List__->[2]; [$node, $node_name, $path] }; do { if (($node_name eq 'Rule::Block')) { use Data::Dumper;my  $comp_unit = $path->[(0 - 1)];$count = ($count + 1);my  $name = ('__rule_block' . ($count . ('_' . $COMPILER::source_md5)));push(@{$comp_unit->body()->body()}, Method->new( 'block' => $node->closure(),'name' => $name, ));$node->closure($name);return($node) } else {  } } }


;
1;
