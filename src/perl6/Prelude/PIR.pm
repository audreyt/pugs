#module Prelude::PIR-0.0.1;
# XXX -- for some reason, compilation doesn't work if the above line is uncommented.

# our &prefix:<?> := &true doesn't work yet.
sub prefix:<?> ($var) returns Bool is primitive { true $var }

sub chomp (Str $str is rw) returns Str is primitive {
    if substr($str, -1, 1) eq "\n" {
        $str = substr $str, 0, chars($str) - 1;
        "\n";
    } else {
        undef;
    }
}

sub chop (Str $str is rw) returns Str is primitive {
    if chars($str) == 0 {
        undef;
    } else {
        my $removed = substr $str, -1, 1;
        $str = substr $str, 0, chars($str) - 1;
        $removed;
    }
}

sub sleep (Num $seconds) returns Num is primitive {
    my $time = time;
    Perl6::Internals::sleep $seconds;
    my $seconds_slept = time() - $time;
    $seconds_slept;
}

sub exit (Int ?$status = 0) is primitive {
    Perl6::Internals::exit $status;
}

sub Perl6::Internals::eval_parrot (Str $code) is primitive {
    my $sub = substr($code, 0, 1) eq "."
        ?? Perl6::Internals::compile_pir($code)
        :: Perl6::Internals::compile_pir(".sub pugs_eval_parrot\n$code\n.end\n");
    $sub();
}

sub pi () returns Num is primitive {
    3.14159265358979323846264338327950288419716939937510;
}

sub lcfirst (Str $str) returns Str is primitive {
    lc(substr $str, 0, 1) ~ substr $str, 1, chars($str) - 1;
}

sub ucfirst (Str $str) returns Str is primitive {
    uc(substr $str, 0, 1) ~ substr $str, 1, chars($str) - 1;
}

sub shift (@a) is primitive {
    my $top = +@a -1;
    return undef if $top < 0;
    my $e = @a[0];
    my $i = 0;
    while $i < $top {
	@a[$i++] = @a[$i];
    }
    pop(@a);
    return $e;
}

# splice entirely untested.
sub splice (@a, ?$offset=0, ?$length, *@list) is primitive {
    my $off = $offset;
    my $len = $length;
    my $size = +@a;

    $off += $size if $off < 0;
    if $off > $size {
	warn "splice() offset past end of array\n";
	$off = $size;
    }
    # $off is now ready

    $len = $size - $off if !defined($len);
    $len = $size + $len - $off if $len < 0;
    $len = 0 if $len < 0;
    # $len is now ready

    my $listlen = +@list;
    my $size_change = $listlen - $len;
    my @result;

    if $size_change > 0 {
	my $i = $size + $size_change -1;
	my $final = $off + $size_change;
	while $i >= $final {
	    @a[$i] = @a[$i-$size_change];
	    $i--;
	}
    } elsif $size_change < 0 {
	my $i = $off;
	my $final = $size + $size_change -1;
	while $i <= $final {
	    push(@result,$a[$i]);
	    @a[$i] = @a[$i-$size_change];
	    $i++;
	}
	# +@a = $size + $size_change;
	#   doesnt exist yet, so...
	my $n = 0;
	while $n-- > $size_change {
	    pop(@a);
	}
    }

    if $listlen > 0 {
	my $i = 0;
	while $i < $listlen {
	    @a[$off+$i] = @list[$i];
	}
    }

    # return want.List ?? *@result :: pop(@result)
    # return want.List ?? *@result :: +@result ?? @result[-1] :: undef;
    # return *@result;
    return @result;
}
