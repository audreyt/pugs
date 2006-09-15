use v6-alpha;

###########################################################################
###########################################################################

# Constant values used by packages in this file:
my Str %TEXT_STRINGS is readonly = (
    'ROS_M_D_ARG_AOH_TO_CONSTR_RT_ND_HAS_KEY_CONFL'
        => q[<CLASS>.<METH>(): as expected, argument <ARG> is an Array]
           ~ q[ of Hashes, where each Hash specifies the values for]
           ~ q[ attributes of a new Node object to be created as a Root]
           ~ q[ Node of the invocant Document; however, at least one of]
           ~ q[ the given Hashes defines an explicit '<KEY>' key,]
           ~ q[ which isn't allowed when creating Nodes from <ARG>.],

    'ROS_M_N_ARG_AOH_TO_CONSTR_CH_ND_HAS_KEY_CONFL'
        => q[<CLASS>.<METH>(): as expected, argument <ARG> is an Array]
           ~ q[ of Hashes, where each Hash specifies the values for]
           ~ q[ attributes of a new Node object to be created as a Child]
           ~ q[ Node of the invocant Node; however, at least one of]
           ~ q[ the given Hashes defines an explicit '<KEY>' key,]
           ~ q[ which isn't allowed when creating Nodes from <ARG>.],
);

###########################################################################
###########################################################################

module Rosetta::Model::L::en-0.400.2 {
    sub get_text_by_key (Str $msg_key!) returns Str {
        return %TEXT_STRINGS{$msg_key};
    }
} # module Rosetta::Model::L::en

###########################################################################
###########################################################################

=pod

=encoding utf8

=head1 NAME

Rosetta::Model::L::en -
Localization of Rosetta::Model for English

=head1 VERSION

This document describes Rosetta::Model::L::en version 0.400.2.

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
