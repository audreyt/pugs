#!/usr/bin/pugs

use v6;
use Test;

plan 10;

=pod

Conflict resolution role tests, see L<S12/"Roles">

=cut

# L<S12/"Roles">
my ($was_in_sentry_shake, $was_in_pet_shake, $was_in_general_shake) = (0) xx 3;
role Sentry { method shake() { $was_in_sentry_shake++; "A" } }
role Pet    { method shake() { $was_in_pet_shake++;    "B" } }

class General {
does Sentry;
does Pet;

method shake(Str $what) {
    $was_in_general_shake++;
    given $what {
        when "sentry" { return self.Sentry::shake() }
        when "pet"    { return self.Pet::shake()    }
    }
}
}
ok(::Pet, "role and class definition worked");

my $a;
ok(($a = General.new()),      "basic class instantiation works");
is $a.shake("sentry"), "A", "conflict resolution works (1-1)";
is      $was_in_general_shake,  1, "conflict resolution works (1-2)";
is      $was_in_sentry_shake,   1, "conflict resolution works (1-3)";
# As usual, is instead of todo_is to avoid unexpected suceedings.
is      $was_in_pet_shake,      0, "conflict resolution works (1-4)";
is $a.shake("pet"),    "B", "conflict resolution works (2-1)";
is      $was_in_general_shake,  2, "conflict resolution works (2-2)";
is      $was_in_sentry_shake,   1, "conflict resolution works (2-3)";
is      $was_in_pet_shake,      1, "conflict resolution works (2-4)";
