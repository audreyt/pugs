#!/usr/bin/pugs

use v6;
require Test;

=kwid

Hash tests

=cut

plan 32;

# basic lvalue assignment
{
  my $hash; 
  isa_ok $hash, 'Any';

  $hash{"1st"} = 5; 
  isa_ok $hash, 'Hash';

  is $hash{"1st"}, 5, 'lvalue hash assignment works (w/ double quoted keys)';

  $hash{'1st'} = 4; 
  is $hash{'1st'}, 4, 'lvalue hash re-assignment works (w/ single quoted keys)';

  $hash<3rd> = 3; 
  is $hash<3rd>, 3, 'lvalue hash assignment works (w/ unquoted style <key>)';
}

# basic hash creation w/ comma seperated key/values
{
  my $hash = ("1st", 1);
  isa_ok $hash, 'List';
  is $hash{"1st"}, 1, 'comma seperated key/value hash creation works';
  is $hash<1st>,   1, 'unquoted <key> fetching works';
}

{
  my $hash = ("1st", 1, "2nd", 2);
  isa_ok $hash, 'List';
  is $hash{"1st"}, 1,
    'comma seperated key/value hash creation works with more than 1st pair';
  is $hash{"2nd"}, 2,
    'comma seperated key/value hash creation works with more than 1st pair';
}

# hash slicing
{
  my $hash = ("1st", 1, "2nd", 2, "3rd", 3);
  isa_ok $hash, 'List';

  my @slice1 = $hash{"1st", "3rd"};
  is +@slice1,   2, 'got the right amount of values from the %hash{} slice';
  is @slice1[0], 1, '%hash{} slice successfull (1)';
  is @slice1[1], 3, '%hash{} slice successfull (2)';

  my @slice2;
  @slice2 = $hash<3rd 1st>;
  is +@slice2,   2, 'got the right amount of values from the %hash<> slice';
  is @slice2[0], 3, '%hash<> slice was successful (1)';
  is @slice2[1], 1, '%hash<> slice was successful (2)';

  # slice assignment
  fail "FIXME: infinite loop";
  fail "FIXME: infinite loop";
  # $hash{"1st", "3rd"} = (5, 10);
  # is $hash<1st>,  5, 'value was changed successfully with slice assignment';
  # is $hash<3rd>, 10, 'value was changed successfully with slice assignment';

  fail "FIXME: infinite loop";
  fail "FIXME: infinite loop";
  # hash<1st 3rd> = [3, 1];
  # is $hash<1st>, 3, 'value was changed successfully with slice assignment';
  # is $hash<3rd>, 1, 'value was changed successfully with slice assignment';
}

# hashref assignment using {}
# L<S06/"Anonymous hashes vs blocks" /"So you may use sub or hash or pair to disambiguate:">
{
  my $hash_a = { a => 1, b => 2 };             isa_ok $hash_a, "Hash";
  my $hash_b = { a => 1, "b", 2 };             isa_ok $hash_b, "Hash";
  my $hash_c = eval 'hash(a => 1, "b", 2)';    isa_ok $hash_c, "Hash";
  my $hash_d = eval 'hash a => 1, "b", 2';     isa_ok $hash_d, "Hash";
  my $hash_e = { pair "a", 1, "b", 2 };        isa_ok $hash_e, "Hash";
}

# infinity HoHoHoH...
{
  my %hash = (val => 42);
  %hash<ref> = \%hash;
  isa_ok %hash,           "Hash";
  isa_ok %hash<ref>,      "Hash";
  isa_ok %hash<ref><ref>, "Hash";
  fail "FIXME: infinite loop";
  fail "FIXME: infinite loop";
  # is %hash<ref><val>,      42, "access to infinite HoHoHoH... (1)";
  # is %hash<ref><ref><val>, 42, "access to infinite HoHoHoH... (2)";
}
