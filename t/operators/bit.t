use v6-alpha;

use Test;

# Mostly copied from Perl 5.8.4 s t/op/bop.t

plan 22;

# test the bit operators '&', '|', '^', '+<', and '+>'

# numerics

# L<S03/Changes to Perl 5 operators/Bitwise operators get a data type prefix>
{

  # numeric
  is( 0xdead +& 0xbeef,   0x9ead,    'numeric bitwise +& of hexadecimal' );
  is( 0xdead +| 0xbeef,   0xfeef,    'numeric bitwise +| of hexadecimal' );
  is( 0xdead +^ 0xbeef,   0x6042,    'numeric bitwise +^ of hexadecimal' );
  is( +^0xdead +& 0xbeef, 0x2042,    'numeric bitwise +^ and +& together' );
                                     
  # string                           
  is( 'a' ~& 'A',         'A',       'string bitwise ~& of "a" and "A"' );
  is( 'a' ~| 'b',         'c',       'string bitwise ~| of "a" and "b"' );
  is( 'a' ~^ 'B',         '#',       'string bitwise ~^ of "a" and "B"' );
  is( 'AAAAA' ~& 'zzzzz', '@@@@@',   'short string bitwise ~&' );
  is( 'AAAAA' ~| 'zzzzz', '{{{{{',   'short string bitwise ~|' );
  is( 'AAAAA' ~^ 'zzzzz', ';;;;;',   'short string bitwise ~^' );
  
  # long strings
  my $foo = "A" x 150;
  my $bar = "z" x 75;
  my $zap = "A" x 75;
  
  is( $foo ~& $bar, '@' x 75,        'long string bitwise ~&, truncates' );
  is( $foo ~| $bar, '{' x 75 ~ $zap, 'long string bitwise ~|, no truncation' );
  is( $foo ~^ $bar, ';' x 75 ~ $zap, 'long string bitwise ~^, no truncation' );

  # "interesting" tests from a long time back...
  is( "ok \xFF\xFF\n" ~& "ok 19\n", "ok 19\n", 'stringwise ~&, arbitrary string' );
  is( "ok 20\n" ~| "ok \0\0\n", "ok 20\n",     'stringwise ~|, arbitrary string' );

  # bit shifting
  is( 32 +< 1,            64,     'shift one bit left' );
  is( 32 +> 1,            16,     'shift one bit right' );
  is( 257 +< 7,           32896,  'shift seven bits left' );
  is( 33023 +> 7,         257,    'shift seven bits right' ); 

  # Tests to see if you really can do casts negative floats to unsigned properly
  my $neg1 = -1.0;
  my $neg7 = -7.0;

  is(+^ $neg1, 0, 'cast numeric float to unsigned' );
  is(+^ $neg7, 6, 'cast -7 to 6 with +^' );
  ok(+^ $neg7 == 6, 'cast -7 with equality testing' );

}


# signed vs. unsigned
#ok((+^0 +> 0 && do { use integer; ~0 } == -1));

#my $bits = 0;
#for (my $i = ~0; $i; $i >>= 1) { ++$bits; }
#my $cusp = 1 << ($bits - 1);


#ok(($cusp & -1) > 0 && do { use integer; $cusp & -1 } < 0);
#ok(($cusp | 1) > 0 && do { use integer; $cusp | 1 } < 0);
#ok(($cusp ^ 1) > 0 && do { use integer; $cusp ^ 1 } < 0);
#ok((1 << ($bits - 1)) == $cusp &&
#    do { use integer; 1 << ($bits - 1) } == -$cusp);
#ok(($cusp >> 1) == ($cusp / 2) &&
#    do { use integer; abs($cusp >> 1) } == ($cusp / 2));

#--
#$Aaz = chr(ord("A") & ord("z"));
#$Aoz = chr(ord("A") | ord("z"));
#$Axz = chr(ord("A") ^ ord("z"));
# instead of $Aaz x 5, literal "@@@@@" is used and thus ascii assumed below
# (for now...)


# currently, pugs recognize octals as "\0o00", not "\o000".
#if ("o\o000 \0" ~ "1\o000" ~^ "\o000k\02\o000\n" eq "ok 21\n") { say "ok 15" } else { say "not ok 15" }

# Pugs does not have \x{}

#
#if ("ok \x{FF}\x{FF}\n" ~& "ok 22\n" eq "ok 22\n") { say "ok 16" } else { say "not ok 16" }
#if ("ok 23\n" ~| "ok \x{0}\x{0}\n" eq "ok 23\n") { say "ok 17" } else { say "not ok 17" }
#if ("o\x{0} \x{0}4\x{0}" ~^ "\x{0}k\x{0}2\x{0}\n" eq "ok 24\n") { say "ok 18" } else { say "not ok 18" }

# Not in Pugs: vstrings, ebcdic, unicode, sprintf

# More variations on 19 and 22
#if ("ok \xFF\x{FF}\n" ~& "ok 41\n" eq "ok 41\n") { say "ok 19" } else { say "not ok 19" }
#if ("ok \x{FF}\xFF\n" ~& "ok 42\n" eq "ok 42\n") { say "ok 20" } else { say "not ok 20" }



