use v6-alpha;

use Test;

=pod
    access or assgin on undeclared attribute will raise an error.

=cut

plan 12;


dies_ok { class A { method set_a { $.a = 1 }}; A.new.set_a; },
    "Test Undeclared public attribute assignment from a class", :todo<bug>;
dies_ok { role B { method set_b { $.b = 1 }};class C does B{ }; C.new.set_b; },
    "Test Undeclared public attribute assignment from a role", :todo<bug>;

dies_ok { class D { method d { $!d = 1 }}; D.new.d; },
    "Test Undeclared private attribute assignment from a class", :todo<bug>;
dies_ok { role E { method e { $!e = 1 }};class F does E{ }; F.new.e; },
    "Test Undeclared private attribute assignment from a role", :todo<bug>;

##### access the undeclared attribute
dies_ok { class H { method set_h { $.h }}; H.new.set_h; },
    "Test Undeclared public attribute access from a class", :todo<bug>;
dies_ok { role I { method set_i { $.i }};class J does I{ }; J.new.set_i; },
    "Test Undeclared public attribute access from a role", :todo<bug>;

dies_ok { class K { method k { $!k }}; K.new.k; },
    "Test Undeclared private attribute access from a class", :todo<bug>;
dies_ok { role L { method l { $!l }};class M does L{ }; M.new.l; },
    "Test Undeclared private attribute access from a role", :todo<bug>;


dies_ok { class N { method set_n { $.n := 1 }}; N.new.set_n; },
    "Test Undeclared public attribute binding from a class";
dies_ok { role O { method set_o { $.o := 1 }}; class P does O{ }; P.new.set_o },
    "Test Undeclared public attribute binding from a role";

dies_ok { class Q { method q { $!q := 1 }}; Q.new.q; },
    "Test Undeclared private attribute binding from a class";
dies_ok { role R { method r { $!r := 1 }};class S does R{ }; S.new.r; },
    "Test Undeclared private attribute binding from a role";

