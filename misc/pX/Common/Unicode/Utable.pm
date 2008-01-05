class Utable;

# An efficient data structure for unicode property data
# The basic data structure is an array of Range objects
# e.g. <alpha> would use ( 0x41..0x5a ; 0x61..0x7a ; ... )
# lookup is O(log n), where n is the number of ranges, not total codepoints
# insertion is O(n) in general, but appending a non-contiguous range is O(1)
has Range @@.table;
# Values to attach to ranges
has Any @.val;

multi submethod BUILD(Range @@r, Any :@val) {
    @@.table = @@r;
    @.val = @val;
    $.preen;
}
multi submethod BUILD(Str $str) {
    # parse the output of $.print
    for $str.split(';') {
        if mm/^ ( <xdigit>+ ) [ ':' ( \S+ ) ]? $/ {
            $.add(hex $0, :val($1), :!preen);
        } elsif mm/^ ( <xdigit>+ ) '..' ( <xdigit>+ ) [ ':' ( \S+ ) ]? $/ {
            $.add(hex($0) .. hex($1), :val($2), :!preen);
        } else {
            die "Utable::BUILD: can't parse '$_'";
        }
    }
    $.preen;
}

#XXX how do you stringify an object?
method tostr(--> Str) {
    # not needed if @@.table.perl DTRT...
    my Str $s;
    loop my Int $i = 0; $i < @@.table.elems; $i++ {
        my Range $r := @@.table[$i];
        my Any $v := @.val[$i];
        $s ~= ';' if $i;
        if $r.min == $r.max {
            $s ~= sprintf '%x', $r.min;
        } else {
            $s ~= sprintf '%x..%x', $r.min, $r.max;
        }
        $s ~= ":$v" if $v.chars;
    }
    return $s;
}

method print(|$args --> Bool) {
    return $.tostr.print(|$args);
}

method say(|$args --> Bool) {
    return $.tostr.say(|$args);
}

method contains(Int $x --> Bool) {
    return False if !+@@.table;
    return False if $x < @@.table[0].min;
    return False if $x > @@.table[*-1].max;
    my Int $min = 0;
    my Int $max = @@.table.elems-1;
    while $min <= $max {
        my Int $mid = ($max + $min) / 2;
        return True if $x ~~ @@.table[$mid];
        if $x < @@.table[$mid].min  {
            $max = $mid - 1;
        } else {
            $min = $mid + 1;
        }
    }
    return False;
}

method get(Int $x --> Any) {
    return undef if !+@@.table;
    return undef if $x < @@.table[0].min;
    return undef if $x > @@.table[*-1].max;
    my Int $min = 0;
    my Int $max = @@.table.elems-1;
    while $min <= $max {
        my Int $mid = ($max + $min) / 2;
        return @.val[$mid] if $x ~~ @@.table[$mid];
        if $x < @@.table[$mid].min  {
            $max = $mid - 1;
        } else {
            $min = $mid + 1;
        }
    }
    return undef;
}

method inverse(--> Utable) {
    my Utable $u.=new;
    if !+@@.table {
        $u.add(0 .. $unicode_max);
        return $u;
    }
    $u.add(0 ..^ @@.table[0].min);
    # $i < @@.table.elems-1 is intended
    loop my Int $i = 0; $i < @@.table.elems-1; $i++ {
        $u.add(@@.table[$i].max ^..^ @@.table[$i+1].min, :!preen);
    }
    $u.add(@@.table[*-1].max ^.. $unicode_max);
    return $u;
}

multi method add(Int $x, Any :$val, Bool :$preen = True -->) {
    return if $.contains($x);
    my Range $r = $x .. $x;
    if !+@@.table {
        @@.table[0] = $r;
        @.val[0] = $val if defined $val;
        return;
    }
    my Int $min = 0;
    my Int $max = @@.table.elems-1;
    while $min <= $max {
        if $x < @@.table[$min].min {
            @@.table.=splice: $min, 0, $r;
            @.val.=splice: $min, 0, $val if @.val;
            $.preen if $preen;
            return;
        }
        if $x > @@.table[$max].max {
            @@.table.=splice: $max+1, 0, $r;
            @.val.=splice: $max+1, 0, $val if @.val;
            $.preen if $preen;
            return;
        }
        my Int $mid = ($max + $min) / 2;
        if $x < @@.table[$mid].min {
            $max = $mid - 1;
        } else {
            $min = $mid + 1;
        }
    }
    die "Utable::add got lost somehow";
}

multi method add(Range $r, Any :$val, Bool :$preen = True -->) {
    if !+@@.table {
        @@.table[0] = $r;
        @.val[0] = $val if defined $val;
        $.preen if $preen;
        return;
    }
    my Int $min = 0;
    my Int $max = @@.table.elems-1;
    while $min <= $max {
        if $r.max < @@.table[$min].min {
            @@.table.=splice: $min, 0, $r;
            @.val.=splice: $min, 0, $val if @.val;
            $.preen if $preen;
            return;
        }
        if $r.min > @@.table[$max].max {
            @@.table.=splice: $max+1, 0, $r;
            @.val.=splice: $max+1, 0, $val if @.val;
            $.preen if $preen;
            return;
        }
        my Int $mid = ($max + $min) / 2;
        my Range $m := @@.table[$mid];
        if ( $r.max >= $m.min and $r.min <= $m.min ) or ( $r.max >= $m.max and $r.min <= $m.max ) {
            # $r and $m overlap
            die "Utable::add: can't add overlapping ranges with different values"
                if $val !eqv @.val[$mid];
            $m = min($r.min, $m.min) .. max($r.max, $m.max);
            $.preen if $preen;
            return;
        }
        if $r.max < @@.table[$mid].min {
            $max = $mid - 1;
        } else {
            $min = $mid + 1;
        }
    }
    die "Utable::add got lost somehow";
}

method preen(-->) {
    # delete null ranges, fix up range overlaps and contiguities
    loop my Int $i = 0; $i < @@.table.elems; $i++ {
        if @@.table[$i].max < @@.table[$i].min {
            @@.table[$i].delete;
            @.val[$i].delete;
        }
        last if $i == @@.table.elems-1;
        if @@.table[$i].max >= @@.table[$i+1].min and @.val[$i] eqv @.val[$i+1]  {
            @@.table.=splice: $i, 2, @@.table[$i].min .. @@.table[$i+1].max;
            @.val[$i+1].delete;
        }
    }
}
