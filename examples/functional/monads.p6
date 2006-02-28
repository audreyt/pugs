#!/usr/bin/pugs

# Definition:
#   Haskell:   IO a
#   Perl 6:    { a }

# return :: (Monad m) => a -> m a
sub mreturn($a) { return { $a } }

# (>>=) :: (Monad m) => m a -> (a -> m b) -> m b
sub mbind(
  Code $ma,        # m a
  Code $f,        # (a -> m b)
            # This should be "Code $f returns Code", but Pugs doesn't
            # grok that yet.
) {
  return {
    my $a  = $ma();    # Run m a, yielding a
    my $mb = $f($a);   # Give $f the a, yielding m b
    $mb();             # Return b
  };
}

# (>>) :: (Monad m) => m a -> m b -> m b
sub mbind_ignore_result(Code $ma, Code $mb) {
  return {
    $ma();     # Run m a, ignoring the result
    $mb();     # Run and return m b
  };
}

# fail :: (Monad m) => String -> m a
# (We can't/shouldn't use "fail" in Perl 6, too, as "fail" is a builtin
# in Perl 6.)
sub mfail(Str $a) {
  return {
    die $a;
  };
}

sub sequence_(Code *@actions) {
  return {
    $_() for @actions;
    undef;
  };
}

sub sequence(Code *@actions) {
  return {
    my @res = @actions.map(-> $action { $action() });
    @res;
  };
}

sub mapM(Code $f, *@input) {
  return {
    @input.map($f).map(-> $i { $i() });
  };
}

# getLine :: IO String
# getLine = ...implemented by the compiler...
sub getLine() {
  return {
    my $line = =$*IN;
    $line;
  };
}

# putStrLn :: String -> IO ()
# putStrLn = ...implemented by the compiler...
sub putStrLn(Str $x) { return { say $x; undef } }


# Now some example code:
{
  my $line_from_user = getLine();
  # Nothing is read yet.
  my $echo = mbind($line_from_user, -> $x { putStrLn($x) });
  # Nothing is read or printed yet.
  my @actions = (getLine(), $echo);
  # Again, nothing printed yet.
  my $both = sequence_(@actions);
  # Only now there're two lines read from the user, and the second one is
  # echoed back.
  $both();
}

{
  # let actions = [getLine, getLine, getLine]
  # actions :: [IO String]
  my @actions = (getLine(), getLine(), getLine());

  # let results = sequence actions
  # results :: IO [String]
  my $results = sequence(@actions);

  my $echo_prefixed = mbind($results, -> *@results {
    mapM(-> Str $x { putStrLn($x) }, @results);
  });
  $echo_prefixed();
}
