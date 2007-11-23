use v6-alpha;

say "1..11";

my $s3;
my $v3;
$s3 = ($v3{1}){2};
say "ok 1 - assignment from autovivified hash";

my $s4;
my $v4;
$s4 := ($v4{1}){2};
say "ok 2 - bind from autovivified hash";

my $s5;
my $v5;
$s5 = ($v5[1])[2];
say "ok 3 - assignment from autovivified array";

my $s6;
my $v6;
$s6 := ($v6[1])[2];
say "ok 4 - bind from autovivified array";



my $s7;
my $v7;
($s7{1}){2} = ($v7{1}){2};
say "ok 5 - assignment from,to autovivified hash";

my $s71;
($s71{1}){2} = 42;
if ($s71{1}){2} != 42 {
    print "not "
}
say "ok 6 - hash assignment worked";


my $s8;
my $v8;
($s8{1}){2} := ($v8{1}){2};
say "ok 7 - bind from,to autovivified hash";

($s8{1}){2} := 42;
if ($v8{1}){2} != 42 {
    print "not "
}
say "ok 8 - hash binding worked";

my $s9;
my $v9;
($s9[1])[2] = ($v9[1])[2];
say "ok 9 - assignment from,to autovivified array";

my $s10;
my $v10;
($s10[1])[2] := ($v10[1])[2];
say "ok 10 - bind from,to autovivified array";

($s10[1])[2] := 42;
if ($v10[1])[2] != 42 {
    print "not "
}
say "ok 11 - array binding worked";

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

