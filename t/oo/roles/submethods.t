use v6-pugs;

use Test;

plan 1;

=pod

Tests of roles with submethods

=cut

my $did_build = 0;

role AddBuild
{
    submethod BUILD ( $self: )
    {
        $did_build = 1;
    }
}

class MyClass does AddBuild {}

my $class = MyClass.new();
ok( $did_build, 'Class that does role should do submethods of role' );
