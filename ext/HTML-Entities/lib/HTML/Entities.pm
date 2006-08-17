use v6-alpha;
module HTML::Entities-0.2;

#@EXPORT = qw(encode_entities decode_entities _decode_entities);
#@EXPORT_OK = qw(%entity_to_char %char_to_entity encode_entities_numeric);

my %entity_to_char = (
 # Some normal chars that have special meaning in SGML context
    "amp"      => '&',  # ampersand 
    "gt"       => '>',  # greater than
    "lt"       => '<',  # less than
    "quot"     => '"',  # double quote
    "apos"     => "'",  # single quote

 # PUBLIC ISO 8879-1986//ENTITIES Added Latin 1//EN//HTML
    "AElig"    => 'Æ',  # capital AE diphthong (ligature)
    "Aacute"   => 'Á',  # capital A, acute accent
    "Acirc"    => 'Â',  # capital A, circumflex accent
    "Agrave"   => 'À',  # capital A, grave accent
    "Aring"    => 'Å',  # capital A, ring
    "Atilde"   => 'Ã',  # capital A, tilde
    "Auml"     => 'Ä',  # capital A, dieresis or umlaut mark
    "Ccedil"   => 'Ç',  # capital C, cedilla
    "ETH"      => 'Ð',  # capital Eth, Icelandic
    "Eacute"   => 'É',  # capital E, acute accent
    "Ecirc"    => 'Ê',  # capital E, circumflex accent
    "Egrave"   => 'È',  # capital E, grave accent
    "Euml"     => 'Ë',  # capital E, dieresis or umlaut mark
    "Iacute"   => 'Í',  # capital I, acute accent
    "Icirc"    => 'Î',  # capital I, circumflex accent
    "Igrave"   => 'Ì',  # capital I, grave accent
    "Iuml"     => 'Ï',  # capital I, dieresis or umlaut mark
    "Ntilde"   => 'Ñ',  # capital N, tilde
    "Oacute"   => 'Ó',  # capital O, acute accent
    "Ocirc"    => 'Ô',  # capital O, circumflex accent
    "Ograve"   => 'Ò',  # capital O, grave accent
    "Oslash"   => 'Ø',  # capital O, slash
    "Otilde"   => 'Õ',  # capital O, tilde
    "Ouml"     => 'Ö',  # capital O, dieresis or umlaut mark
    "THORN"    => 'Þ',  # capital THORN, Icelandic
    "Uacute"   => 'Ú',  # capital U, acute accent
    "Ucirc"    => 'Û',  # capital U, circumflex accent
    "Ugrave"   => 'Ù',  # capital U, grave accent
    "Uuml"     => 'Ü',  # capital U, dieresis or umlaut mark
    "Yacute"   => 'Ý',  # capital Y, acute accent
    "aacute"   => 'á',  # small a, acute accent
    "acirc"    => 'â',  # small a, circumflex accent
    "aelig"    => 'æ',  # small ae diphthong (ligature)
    "agrave"   => 'à',  # small a, grave accent
    "aring"    => 'å',  # small a, ring
    "atilde"   => 'ã',  # small a, tilde
    "auml"     => 'ä',  # small a, dieresis or umlaut mark
    "ccedil"   => 'ç',  # small c, cedilla
    "eacute"   => 'é',  # small e, acute accent
    "ecirc"    => 'ê',  # small e, circumflex accent
    "egrave"   => 'è',  # small e, grave accent
    "eth"      => 'ð',  # small eth, Icelandic
    "euml"     => 'ë',  # small e, dieresis or umlaut mark
    "iacute"   => 'í',  # small i, acute accent
    "icirc"    => 'î',  # small i, circumflex accent
    "igrave"   => 'ì',  # small i, grave accent
    "iuml"     => 'ï',  # small i, dieresis or umlaut mark
    "ntilde"   => 'ñ',  # small n, tilde
    "oacute"   => 'ó',  # small o, acute accent
    "ocirc"    => 'ô',  # small o, circumflex accent
    "ograve"   => 'ò',  # small o, grave accent
    "oslash"   => 'ø',  # small o, slash
    "otilde"   => 'õ',  # small o, tilde
    "ouml"     => 'ö',  # small o, dieresis or umlaut mark
    "szlig"    => 'ß',  # small sharp s, German (sz ligature)
    "thorn"    => 'þ',  # small thorn, Icelandic
    "uacute"   => 'ú',  # small u, acute accent
    "ucirc"    => 'û',  # small u, circumflex accent
    "ugrave"   => 'ù',  # small u, grave accent
    "uuml"     => 'ü',  # small u, dieresis or umlaut mark
    "yacute"   => 'ý',  # small y, acute accent
    "yuml"     => 'ÿ',  # small y, dieresis or umlaut mark

 # Some extra Latin 1 chars that are listed in the HTML3.2 draft (21-May-96)
    "copy"     => '©',  # copyright sign
    "reg"      => '®',  # registered sign
    "nbsp"     => "\o240", # non breaking space

 # Additional ISO-8859/1 entities listed in rfc1866 (section 14)
    "iexcl"    => '¡',
    "cent"     => '¢',
    "pound"    => '£',
    "curren"   => '¤',
    "yen"      => '¥',
    "brvbar"   => '¦',
    "sect"     => '§',
    "uml"      => '¨',
    "ordf"     => 'ª',
    "laquo"    => '«',
    "not"      => '¬',
    "shy"      => '­',
    "macr"     => '¯',
    "deg"      => '°',
    "plusmn"   => '±',
    "sup1"     => '¹',
    "sup2"     => '²',
    "sup3"     => '³',
    "acute"    => '´',
    "micro"    => 'µ',
    "para"     => '¶',
    "middot"   => '·',
    "cedil"    => '¸',
    "ordm"     => 'º',
    "raquo"    => '»',
    "frac14"   => '¼',
    "frac12"   => '½',
    "frac34"   => '¾',
    "iquest"   => '¿',
    "times"    => '×',
    "divide"   => '÷',
    "OElig"    => chr(338),
    "oelig"    => chr(339),
    "Scaron"   => chr(352),
    "scaron"   => chr(353),
    "Yuml"     => chr(376),
    "fnof"     => chr(402),
    "circ"     => chr(710),
    "tilde"    => chr(732),
    "Alpha"    => chr(913),
    "Beta"     => chr(914),
    "Gamma"    => chr(915),
    "Delta"    => chr(916),
    "Epsilon"  => chr(917),
    "Zeta"     => chr(918),
    "Eta"      => chr(919),
    "Theta"    => chr(920),
    "Iota"     => chr(921),
    "Kappa"    => chr(922),
    "Lambda"   => chr(923),
    "Mu"       => chr(924),
    "Nu"       => chr(925),
    "Xi"       => chr(926),
    "Omicron"  => chr(927),
    "Pi"       => chr(928),
    "Rho"      => chr(929),
    "Sigma"    => chr(931),
    "Tau"      => chr(932),
    "Upsilon"  => chr(933),
    "Phi"      => chr(934),
    "Chi"      => chr(935),
    "Psi"      => chr(936),
    "Omega"    => chr(937),
    "alpha"    => chr(945),
    "beta"     => chr(946),
    "gamma"    => chr(947),
    "delta"    => chr(948),
    "epsilon"  => chr(949),
    "zeta"     => chr(950),
    "eta"      => chr(951),
    "theta"    => chr(952),
    "iota"     => chr(953),
    "kappa"    => chr(954),
    "lambda"   => chr(955),
    "mu"       => chr(956),
    "nu"       => chr(957),
    "xi"       => chr(958),
    "omicron"  => chr(959),
    "pi"       => chr(960),
    "rho"      => chr(961),
    "sigmaf"   => chr(962),
    "sigma"    => chr(963),
    "tau"      => chr(964),
    "upsilon"  => chr(965),
    "phi"      => chr(966),
    "chi"      => chr(967),
    "psi"      => chr(968),
    "omega"    => chr(969),
    "thetasym" => chr(977),
    "upsih"    => chr(978),
    "piv"      => chr(982),
    "ensp"     => chr(8194),
    "emsp"     => chr(8195),
    "thinsp"   => chr(8201),
    "zwnj"     => chr(8204),
    "zwj"      => chr(8205),
    "lrm"      => chr(8206),
    "rlm"      => chr(8207),
    "ndash"    => chr(8211),
    "mdash"    => chr(8212),
    "lsquo"    => chr(8216),
    "rsquo"    => chr(8217),
    "sbquo"    => chr(8218),
    "ldquo"    => chr(8220),
    "rdquo"    => chr(8221),
    "bdquo"    => chr(8222),
    "dagger"   => chr(8224),
    "Dagger"   => chr(8225),
    "bull"     => chr(8226),
    "hellip"   => chr(8230),
    "permil"   => chr(8240),
    "prime"    => chr(8242),
    "Prime"    => chr(8243),
    "lsaquo"   => chr(8249),
    "rsaquo"   => chr(8250),
    "oline"    => chr(8254),
    "frasl"    => chr(8260),
    "euro"     => chr(8364),
    "image"    => chr(8465),
    "weierp"   => chr(8472),
    "real"     => chr(8476),
    "trade"    => chr(8482),
    "alefsym"  => chr(8501),
    "larr"     => chr(8592),
    "uarr"     => chr(8593),
    "rarr"     => chr(8594),
    "darr"     => chr(8595),
    "harr"     => chr(8596),
    "crarr"    => chr(8629),
    "lArr"     => chr(8656),
    "uArr"     => chr(8657),
    "rArr"     => chr(8658),
    "dArr"     => chr(8659),
    "hArr"     => chr(8660),
    "forall"   => chr(8704),
    "part"     => chr(8706),
    "exist"    => chr(8707),
    "empty"    => chr(8709),
    "nabla"    => chr(8711),
    "isin"     => chr(8712),
    "notin"    => chr(8713),
    "ni"       => chr(8715),
    "prod"     => chr(8719),
    "sum"      => chr(8721),
    "minus"    => chr(8722),
    "lowast"   => chr(8727),
    "radic"    => chr(8730),
    "prop"     => chr(8733),
    "infin"    => chr(8734),
    "ang"      => chr(8736),
    "and"      => chr(8743),
    "or"       => chr(8744),
    "cap"      => chr(8745),
    "cup"      => chr(8746),
    "int"      => chr(8747),
    "there4"   => chr(8756),
    "sim"      => chr(8764),
    "cong"     => chr(8773),
    "asymp"    => chr(8776),
    "ne"       => chr(8800),
    "equiv"    => chr(8801),
    "le"       => chr(8804),
    "ge"       => chr(8805),
    "sub"      => chr(8834),
    "sup"      => chr(8835),
    "nsub"     => chr(8836),
    "sube"     => chr(8838),
    "supe"     => chr(8839),
    "oplus"    => chr(8853),
    "otimes"   => chr(8855),
    "perp"     => chr(8869),
    "sdot"     => chr(8901),
    "lceil"    => chr(8968),
    "rceil"    => chr(8969),
    "lfloor"   => chr(8970),
    "rfloor"   => chr(8971),
    "lang"     => chr(9001),
    "rang"     => chr(9002),
    "loz"      => chr(9674),
    "spades"   => chr(9824),
    "clubs"    => chr(9827),
    "hearts"   => chr(9829),
    "diams"    => chr(9830)
);

# Make the opposite mapping
my %char_to_entity;
for %entity_to_char.kv -> $key, $value {
    %char_to_entity{$value} = '&'~$key~';';
}

%char_to_entity.delete("'");  # only one-way decoding

# Fill in missing entities
for 0 .. 255 -> $ascii_val {
    %char_to_entity{~chr($ascii_val)} //= "&#$ascii_val;";
}

multi sub decode_entities($string is rw) is export
{
    my $result = $string;
    
    $result ~~ s:Perl5:g/&\#(\d+);?/{chr($0)}/;
    $result ~~ s:Perl5:g/(&\#[xX]([0-9a-fA-F]+);?)/{my $c = :16($1); $c < 256 ?? chr($c) !! $0}/;
    $result ~~ s:Perl5:g/(&(\w+);?)/{%entity_to_char{$1} // $0}/;
    
    $string = $result;
    
    return $result;
}

multi sub decode_entities(*@strings is rw) is export
{
    @strings.map: -> $string is copy { decode_entities($string); };
}

multi sub decode_entities(@strings is rw) is export
{
    @strings.map: -> $string is copy { decode_entities($string); };
}

sub encode_entities_numeric (Str $string) returns Str is export
{
    # XXX temp does not yet appear to be working
    #temp %char_to_entity;
    my %temp        = %char_to_entity;
    %char_to_entity = ();
    my $temp        = $string;
    my $result      = encode_entities($temp);
    %char_to_entity = %temp;
    return $result;
}

my %subst;  # compiled encoding regexps
sub encode_entities (Str $string is rw, $unsafe_chars?) is export
{
    my $result = $string;
    if ($string.defined && $unsafe_chars.defined) {
        #unless (exists %subst{$unsafe_chars}) {
        #    # Because we can't compile regex we fake it with a cached sub
        #    my $code = "sub {$string =~ s:perl5:g/([$string])/{\%char_to_entity{\$0} || num_entity(\$0)}/; return $string}";
        #    %subst{$unsafe_chars} = eval $code;
        #    die( 
        #        $! ~ " while trying to turn range: \"$string\"\n "
        #           ~ "into code: $code\n "
        #    ) if $!;
        #}
        #%subst{$unsafe_chars}($string);
        $result ~~ s:Perl5:g/([$unsafe_chars])/{
            %char_to_entity.exists($0)
                ?? %char_to_entity{$0}
                !! num_entity($0)
        }/;
    }
    else {
        # Encode control chars, high bit chars and '<', '&', '>', '"'
        $result ~~ s:perl5:g/([^\n\r\t !\#\$%\'-;=?-~])/{
            %char_to_entity.exists($0)
                ?? %char_to_entity{$0}
                !! num_entity($0)
        }/;
    }
    $string = $result;
    return $result;
}

sub num_entity($char) {
    '&#x' ~ uc(sprintf '%x;', ord($char));
}

1;

# Set up aliases
#*encode = \&encode_entities;
#*encode_numeric = \&encode_entities_numeric;
#*encode_numerically = \&encode_entities_numeric;
#*decode = \&decode_entities;

1;

# $Id: Entities.pm,v 1.29 2004/11/23 15:06:16 gisle Exp $

=head1 NAME

HTML::Entities - Encode or decode strings with HTML entities

=head1 SYNOPSIS

 use HTML::Entities;

 $a = "V&aring;re norske tegn b&oslash;r &#230res";
 decode_entities($a);
 encode_entities($a, "\o200-\o377");

For example, this:

 $input = "vis-à-vis Beyoncé's naïve\npapier-mâché résumé";
 print encode_entities($in), "\n"

Prints this out:

 vis-&agrave;-vis Beyonc&eacute;'s na&iuml;ve
 papier-m&acirc;ch&eacute; r&eacute;sum&eacute;

=head1 DESCRIPTION

B<Note>:  at the current time, this is a work in progress to test Pugs'
features.  It does not (yet) behave quite like the old 
L<HTML::Entities|HTML::Entities>.  Until we have it stabilized, these
docs will not be updated.  The tests that are passing represent the
current working features.

This module deals with encoding and decoding of strings with HTML
character entities.  The module provides the following functions:

=over 4

=item decode_entities( $string, ... )

This routine replaces HTML entities found in the $string with the
corresponding Unicode character.  Under perl 5.6 and earlier only
characters in the Latin-1 range are replaced. Unrecognized
entities are left alone.

If multiple strings are provided as argument they are each decoded
separately and the same number of strings are returned.

If called in void context the arguments are decoded in-place.

This routine is exported by default.

=item _decode_entities( $string, \%entity_to_char )

=item _decode_entities( $string, \%entity_to_char, $allow_unterminated )

This will in-place replace HTML entities in $string.  The %entity_to_char
hash must be provided.  Named entities not found in the %entity_to_char
hash are left alone.  Numeric entities are always expanded.

If $allow_unterminated is TRUE then we also unterminated named
entities will also be expanded.  The longest matching name in
%entity_to_char will be used.

   $string = "foo&nbspbar";
   _decode_entities($string, { nb => "@", nbsp => "\xA0" }, 1);
   print $string;  # will print "foo bar"

This routine is exported by default.

=item encode_entities( $string )

=item encode_entities( $string, $unsafe_chars )

This routine replaces unsafe characters in $string with their entity
representation. A second argument can be given to specify which
characters to consider unsafe (i.e., which to escape). The default set
of characters to encode are control chars, high-bit chars, and the
C<< < >>, C<< & >>, C<< > >>, and C<< " >>
characters.  But this, for example, would encode I<just> the
C<< < >>, C<< & >>, C<< > >>, and C<< " >> characters:

  $escaped = encode_entities($input, '<>&"');

This routine is exported by default.

=item encode_entities_numeric( $string )

=item encode_entities_numeric( $string, $unsafe_chars )

This routine works just like encode_entities, except that the replacement
entities are always C<&#xI<hexnum>;> and never C<&I<entname>;>.  For
example, C<escape_entities("r\xF4le")> returns "r&ocirc;le", but
C<escape_entities_numeric("r\xF4le")> returns "r&#xF4;le".

This routine is I<not> exported by default.  But you can always
export it with C<use HTML::Entities qw(encode_entities_numeric);>
or even C<use HTML::Entities qw(:DEFAULT encode_entities_numeric);>

=back

All these routines modify the string passed as the first argument, if
called in a void context.  In scalar and array contexts, the encoded or
decoded string is returned (without changing the input string).

If you prefer not to import these routines into your namespace, you can
call them as:

  use HTML::Entities ();
  $decoded = HTML::Entities::decode($a);
  $encoded = HTML::Entities::encode($a);
  $encoded = HTML::Entities::encode_numeric($a);

The module can also export the %char_to_entity and the %entity_to_char hashes,
which contain the mapping from all characters to the corresponding entities
(and vice versa, respectively).

=head1 AUTHOR

Gigle Aas.  Ported to Pugs by Curtis "Ovid" Poe.

=head1 COPYRIGHT

Copyright 1995-2004 Gisle Aas. All rights reserved.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

