use v6-alpha;

use Test;

plan 2;

=pod

Tests of roles with SUPER

=cut

my $call_count = 0;

role ParentRole
{
    method interesting
    {
        return 'How Interesting';
    }
}

role ChildRole does ParentRole
{
    method interesting ( $self: )
    {
        return if $call_count++ > 1;
        my $rv;
        try {
           # XXX - SUPER and Roles?
           $rv = $self.SUPER::interesting();
        };
        return $rv;
    }
}

class MyClass does ChildRole {}

my $class       = MyClass.new();
my $interesting = $class.interesting();

is($call_count, 1, 'SUPER() should not hit the same class multiple times');
is($interesting, 'How Interesting', '... instead hitting parentmost method',
        :todo<bug>);
