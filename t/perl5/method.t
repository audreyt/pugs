use v6-pugs;

use Test;

plan(13);

unless try({ eval("1", :lang<perl5>) }) {
    skip_rest;
    exit;
}

eval(q/
#line 16 method.t
package FooBar;
our $VERSION = '6.0';
print '';

sub new {
    bless {}, __PACKAGE__;
}

sub foo {
    return 'foo';
}

sub echo {
    my ($self, $what) = @_;
#print "==> echo got $what\n";
    return $what;
}

sub callcode {
    my ($self, $code) = @_;
#print "==> callcode got $code\n";
    return eval { $code->($self) };
}

sub asub {
    return sub { return "asub" };
}

sub submany {
    return sub { ("many", "return") };
}

sub many {
    return ("many", "return") ;
}

sub modify_array {
    my ($class, $val) = @_;
    warn $val;
    warn $#{$val};
    $val->[0]++;
}

# takes an object and invoke me on that
sub invoke {
    my ($class, $obj) = @_;
    $obj->me ('invoking');
}

/, :lang<perl5>);

{
    my $r = eval("FooBar->VERSION", :lang<perl5>);
    is($r, '6.0', "class method");
}

my $obj;

{
    $obj = eval("FooBar->new", :lang<perl5>);
    isa_ok($obj, 'FooBar', "blessed");
    like($obj, rx:perl5/FooBar/, "blessed");
}

{
    is($obj.foo, 'foo', 'invoke method');
}

{
    my $r = $obj.echo("bar");
    is($r, 'bar', 'invoke method with pugs arg');
}

{
    my $r = $obj.asub;
    isa_ok($r, 'CODE', "returning a coderef");
    is($r.(), 'asub', 'invoking p5 coderef');
    my $rr = $obj.callcode($r);
    is($rr, 'asub', 'invoke with p5 coderef');
}

{
    my @r = $obj.many;
    is(@r.elems, 2);
}

{
    my $r = $obj.submany;
    my @r = $r.();
    is(@r.elems, 2);
}

{
    my $callback = { "baz" };
    my $r = $obj.callcode($callback);
    is($r, 'baz', 'invoke method with callback');
}

{
    class Foo6 {
        method me (Class|Foo6 $class: $arg) { 'Foo6'~$arg };
    };
    my $obj6 = Foo6.new;
    $obj = eval("FooBar->new", :lang<perl5>);
    is($obj.invoke($obj6), 'Foo6invoking', 'invoke pugs method from p5');
}

# XXX Core dump
flunk("modify a scalar ref", :todo<feature>); exit;

{
    my @rw = (1);
    my $r = \@rw;
    $obj.modify_array($r);
    is(@rw[0], 2, 'modify a scalar ref', :todo<feature>);
}
