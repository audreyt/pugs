# this is the algorithm for keeping the compile-time environment in pure-perl

# incrementally set environment; and keep a pad stack

use strict;
my @v;  # pad stack
my @d;  # pad inspectors

sub add_pad_level {
    my $var_name = shift;
    my $level = scalar @v;
    $v[$level] = $v[$level-1](
    ' do { my ' . $var_name . ' = 4;
    $d[' . $level . '] = sub { \'' . $var_name . '\' => ' . $var_name . ' };
    sub { ' . $var_name . '; eval $_[0] } }
    '
    );
}

$v[0] = do {
    my $x = 3;
    $d[0] = sub { '$x' => $x };
    sub { $x; eval $_[0] }
};  # set up closure

$v[0]( ' print "x=$x\n" ' );   # execute in this context level
print "sub=$v[0]\n";

add_pad_level( '$y' );

$v[1]( ' print "y=$y\n" ' );   # execute in this context level

add_pad_level( '$z' );

$v[2]( ' $y++ ' );   # execute in this context level
$v[2]( ' print "y=$y\n" ' );   # execute in this context level
$v[2]( ' print "done\n" ' );   # execute in this context level


# reconstruct env:

sub dump1 {
    my $level = shift;
    "{ my " . join( ' = ', $d[$level]() ) . '; ' .
    (   $level < $#d
        ? dump1( $level + 1 )
        : ''
    ) .
    " }";
}

print dump1(0), "\n";

__END__

# this is the algorithm for keeping the compile-time environment in pure-perl

# incrementally set environment; and keep a pad stack

use strict;
my @v;  # pad stack
my @d;  # pad inspectors

$v[0] = do {
    my $x = 3;
    $d[0] = sub { '$x' => $x };
    sub { $x; eval $_[0] }
};  # set up closure

$v[0]( ' print "x=$x\n" ' );   # execute in this context level
print "sub=$v[0]\n";

$v[1] = $v[0]( ' do { my $y = 4;
    $d[1] = sub { \'$y\' => $y };
    sub { $y; eval $_[0] } } ' );  # add a pad level

$v[1]( ' print "y=$y\n" ' );   # execute in this context level

$v[2] = $v[1]( ' do { my $z = 7;
    $d[2] = sub { \'$z\' => $z };
    sub { $z; eval $_[0] } } ' );  # add a pad level

$v[2]( ' $y++ ' );   # execute in this context level
$v[2]( ' print "y=$y\n" ' );   # execute in this context level
$v[2]( ' print "done\n" ' );   # execute in this context level


# reconstruct env:

sub dump1 {
    my $level = shift;
    "{ my " . join( ' = ', $d[$level]() ) . '; ' .
    (   $level < $#d
        ? dump1( $level + 1 )
        : ''
    ) .
    " }";
}

print dump1(0), "\n";

__END__


# - lexical grammar changes, such as
#  my multi infix:<+> ...
#  - the p6-parser is executed in the lexical context under compilation

use strict;
our @parsed = (
    '{',
    'my $x',
    '}',
);
our $env;
our @vars;

sub enter_pad {
    $env = sub {
        push @vars, {};
        { print "enter\n" }
    };
}
sub create_var {
    $env = sub {
        my $x = 42;  # the var is OUTER to the parser
        # problem - tied variables (FETCH and REF may have side-effects)
        $vars[-1]{'$x'} = \$x;
        { print "create\n" }
    };
}
sub exit_pad {
    $env = sub {
        { print "exit\n" }
        pop @vars;
    };
}

sub do_something {
    my $s = shift;
    return enter_pad()  if $s eq '{';
    return create_var() if $s eq 'my $x';
    return exit_pad()   if $s eq '}';
}

# main parser sub
$env = sub {
    print "init\n";
};
for ( @parsed ) {
    do_something( $_ );
    $env->();
}

__END__

use strict;

    INIT {
        Main::_begin_001_();
    }

    package Main;
    use Data::Dump::Streamer;
    my $y;
    my $z;
    sub _begin_001_ {
        my $x;
        $y = sub { $x };
        $z = sub { $x }
    }
    print Dump( $y );
    print Dump( $z );

__END__
=pod

    module Main;
    my $y;
    my $z;
    BEGIN {
        my $x;
        $y = { $x };
        $z = { $x }
     }

=cut

package Main;

    Compiler::set_scope();

package Compiler;

    use PadWalker qw(peek_my peek_our peek_sub closed_over);

    our $main_scope;
    sub set_scope {
        $main_scope = peek_my(1);
    }

__END__

    # how to declare my vars in another module?
    our $Main::y;
    our $Main::z;
    # how to scope the sub into another module?
    my $_begin = sub {
        my $x;
        $y = { $x };
        $z = { $x }
    };
    # list side-effects?


=begin

=head1 AUTHORS

The Pugs Team E<lt>perl6-compiler@perl.orgE<gt>.

=head1 SEE ALSO

The Perl 6 homepage at L<http://dev.perl.org/perl6>.

The Pugs homepage at L<http://pugscode.org/>.

=head1 COPYRIGHT

Copyright 2007 by Flavio Soibelmann Glock and others.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=end
