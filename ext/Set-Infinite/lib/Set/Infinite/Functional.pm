use v6-alpha;

use Span;

class Set::Infinite::Functional-0.01;

has @.spans;

submethod BUILD ( @.spans ) {}

method empty_set ($class: ) returns Set::Infinite::Functional {
    $class.new( spans => [] );
}

method universal_set ($class: ) returns Set::Infinite::Functional {
    $class.new( spans => [Span.new( start => -Inf, end => Inf )] );
}

method is_empty () returns bool { return ! @.spans }

method is_infinite ($self: ) returns bool {
    return $self.start == -Inf || $self.end == Inf
}

method start () returns Object {
    return unless @.spans;
    my $head = @.spans[0];
    return $head.start;
}
method end () returns Object {
    return unless @.spans;
    my $last = @.spans[-1];
    return $last.end;
}
method start_is_open () returns bool {
    return Bool::False unless @.spans;
    my $head = @.spans[0];
    return $head.start_is_open;
}
method start_is_closed () returns bool {
    return Bool::False unless @.spans;
    my $head = @.spans[0];
    return $head.start_is_closed;
}
method end_is_open () returns bool {
    return Bool::False unless @.spans;
    my $last = @.spans[-1];
    return $last.end_is_open;
}
method end_is_closed () returns bool {
    return Bool::False unless @.spans;
    my $last = @.spans[-1];
    return $last.end_is_closed;
}
method stringify () returns String {
    return '' unless @.spans;
    return @.spans.map:{ .stringify }.join( ',' );
}
method size () returns Object {
    return [+] @.spans.map:{ .size };
}

method union ($self: Set::Infinite::Functional $set ) 
    returns Set::Infinite::Functional 
{
    # TODO - optimize; invert loop order, since the new span is usually "after"
    my @tmp;
    my @res;
    my @a = @.spans, $set.spans.[];
    @a = @a.sort:{ $^a.compare( $^b ) };
    # say "union ", @a.map:{ $_.stringify }.join(":");
    @res[0] = shift @a
        if @a;
    while @a {
        my $elem = shift @a;
        @tmp = @res[-1].union( $elem );
        # say "span union ", @tmp.map:{ $_.stringify }.join(":");
        if @tmp == 3 {
            # intersecting Recurrence Spans
            # say "push ", @tmp[0], " left ", @tmp[1,2];
            @res[-1] = @tmp[0];
            unshift @a, @tmp[1,2];
            redo;
        }
        if @tmp == 2 {
            push @res, @tmp[1];
        }
        else {
            @res[-1] = @tmp[0];
        }
    }
    return $self.new( spans => @res );
}

method intersection ($self: Set::Infinite::Functional $set ) returns Set::Infinite::Functional {
    # TODO - optimize
    my @res;
    my @a = @.spans;
    my @b = $set.spans;
    while @a && @b {
        push @res, @a[0].intersection( @b[0] );
        if @a[0].end < @b[0].end { shift @a } else { shift @b }
    }
    return $self.new( spans => @res );
}

method intersects ( Set::Infinite::Functional $set ) returns bool {
    # TODO - optimize
    my @res;
    my @a = @.spans;
    my @b = $set.spans;
    while @a && @b {
        return Bool::True if @a[0].intersection( @b[0] );
        if @a[0].end < @b[0].end { shift @a } else { shift @b }
    }
    return Bool::False;
}

method complement ($self: ) returns Set::Infinite::Functional {
    return $self.universal_set() 
        if $self.is_empty;
    return @.spans.map:{ $self.new( spans => $_.complement ) }\
                  .reduce:{ $^a.intersection( $^b ) };
}

method difference ($self: Set::Infinite::Functional $span ) returns Set::Infinite::Functional {
    return $self.intersection( $span.complement );
}

method compare ($self: Set::Infinite::Functional $span ) returns int {
    ...
}

=kwid

= NAME

Set::Infinite::Functional - An object representing an ordered set of spans.

= SYNOPSIS

  use Set::Infinite::Functional;

  # XXX

= DESCRIPTION

This class represents an ordered set of spans.

It is intended mostly for "internal" use by the Set::Infinite class. 
For a more complete API, see `Set::Infinite`.

= CONSTRUCTORS

- `new()`

Creates an empty set.

- `new( spans => @spans )`

Creates a set containing zero or more `Span` objects.

The array of spans must be ordered, and the spans must not intersect with each other.

- empty_set()

- universal_set()

= OBJECT METHODS

    # XXX

- `start()` / `end()`

Return the start or end value of the span.

These methods may return nothing if the span is empty.

- `start_is_open()` / `end_is_open()` / `start_is_closed()` / `end_is_closed()`

Return a logical value, whether the `start` or `end` values belong to the span ("closed") or not ("open").

- size()

Return the "size" of the span.

For example: if `start` and `end` are times, then `size` will be a duration.

- `intersects( $set )`

This method return a logical value.

- union( $set ) / intersection( $set )

  # XXX

- complement()

  # XXX

- intersects( $set )

  # XXX
  
- difference( $set )

  # XXX

- stringify() 

  # XXX

- compare

  # XXX
  
- is_empty()

- is_infinite()

- `spans()`

Returns a list of `Span` objects.

= AUTHOR

Flavio S. Glock, <fglock@gmail.com>

= COPYRIGHT

Copyright (c) 2005, Flavio S. Glock.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
