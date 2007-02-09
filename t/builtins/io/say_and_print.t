use v6-alpha;

# Is another link for print?
# L<S16/"Input and Output"/"appends a newline">

say "1..14";

# Tests for say
{
    say "ok 1 - basic form of say";
}

{
    say "o", "k 2 - say with multiple parame", "ters (1)";

    my @array = ("o", "k 3 - say with multiple parameters (2)");
    say @array;
}

{
    my $arrayref = <ok 4 - say stringifies its args>;
    say $arrayref;
}

{
    "ok 5 - method form of say".say;
}

# Tests for print
{
    print "ok 6 - basic form of print\n";
}

{
    print "o", "k 7 - print with multiple parame", "ters (1)\n";

    my @array = ("o", "k 8 - print with multiple parameters (2)\n");
    print @array;
}

{
    my $arrayref = (<ok 9 - print stringifies its args>, "\n");
    print $arrayref;
}

{
    "ok 10 - method form of print\n".print;
}

{
    print "o";
    print "k 11 - print doesn't add newlines\n";
}

# Perl6::Spec::IO mentions
# print FILEHANDLE: LIST
# FILEHANDLE.print(LIST)
#  FILEHANDLE.print: LIST
 
{
    print $*DEFOUT: 'ok 12 - print with $*DEFOUT: as filehandle' ~ "\n";
}

{
    $*DEFOUT.print: 'ok 13 - $*DEFOUT.print: list' ~ "\n";
}

{
    my @array = 'ok', ' ',  '14 - $*DEFOUT.print(LIST)', "\n";
    $DEFOUT.print(@array);
}


