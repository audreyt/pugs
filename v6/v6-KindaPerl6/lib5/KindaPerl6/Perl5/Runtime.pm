
use v5;

use Data::Dumper;
use KindaPerl6::Perl5::Match;
use KindaPerl6::Perl5::MOP;
use KindaPerl6::Perl5::Type;
use KindaPerl6::Perl5::Pad;

package KindaPerl6::Grammar;
    sub space { 
        my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; 
        my $MATCH; 
        $MATCH = KindaPerl6::Perl5::Match->new( 
            'str' => $str,'from' => $pos,'to' => $pos, ); 
        $MATCH->bool(
            substr($str, $MATCH->to()) =~ m/^([[:space:]])/
            ? ( 1 + $MATCH->to( length( $1 ) + $MATCH->to() ))
            : 0
        );
        $MATCH;
    }
    sub digit { 
        my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; 
        my $MATCH; $MATCH = KindaPerl6::Perl5::Match->new( 
            'str' => $str,'from' => $pos,'to' => $pos, ); 
        $MATCH->bool(
            substr($str, $MATCH->to()) =~ m/^([[:digit:]])/
            ? ( 1 + $MATCH->to( length( $1 ) + $MATCH->to() ))
            : 0
        );
        $MATCH;
    }

    sub word { 
            my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; 
            my $MATCH; $MATCH = KindaPerl6::Perl5::Match->new( 
                'str' => $str,'from' => $pos,'to' => $pos, ); 
            $MATCH->bool(
                substr($str, $MATCH->to()) =~ m/^([[:word:]])/
                ? ( 1 + $MATCH->to( length( $1 ) + $MATCH->to() ))
                : 0
            );
            $MATCH;
    }
    sub backslash { 
            my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; 
            my $MATCH; $MATCH = KindaPerl6::Perl5::Match->new( 
                'str' => $str,'from' => $pos,'to' => $pos, ); 
            $MATCH->bool(
                substr($str, $MATCH->to(), 1) eq '\\'         # '
                ? ( 1 + $MATCH->to( 1 + $MATCH->to() ))
                : 0
            );
            $MATCH;
    }
        
    sub newline { 
        my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; 
        my $MATCH; $MATCH = KindaPerl6::Perl5::Match->new( 
            'str' => $str,'from' => $pos,'to' => $pos, ); 
        return $MATCH unless ord( substr($str, $MATCH->to()) ) == 10
            || ord( substr($str, $MATCH->to()) ) == 13;
        $MATCH->bool(
            substr($str, $MATCH->to()) =~ m/(?m)^(\n\r?|\r\n?)/
            ? ( 1 + $MATCH->to( length( $1 ) + $MATCH->to() ))
            : 0
        );
        $MATCH;
    }
    sub not_newline { 
        my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; 
        my $MATCH; $MATCH = KindaPerl6::Perl5::Match->new( 
            'str' => $str,'from' => $pos,'to' => $pos, 'bool' => 0 ); 
        return $MATCH if ord( substr($str, $MATCH->to()) ) == 10
            || ord( substr($str, $MATCH->to()) ) == 13;
        $MATCH->to( 1 + $MATCH->to );
        $MATCH->bool( 1 );
        $MATCH;
    }
    
package GLOBAL;

    #require Exporter;
    #@ISA = qw(Exporter);
    our @EXPORT = qw( 
        print 
        say
        undef
        undefine
         
        ternary_58__60__63__63__32__33__33__62_
        
        infix_58__60_eq_62_
        infix_58__60__61__61__62_
        infix_58__60__38__38__62_
        infix_58__60__124__124__62_
        infix_58__60__126__62_
        infix_58__60__43__62_
        
        prefix_58__60__64__62_        
    );
    
    # %*ENV
    $GLOBAL::Hash_ENV = bless \%ENV, 'Type_Perl5_Buf_Hash';
    
    ${"GLOBAL::Code_$_"} = \&{"GLOBAL::$_"} for @EXPORT;
    $GLOBAL::Code_import = \&{"GLOBAL::import"};
    sub import {
        my ($pkg) = caller;
        #print "IMPORT $pkg\n";
        ${"${pkg}::Code_$_"} = ${"GLOBAL::Code_$_"} for @EXPORT;
    }

    sub print { print join( '',  map { ${$_->FETCH} } @_ ) }
    sub say   { print join( '', (map { ${$_->FETCH} } @_), "\n" ) }

    $GLOBAL::undef = bless \( do{ my $v = undef } ), 'Type_Constant_Undef';
    sub undef    { $GLOBAL::undef }
    sub undefine { $_[0]->STORE( $GLOBAL::undef ) }

    # TODO - macro
    sub ternary_58__60__63__63__32__33__33__62_ { $_[0] ? $_[1] : $_[2] }
        #  ternary:<?? !!>
    
    # TODO - macro
    sub infix_58__60__38__38__62_   { $_[0] && $_[1] }
    # TODO - macro
    sub infix_58__60__124__124__62_ { $_[0] || $_[1] }

    sub infix_58__60_eq_62_         { bless \( do{ my $v = ${$_[0]->FETCH} eq ${$_[1]->FETCH}  } ), 'Type_Constant_Bit' }  # infix:<eq>
    sub infix_58__60__61__61__62_   { bless \( do{ my $v = ${$_[0]->FETCH} == ${$_[1]->FETCH}  } ), 'Type_Constant_Bit' }  # infix:<==>
    sub infix_58__60__126__62_      { bless \( do{ my $v = ${$_[0]->FETCH} . ${$_[1]->FETCH}  } ), 'Type_Constant_Buf' }  # infix:<~>
    sub infix_58__60__43__62_       { bless \( do{ my $v = ${$_[0]->FETCH} + ${$_[1]->FETCH}  } ), 'Type_Constant_Num' }  # infix:<+>

    # ???
    sub prefix_58__60__64__62_      { @{$_[0]} }        # prefix:<@>

package Main;
    
    sub chars { length( $_[0] ) }
    sub newline { "\n" }
    sub quote   { '"' }
    sub isa { 
        my $ref = ref($_[0]);
           (  $ref eq 'ARRAY' 
           && $_[1] eq 'Array'
           )
        || (  $ref eq 'HASH' 
           && $_[1] eq 'Hash'
           )
        || (  $ref eq '' 
           && $_[1] eq 'Str'
           )
        || $ref eq $_[1]
        || (  ref( $_[1] ) 
           && $ref eq ref( $_[1] ) 
           )
    }

    sub perl {
        local $Data::Dumper::Terse    = 1;
        my $can = UNIVERSAL::can($_[0] => 'perl');
        if ($can) {
            $can->($_[0]);
        }
        else {
            Data::Dumper::Dumper($_[0]);
        }
    }
    
    sub yaml {
        my $can = UNIVERSAL::can($_[0] => 'yaml');
        if ($can) {
            $can->($_[0]);
        }
        else {
            require YAML::Syck;
            YAML::Syck::Dump($_[0]);
        }
    }
      
    sub join {
        my $can = UNIVERSAL::can($_[0] => 'join');
        if ($can) {
            $can->(@_);
        }
        else {
            join($_[1], @{$_[0]} );
        }
    }
    
        my %table = (
            '$' => '',
            '@' => 'List_',
            '%' => 'Hash_',
            '&' => 'Code_',
        );
    sub mangle_name {
        my ($sigil, $twigil, $name) = @_;
        #print "mangle: ($sigil, $twigil, $name)\n";
        $name =~ s/ ([^a-zA-Z0-9_:] | (?<!:):(?!:)) / '_'.ord($1).'_' /xge;
        my @name = split( /::/, $name );
        $name[-1] = $table{$sigil} . $name[-1];
        #print "name: @name \n";
        if  (  $twigil eq '*'
            && @name   == 1
            )
        {
            unshift @name, 'GLOBAL';
        }
        return '$' . join( '::', @name );   # XXX - no twigil
    }
    
1;

__END__

=pod

=head1 NAME 

KindaPerl6::Perl5::Runtime

=head1 DESCRIPTION

Provides runtime routines for the KindaPerl6-in-Perl5 compiled code

=head1 AUTHORS

The Pugs Team E<lt>perl6-compiler@perl.orgE<gt>.

=head1 COPYRIGHT

Copyright 2007 by Flavio Soibelmann Glock and others.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
