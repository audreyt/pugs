
use v6;

# this namespace is from 'S29'
    our &Perl6::Array::pop     := &pop;
    our &Perl6::Array::push    := &push;
    our &Perl6::Array::shift   := &shift;
    our &Perl6::Array::unshift := &unshift;
    our &Perl6::Array::reverse := &reverse;
    our &Perl6::Array::map     := &map;
    our &Perl6::Array::grep    := &grep;

    # TODO - emit error message if attempting to instantiate an infinite list
    # TODO - does zip() has additional parameters?
    # TODO - document unsupported operations: join, reduce, sort
    # TODO - check grep() syntax
    # TODO - keys/kv/pairs/values with indexes - S29

class Lazy::List {
    has Code $.cstart;
    has Code $.cend;
    has Code $.ccount;
    class Lazy::Reverse is Lazy::List {
        has $.iter;
        method shift   ( Lazy::Reverse $self: ) { $.iter.pop   }
        method pop     ( Lazy::Reverse $self: ) { $.iter.shift }
        method reverse ( Lazy::Reverse $self: ) { $.iter       }
    }
    submethod BUILD ($class: 
            Coro ?$start, 
            Coro ?$end, 
            Coro ?$count ) 
    {
        $.cstart = $start // coro { yield -Inf };
        $.cend   = $end   // coro { yield  Inf };
        $.ccount = $count // sub  { Inf };
    }
    method shift   ( Lazy::List $self: ) { &{$self.cstart}() }
    method pop     ( Lazy::List $self: ) { &{$self.cend}()   }  
    method reverse ( Lazy::List $self: ) { Lazy::Reverse.new( :iter($self) ) }
    method elems   ( Lazy::List $self: ) { &{$self.ccount}() }

    method grep ( $array: Code $code ) { 
        my $ret = $array; 
        Lazy::List.new(
                start => coro {
                        my $x = $ret.shift // yield;
                        yield $x if &$code($x) 
                },
                end => coro { 
                        my $x = $ret.pop // yield;
                        yield $x if &$code($x) 
                },
        );
    }

    method map ( $array: Code $code ) { 
        my $ret = $array; 
        Lazy::List.new(
                start => coro {
                        my @ret;
                        my $x = $ret.shift // yield;
                        Perl6::Array::unshift @ret,&$code($x); 
                        yield Perl6::Array::shift @ret while @ret 
                },
                end => coro {
                        my @ret; 
                        my $x = $ret.pop // yield;
                        Perl6::Array::push @ret, &$code($x); 
                        yield Perl6::Array::pop @ret while @ret  
                },
        )
    }

    method uniq ( $array: ) { 
        my %seen = ();
        my $ret = $array; 
        Lazy::List.new(
                start => coro {
                        my $x = $ret.shift // yield;
                        unless %seen{$x} { 
                            %seen{$x} = bool::true; 
                            yield $x 
                        }                       
                },
                end => coro {
                        my $x = $ret.pop // yield;
                        unless %seen{$x} { 
                            %seen{$x} = bool::true; 
                            yield $x 
                        }  
                },
        )
    }

    method kv ( $array: ) { 
        my $ret = $array; 
        my $count = 0;
        Lazy::List.new(
                start => coro {
                        my $x = $ret.shift // yield;
                        yield $count++;
                        yield $x;
                },
                count => sub { $ret.elems + $ret.elems },
        )
    }

    method pairs ( $array: ) { 
        my $ret = $array; 
        my $count = 0;
        Lazy::List.new(
                start => coro {
                        my $x = $ret.shift // yield;
                        my $pair = $count => $x;
                        yield $pair;
                        $count++;
                },
                count => sub { $ret.elems },
        )
    }

    method keys ( $array: ) { 
        my $ret = $array; 
        my $count = 0;
        Lazy::List.new(
                start => coro {
                        my $x = $ret.shift // yield;
                        yield $count++; 
                },
                count => sub { $ret.elems },
        )
    }

    method values ( $array: ) { 
        $array
    }

    method zip ( $array: *@list ) { 
        # TODO: implement zip parameters
        # TODO: implement count = max( @lists.elems )
        my @lists = ( $array, @list );
        Lazy::List.new(
                start => coro {
                        my @x;
                        my $count = 0;
                        # XXX - the list would normally stop after the first 'undef'
                        for @lists -> $xx {
                            Perl6::Array::push @x, [$xx.shift];
                        }
                        if defined any(@x) {
                            for @lists -> $xx {
                                yield Perl6::Array::shift @x;
                            }
                        }
                        else {
                            yield;
                        }
                }
        )
    }

}  # end class Lazy::List

    # XXX - what does (9..1) do?

class Lazy::Range is Lazy::List 
{
    has $.start;
    has $.end;
    has $.step;
    method shift ( Lazy::Range $self: ) {
        my $tmp = $self.start; 
        defined $self.step ?? $self.start += $self.step :: $self.start++;
        return if $tmp > $self.end;
        $tmp;
    }    
    method pop   ( Lazy::Range $self: ) {
        my $tmp = $self.end;
        defined $self.step ?? $self.end -= $self.step :: $self.start--;
        return if $tmp < $self.start;
        $tmp;
    }
    method elems {
        return $.end - $.start + 1 unless defined $.step;
        return int( $.end - $.start + 1 ) / $.step;
    }
}

=kwid

= NAME

Lazy::Range - A lazy list representing a range 

Lazy::List - A lazy list created from coroutines

= SYNOPSIS

  my $iter1 = Lazy::Range.new( start => 10, end => 20 );

  my $iter2 = Lazy::List.new( start => coro mylist2 { yield $_ for 1..3; yield; } );

= DESCRIPTION

...

= CONSTRUCTORS

- `new( :start($a), :end($b), :step(1) )`

= METHODS

- `shift`

- `pop`

- `reverse`

= AUTHOR

Flavio S. Glock, <fglock@gmail.com>

= COPYRIGHT

Copyright (c) 2005, Flavio S. Glock.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
