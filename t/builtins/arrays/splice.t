#!/usr/bin/pugs

use Test;
use v6;

=head1 DESCRIPTION

This test tests the C<splice> builtin, see S29 and Perl 5's perlfunc.

Ported from the equivalent Perl 5 test.

This test includes a test for the single argument form of
C<splice>. Depending on whether the single argument form
of C<splice> should survive or not, this test should be dropped.

  my @a = (1..10);
  splice @a;

is equivalent to:

  my @a = (1..10);
  @a = ();

=cut

plan 33;

my (@a,@b,@res);

# Somehow, this doesn't propagate array context
# to splice(). The intermediate array in the calls
# should be removed later

sub splice_ok (Array @got, Array @ref, Array @exp, Array @exp_ref, Str $comment) {
  is "[@got[]]", "[@exp[]]", "$comment - results match";
  is @ref, @exp_ref, "$comment - array got modified in-place";

  # Once we get Test::Builder, this will be better:
  #if ( (@got ~~ @exp) and (@ref ~~ @exp_ref)) {
  #  fail($comment);
  #  if (@got !~ @exp) {
  #    diag "The returned result is wrong:";
  #    diag "  Expected: @exp";
  #    diag "  Got     : @got";
  #  };
  #  if (@ref !~ @exp_ref) {
  #    diag "The modified array is wrong:";
  #    diag "  Expected: @exp_ref";
  #    diag "  Got     : @exp";
  #  };
  #} else {
  #  ok($comment);
  #};
};

@a = (1..10);
@b = splice(@a,+@a,0,11,12);

is( @b, [], "push-via-splice result works" );
is( @a, ([1..12]), "push-via-splice modification works");

@a  = ('red', 'green', 'blue');
is( splice(@a, 1, 2), "blue", "splice() in scalar context returns last element of array");

# Test the single arg form of splice (which should die IMO)
@a = (1..10);
@res = splice(@a);
splice_ok( @res, @a, [1..10],[], "Single-arg splice returns the whole array" );

@a = (1..10);
@res = splice(@a,8,2);
splice_ok( @res, @a, [9,10], [1..8], "3-arg positive indices work");

@a = (1..12);
splice_ok splice(@a,0,1), @a, [1], [2..12], "Simple 3-arg splice";

@a = (1..10);
@res = splice(@a,8);
splice_ok @res, @a, [9,10], [1..8], "2-arg positive indices work";

@a = (1..10);
@res = splice(@a,-2,2);
splice_ok @res, @a, [9,10], [1..8], "3-arg negative indices work";

@a = (1..10);
@res = splice(@a,-2);
splice_ok @res, @a, [9,10], [1..8], "2-arg negative indices work";

# to be converted into more descriptive tests
@a = (2..10);
splice_ok splice(@a,0,0,0,1), @a, [], [0..10], "Prepending values works";

# Need to convert these
# skip 5, "Need to convert more tests from Perl5";
@a = (0..11);
splice_ok splice(@a,5,1,5), @a, [5], [0..11], "Replacing an element with itself";

@a = (0..11);
splice_ok splice(@a, @a, 0, 12, 13), @a, [], [0..13], "Appending a array";

@a = (0..13);
@res = splice(@a, -@a, @a, 1, 2, 3);
splice_ok @res, @a, [0..13], [1..3], "Replacing the array contents from right end";

@a = (1, 2, 3);
splice_ok splice(@a, 1, -1, 7, 7), @a, [2], [1,7,7,3], "Replacing a array into the middle";

@a = (1,7,7,3);
splice_ok splice(@a,-3,-2,2), @a, [7], [1,2,7,3], "Replacing negative count of elements";

# Test the identity of calls to splice:
# See also t/builtins/want.t, for the same test in a different
# setting
sub indirect_slurpy_context( @got ) { @got };


# splice4 gets "CxtItem _" or "CxtArray _" instead of "CxtSlurpy _"
my @tmp = (1..10);
@a = splice @tmp, 5, 3;
@a = indirect_slurpy_context( @a );
@tmp = (1..10);
@b = indirect_slurpy_context( splice @tmp, 5, 3 );
is( @b, @a, "Calling splice with immediate and indirect context returns consistent results" );
is( @a, [6,7,8], "Explicit call/assignment gives the expected results");
is( @b, [6,7,8], "Implicit context gives the expected results" );

my @tmp = (1..10);
@a = item splice @tmp, 5, 3;
is( @a, [8], "Explicit scalar context returns the last element");

## test some error conditions

@a = splice([], 1);
is +@a, 0, '... empty arrays are not fatal anymore';
# But this should generate a warning, but unfortunately we can't test for
# warnings yet.

dies_ok { 42.splice }, '.splice should not work on scalars';
