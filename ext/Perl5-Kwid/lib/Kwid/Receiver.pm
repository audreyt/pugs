
package Kwid::Receiver;
use strict;
use warnings;
use Kwid::Base;
use base 'Kwid::Base';
use Carp;

=head1 NAME

Kwid::Receive - a description of how to `receive' parse events

=head1 SYNOPSIS

  $emitter->emit_to($receiver);

=head1 METHODS

Exactly the same as Kwid::Emitter.  You can/should support a selection
of these methods:

=over

=item B<start_document({})>

=item B<end_document>

=item B<start_element({})>

=item B<end_element>

=item B<characters>

=item B<processing_instruction>

=item B<ignorable_whitespace>

=back

=cut

sub start_document { }
sub end_document { }
sub end_element { }
sub characters { }
sub processing_instruction { }
sub ignorable_whitespace { }

1;
