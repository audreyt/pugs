use v6-alpha;

module HTTP::Headers::Util-0.2;

sub split_header_words (*@values) is export {
    my @return;
    
    for @values -> $value is copy {
        my @current;
        
        while ($value.chars) {
            if ($value ~~ s:P5/^\s*(=*[^\s=;,]+)//) {
                push @current, ~$0;  # 'token' or parameter 'attribute'
                
                # a quoted value
                if ($value ~~ s:P5/^\s*=\s*\"([^\"\\]*(?:\\.[^\"\\]*)*)\"//) {
                    my $val = ~$0;
                    $val ~~ s:P5:g/\\(.)/$0/;
                    push @current, $val;
                # some unquoted value
                } elsif ($value ~~ s:P5/^\s*=\s*([^;,\s]*)//) {
                    my $val = ~$0;
                    $val ~~ s:P5/\s+$//;
                    push @current, $val;
                # no value, a lone token
                } else {
                    push @current, undef;
                }
            } elsif ($value ~~ s:P5/^\s*,//) {
                push @return, [@current] if @current;
                @current = ();
            } elsif ($value ~~ s:P5/^\s*;// || $value ~~ s:P5/^\s+//) {
                # continue
            } else {
                die "This should not happen: '$value'";
            }
        }
        
        push @return, [@current] if @current;
    }
    
    return @return;
}

multi sub join_header_words(*@words) is export {
    join ', ', gather {
        for @words -> $cur {
            take join '; ', gather {
                for $cur -> $k, $v {
                    if $v.defined {
                        # XXX add / to character class in regex below
                        # currently results in parsefail
                        if $v ~~ m:P5/[\x00-\x20()<>@,;:\\\"\[\]?={}\x7F-\xFF]/ || !$v.chars {
                            my $esc = $v;
                            $esc ~~ s:P5:g/([\"\\])/\\$0/; # escape " and \
                            take qq($k="$esc");
                        }
                        else {
                            # token
                            take "$k=$v";
                        }
                    }
                    else {
                        take $k;
                    }
                }
            }
        }
    }
}

1;
