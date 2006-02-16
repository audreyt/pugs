# pX/Common/iterator_engine.pl - fglock
#
# status: the implementation uses fast ARRAY operations, 
# but this makes it difficult to write regex compositions
# such as alternations, so that it
# doesn't scale easily for complex regexes
#
# plan: rewrite using generators instead of ARRAY
# problem: this may be too slow, or difficult to maintain

use strict;
no strict "refs";

# internal composition functions

# TODO: <rule>+ can be compiled as <rule><rule>*

sub rule::greedy { 
  my $node = shift;
  return sub {
    my @tail = @_;
    my @matches;
    while (1) {
        my ($match, @new_tail) = $node->(@tail);
        return ( { '_greedy' => [ @matches ] }, @tail ) if ! $match;
        @tail = @new_tail;
        push @matches, $match;
    }
  }
}

sub rule::non_greedy { 
  my $node = shift;
  return sub {
    my ($match, @tail) = $node->(@_);
    return ( { '_non_greedy' => [ $match ] }, @tail ) if $match;
    return undef;
  }
}

sub rule::alternation {
  # XXX - this needs to be able to backtrack 
  # XXX   when it is inside a greedy match, for example
  my $alternates = shift;
  return sub {
    for ( @$alternates ) {
        my ($match, @tail) = $_->(@_);
        return ( { '_alternation' =>$match }, @tail) if $match;
    }
    return undef;
  }
}

sub rule::concat {
  my @concat = @_;
  return sub {
    my @matches;
    my @tail;
    my $match;
    
    ($match, @tail) = $concat[0]->(@_);
    return undef unless $match;  
    #print Dumper [ $match, @tail ];

    # XXX - _greedy / _non_greedy / _alternation / other
    while (1) {
        my $iterations = @{ $match->{'_greedy'} };
        warn "iterations to go: $iterations";
    
        @matches = ();
        push @matches, $match;
        
        my $match2;
        ($match2, @tail) = $concat[1]->(@tail);
        push @matches, $match2 if $match2;
    
        return ( { '_concat'=>[ @matches ] }, @tail) if $match2;
        
        return undef unless @{ $match->{'_greedy'} };
        
        my $last = pop @{ $match->{'_greedy'} };
        unshift @tail, $last;
    }
  }
}

# Prelude - precompiled rules, such as <word>, \x, etc.

*{'rule::.'} = sub { 
        return ( { '.'=>[ $_[0] ] }, @_[1..$#_] ) if @_;
        return;
    };
*{'rule::<slashed_char>'} = sub {
        return ( { '<slashed_char>' => [ $_[0], $_[1] ] }, @_[2..$#_] ) if $_[0] eq '\\';
        return;
    };
*{'rule::<word_char>'} = sub { 
        return ( { '<word_char>'=>[ $_[0] ] }, @_[1..$#_] ) if $_[0] =~ m/[a-zA-Z0-9\_]/;  
        return;
    };
*{'rule::<word>'} = rule::greedy( \&{'rule::<word_char>'} );
  
  # more definitions, just for testing
 
my %rules;
%rules = (
    'a' => sub { 
        return ( { 'a'=>[ $_[0] ] }, @_[1..$#_] ) if $_[0] eq 'a';
        return;
    },
    'ab' => sub { 
        return ( { 'ab'=>[ @_[0,1] ] }, @_[2..$#_] ) if $_[0] eq 'a' && $_[1] eq 'b';
        return;
    },
    'cd' => sub { 
        return ( { 'cd'=>[ @_[0,1] ] }, @_[2..$#_] ) if $_[0] eq 'c' && $_[1] eq 'd';
        return;
    },
    'abb' => sub { 
        my ($match, @tail) = $rules{'ab'}(@_);
        return unless $match;
        return ( { 'abb'=>[ $match, 'b' ] }, @tail[1..$#tail] ) if $tail[0] eq 'b'; 
        return;
    },
);
$rules{'ab|cd'} = rule::alternation( [ $rules{'ab'}, $rules{'cd'} ] );
$rules{'a*'} =    rule::greedy( $rules{'a'} );
$rules{'a*.'} =   rule::concat( $rules{'a*'}, \&{'rule::.'} );

package main;

use Data::Dumper;
$Data::Dumper::Indent = 1;
my @in = qw( a b b a b c c d );
print Dumper( &{'rule::.'}(@in) );
print Dumper( $rules{'abb'}(@in) );
print Dumper( $rules{'ab|cd'}( qw(a b c) ) );
print Dumper( $rules{'a*'}( qw(a a a b c) ) );
print Dumper( $rules{'a*.'}( qw(a a a a) ) );
print Dumper( $rules{'a*.'}( qw(b a a a a) ) );
print Dumper( &{'rule::<word>'}( qw(b a a ! !) ) );
