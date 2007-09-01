package Data::Transform::Trivial::Rule;
use strict;
use warnings;
###l4p use Data::Dumper;
###l4p use Log::Log4perl qw(:easy);

=head1 C<Rule->new($rule_name,\&matcher_sub,\&action_sub,$priority)>

Defaults:

=over 4

=item C<&matcher_sub>

  sub {1} # match anything

=item C<&action_sub>

  sub {} # do nothing

=item C<$priority>

  1

=back

=cut

sub new {
    my ($class,$name,$matcher,$action,$prio)=(@_);
    return bless {name=>$name,
                  matcher=>($matcher||sub{1}),
                  prio=>(defined($prio)?$prio:1),
                  action => ($action||sub{}),
              }, $class;
}

=head1 C<$rule->apply($context)>

Calls the action sub, setting C<$_> to the current node,
C<$main::_POS> to the current position, and C<@_> to the current node
list.

=cut

sub apply {
    my ($self,$context)=@_;
###l4p     DEBUG "Applying $self->{name} ($self->{prio}), position $context->{position}\n";
    local $_=$context->current_nodes->[$context->position];
    my ($caller_P,$caller_OUTER)=do {
        my $pkg=Data::Transform::Trivial::_caller_pkg();
        no strict 'refs';
        \*{$pkg.'::_P'},
        \*{$pkg.'::_OUTER'},
    };
    local *$caller_P=\($context->{position});
    push @{*$caller_OUTER},$context->current_nodes->[$context->position];
    local *$caller_OUTER=\(${*$caller_OUTER}[-2]);
#-##l4p DEBUG ('@_OUTER:',{filter=>\&Dumper,value=>\@{*$caller_OUTER}});
#-##l4p DEBUG ('$_OUTER:',{filter=>\&Dumper,value=>\${*$caller_OUTER}});
###l4p DEBUG ('@_OUTER:',map {defined($_) ? $_->attributes->{a} : '-'} @{*$caller_OUTER});
    my @ret=$self->{action}->(@{$context->current_nodes});
    pop @{*$caller_OUTER};
    return @ret;
}


=head1 C<$rule->matches($rule_name,$context)>

Returns true if this rule's name is C<$rule_name>, and the match sub
returns a true value.

The match sub is called setting C<$_> to the current node,
C<$main::_POS> to the current position, and C<@_> to the current node
list.

=cut

sub matches {
    my ($self,$name,$context)=@_;
    return unless $name eq $self->{name};
    local $_=$context->current_nodes->[$context->position];
    my ($caller_P)=do {
        my $pkg=Data::Transform::Trivial::_caller_pkg();
        no strict 'refs';
        \*{$pkg.'::_P'},
    };
    local *$caller_P=\($context->{position});
    return $self->{matcher}->(@{$context->current_nodes});
}

1;
