use v6;

use Test;

plan 2;

=begin pod

xinming audreyt: class A is A { };    <---  This error is reported at compile time or runtime?
xinming I mean, it will reported when it sees `class A is A` or, when A.new is invoked
audreyt I suspect compile time is the correct answer

=end pod

ok(!eval('role RA does RA { }; 1'), "Testing `role A does A`");
ok(!eval('class CA is CA { }; 1'), "Testing `class A is A`");

