use v6-alpha;

use Test;


BEGIN {
plan 3;
unless try({ eval("1", :lang<perl5>) }) {
    skip_rest('no perl 5 support'); exit;
}
}

use perl5:Carp;

my $err;
lives_ok({ try{ Carp.croak() }; $err = $! }, "Perl 5 exception (die) caught");
like($err, rx:P5/Carp/, "Exception is propagated to Perl 6 land");

eval(q[
package Foo;

sub new {
	bless {}, __PACKAGE__;
}

sub error {
	my $error = Foo->new;
	die $error;
}

sub test { "1" }
], :lang<perl5>);

my $foo = eval("Foo->new",:lang<perl5>);
try { $foo.error };
lives_ok( {
    my $err = $!;
    $err.test;
}, "Accessing Perl5 method doesn't die");
