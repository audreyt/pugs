
# XXX - doesnt work quite yet...
#module PIL::Run::Root::P5Runtime::PrimP6-0.0.1;
use v6;

=kwid

This file contains p5 runtime primitives which are written in p6.
Most will eventually be implemented in perl6/Prelude.pm, and can
then be removed from here.

See the note at the top of Prelude.pm.

=cut

my $?PUGS_BACKEND = "BACKEND_PERL5";

multi sub nothing () is builtin is primitive is safe {
    bool::true}

multi sub postcircumfix:<[ ]> ($a,$i) { Array::slice($a,$i) }

# TODO - string versions
multi sub infix:<..^> ($x0,$x1) { $x0..($x1-1) };
multi sub infix:<^..> ($x0,$x1) { ($x0+1)..$x1 };
multi sub infix:<^..^> ($x0,$x1) { ($x0+1)..($x1-1) };
multi sub postfix:<...> ($x0) { $x0 .. Inf };

multi sub prefix:<~> ($xx) { coerce:as($xx,'Str') };
multi sub prefix:<?> ($xx) { coerce:as($xx,'Bit') };
multi sub prefix:<+> ($xx) { coerce:as($xx,'Num') };
# multi sub prefix:<\\> ($xx) { coerce:as($xx,'Ref') };
multi sub true ($xx) { coerce:as($xx,'Bit') };

multi sub prefix:<!> ($xx) { 1 - coerce:as($xx,'Bit') };

# multi sub zip ($x0,$x1) { $x0.Array::zip($x1) };
multi sub infix:<Y> ($x0,$x1) { $x0.zip($x1) };
multi sub infix:<¥> ($x0,$x1) { $x0.zip($x1) };

multi sub prefix:<-> ($x) { 0 - $x }
multi sub sign ($x) { $x <=> 0 }
