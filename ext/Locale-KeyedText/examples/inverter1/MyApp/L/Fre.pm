use v6;

###########################################################################
###########################################################################

my Str %TEXT_STRINGS is readonly = (
    'MYAPP_HELLO' => q[Bienvenue allé MyApp.],
    'MYAPP_GOODBYE' => q[Salut!],
    'MYAPP_PROMPT'
        => q[Fournir nombre être inverser, ou appuyer sur]
           ~ q[ ENTER être arrêter.],
    'MYAPP_RESULT' => q[Renversement "<ORIGINAL>" est "<INVERTED>".],
);

module MyApp::L::Fre {
    sub get_text_by_key (Str $msg_key!) returns Str {
        return %TEXT_STRINGS{$msg_key};
    }
} # module MyApp::L::Fre

###########################################################################
###########################################################################
