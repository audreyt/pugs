package Pugs::Emitter::Rule::Perl5::CharClass;

use strict;
use charnames ();
use Data::Dumper;

use vars qw( %char_class );
BEGIN {
    %char_class = map { $_ => 1 } qw(
        alpha alnum ascii blank
        cntrl digit graph lower
        print punct space upper
        word  xdigit
    );
}

sub vianame {
    my $c = shift;
    my $s = charnames::vianame($c);
    return $s if $s;
    $s = charnames::vianame("LINE FEED (LF)") 
        if $c eq "LINE FEED" || $c eq "LF";
    return $s if $s;
    $s = charnames::vianame("CARRIAGE RETURN (CR)") 
        if $c eq "CARRIAGE RETURN" || $c eq "CR";
    return $s if $s;
    $s = charnames::vianame("FORM FEED (FF)")  
        if $c eq "FORM FEED" || $c eq "FF";
    return $s if $s;
    $s = charnames::vianame("NEXT LINE (NEL)") 
        if $c eq "NEXT LINE" || $c eq "NEL";
    return $s if $s;
}

# input format:
# [
#    '+alpha'
#    '-[z]'
# ]

# TODO - set composition logic
# ( ( ( before +alpha ) | before +digit ) before not-alpha ) before not-digit )

sub emit {
    #print Dumper( $_[0] );
    #print Dumper( @{$_[0]} );
    my @c = map { "$_" } @{$_[0]};
    #print Dumper( @c );
    my $out = '';
    #my $last_cmd = '';
    for ( @c ) {
        my ( $op, $cmd ) = /(.)(.*)/;

        $cmd =~ s/ \\c\[ ([^];]+) \; ([^];]+) \] / 
                "\\x{" . sprintf("%02X", vianame($1)) . "}"
              . "\\x{" . sprintf("%02X", vianame($2)) . "}"
            /xgme;
        $cmd =~ s/ \\c\[ ([^]]+) \] / "\\x[" . sprintf("%02X", vianame($1)) . ']' /xgme;
        $cmd =~ s/ \\C\[ ([^]]+) \] / "\\X[" . sprintf("%02X", vianame($1)) . ']' /xgme;
        $cmd =~ s/ \\o\[ ([^]]+) \] / "\\x[" . sprintf("%02X", oct($1)) . ']' /xgme;
        $cmd =~ s/ \\O\[ ([^]]+) \] / "\\X[" . sprintf("%02X", oct($1)) . ']' /xgme;
        $cmd =~ s/\s//g;
        
        $cmd =~ s/\.\./-/g;  # ranges

        if ( $cmd =~ /^ \[ \\ x \[ (.*) \] \] /x ) {
            $cmd = "(?:\\x{$1})";
        }
        elsif ( $cmd =~ /^ \[ \\ X \[ (.*) \] \] /x ) {
            $cmd = "(?!\\x{$1})\\X";
            #$cmd = "[^\\x{$1}]";
        }

        elsif ( $cmd =~ /^ \s* \[ (.*) /x ) {
           $cmd = '[' . $1;
	    }
        elsif ( $cmd =~ /^ \s* (.*) /x ) {
           my $name = $1;
           $cmd = ( exists $char_class{$name} )
                ? "[[:$name:]]"
                : "\\p{$name}";
        }

        if ( $op eq '+' ) {
            $out .=
                ( $out eq '' )
                ? '(?=' . $cmd . ')'
                : '|(?=' . $cmd . ')';
        }
        elsif ( $op eq '-' ) {
            $out .= '(?!' . $cmd . ')';
        }
        else {
            #print Dumper( @c ), ' == ', $out, "\n";
            die "invalid character set op: $op";
        }
    }
    $out = "(?:$out)\\X";

    #print Dumper( \@c ), ' == ', $out, "\n";

    return $out;
}

1;

