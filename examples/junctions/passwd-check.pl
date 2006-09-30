sub retrieve_passwords {
  <x y z>;
}

sub verify($password) {
  my @previous_passwords = retrieve_passwords;
  $password eq none(@previous_passwords);
}

sub read_new_password {

  print "Enter new password: ";
  my $password = =$IN;
}

while (not verify(read_new_password)) {
  say "Password matches a previous password";
}

print "New password accepted";
