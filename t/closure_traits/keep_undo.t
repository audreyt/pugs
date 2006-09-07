use v6-alpha;

use Test;

plan 8;

# L<S04/Closure traits/KEEP "at every successful block exit">
# L<S04/Closure traits/UNDO "at every unsuccessful block exit">

{
    my $str;
    my sub is_pos ($n) {
        return ($n > 0);
        KEEP { $str ~= "$n>0 " }
        UNDO { $str ~= "$n<=0 " }
    }

    ok is_pos(1), 'is_pos worked for 1';
    is $str, '1>0 ', 'KEEP ran as expected';

    ok !is_pos(0), 'is_pos worked for 0';
    is $str, '1>0 0<=0 ', 'UNDO worked as expected';

    ok !is_pos(-1), 'is_pos worked for 0';
    is $str, '1>0 0<=0 -1<=0 ', 'UNDO worked as expected';
}

# L<S04/Closure traits/KEEP UNDO are "variants of LEAVE"
#   "treated as part of the queue of LEAVE blocks">
{
    my $str;
    my sub is_pos($n) {
        return $n > 0;
        LEAVE { $str ~= ")" }
        KEEP { $str ~= "$n>0" }
        UNDO { $str ~= "$n<=0" }
        LEAVE { $str ~= "(" }
    }

    is_pos(1);
    is $str, '(1>0)';

    is_pos(-5);
    is $str, '(1>0)(-5<=0)';
}
