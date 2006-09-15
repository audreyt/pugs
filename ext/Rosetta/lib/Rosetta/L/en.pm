use v6-alpha;

###########################################################################
###########################################################################

# Constant values used by packages in this file:
my Str %TEXT_STRINGS is readonly = (
);

###########################################################################
###########################################################################

module Rosetta::L::en-0.210.2 {
    sub get_text_by_key (Str $msg_key!) returns Str {
        return %TEXT_STRINGS{$msg_key};
    }
} # module Rosetta::L::en

###########################################################################
###########################################################################

=pod

=encoding utf8

=head1 NAME

Rosetta::L::en -
Localization of Rosetta for English

=head1 VERSION

This document describes Rosetta::L::en version 0.210.2.

=head1 SYNOPSIS

I<This documentation is pending.>

=head1 DESCRIPTION

I<This documentation is pending.>

=head1 INTERFACE

I<This documentation is pending; this section may also be split into several.>

=head1 DIAGNOSTICS

I<This documentation is pending.>

=head1 CONFIGURATION AND ENVIRONMENT

I<This documentation is pending.>

=head1 DEPENDENCIES

This file requires any version of Perl 6.x.y that is at least 6.0.0.

=head1 INCOMPATIBILITIES

None reported.

=head1 SEE ALSO

Go to L<Rosetta> for the majority of distribution-internal references, and
L<Rosetta::SeeAlso> for the majority of distribution-external references.

=head1 BUGS AND LIMITATIONS

I<This documentation is pending.>

=head1 AUTHOR

Darren R. Duncan (C<perl@DarrenDuncan.net>)

=head1 LICENCE AND COPYRIGHT

This file is part of the Rosetta DBMS framework.

Rosetta is Copyright (c) 2002-2006, Darren R. Duncan.

See the LICENCE AND COPYRIGHT of L<Rosetta> for details.

=head1 ACKNOWLEDGEMENTS

The ACKNOWLEDGEMENTS in L<Rosetta> apply to this file too.

=cut
