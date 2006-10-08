use v6-alpha;

use Test;

plan(1);

unless eval 'eval("1", :lang<perl5>)' {
    skip_rest;
    exit;
}

die unless
eval(q/
package My::Hash;
use strict;

sub new {
    my ($class, $ref) = @_;
    bless \$ref, $class;
}

sub hash {
    my $self = shift;
    return $$self;
}

sub my_keys {
    my $self = shift;
    return keys %{$$self};
}

sub my_exists {
    my ($self, $idx) = @_;
    return exists $$self->{$idx};
}

sub fetch {
    my ($self, $idx) = @_;
    return $$self->{$idx};
}

sub store {
    my ($self, $idx, $val) = @_;
    $$self->{$idx} = $val;
}

sub push {
    my ($self, $val) = @_;
}

1;
/, :lang<perl5>);

my $p5ha = eval('sub { My::Hash->new($_[0]) }', :lang<perl5>);
my %hash = (5 => 'a', 6 => 'b', 7 => 'c', 8 => 'd');
my $p5hash = $p5ha(\%hash);

my $rethash = $p5hash.hash;
my @keys = %hash.keys.sort;
my @p5keys;
try {
    @p5keys = $p5hash.my_keys; # this doesn't even pass lives_ok ??
    @p5keys .= sort;
};

is("{ @keys }", "{ @p5keys }");
