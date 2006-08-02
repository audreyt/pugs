﻿package Pugs::Grammar::Circumfix;
use strict;
use warnings;
#use base qw(Pugs::Grammar::Operator);
use Pugs::Grammar::Operator;
use base qw(Pugs::Grammar::BaseCategory);

use Pugs::Grammar::Infix;

sub add_rule {
    my $self = shift;
    my %opt = @_;
    $self->Pugs::Grammar::Operator::add_rule( %opt,
        fixity => 'circumfix', 
        assoc => 'non',
    );
    $self->Pugs::Grammar::Operator::add_rule( %opt,
        precedence => 'equal',
        other  => $opt{name},
        fixity => 'circumfix', 
        assoc => 'non',
        name => 'circumfix:<' . $opt{name} . ' ' . $opt{name2} . '>',
    );
    $self->SUPER::add_rule( 
        $opt{name}, 
        '{ return { op => "' . $opt{name} . '" ,} }' );
    $self->SUPER::add_rule( 
        $opt{name2}, 
        '{ return { op => "' . $opt{name2} . '" ,} }' );
    $self->SUPER::add_rule( 
        "circumfix:<" . $opt{name} . " " . $opt{name} . ">",
        '{ return { op => "circumfix:<' . $opt{name} . ' ' . $opt{name2} . '>" ,} }' );
}


BEGIN {
    #__PACKAGE__->add_rule( 
    #    name => '(',
    #    name2 => ')',
    #    assoc => 'non',
    #    precedence => 'tighter',
    #    other => '*',
    #);
    __PACKAGE__->recompile;
}

1;
