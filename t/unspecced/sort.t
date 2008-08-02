use v6;

use Test;

plan 28;

# This is a perl6 implementation of L<S29/List/"=item sort">
# based on mergesort.

=begin comment

  * Existence
     * Clarify why this implementation of a spec'ed feature
       exists in the "unspecced" directory of the test suite. 
        * That was where suggested when asked for suggestions
          on #perl6.  Other suggestions welcome.

  * Pugs
     * `subset`

  * Spec
     * any Ordering has traits or only top level?
        *  {.TEST(:M)} is descending => &fuzzy_cmp is insensitive

  * Syntax cleanup
     * guidance on making this the builtin sort()

=end comment

# L<S29/"List"/"=item sort">

my $prelude_sort = q:to'END_PRELUDE_SORT';
    subset KeyExtractor of Code where { .sig === :(Any --> Any) };
    subset Comparator   of Code where { .sig === :(Any, Any --> Int) };
    subset OrderingPair
        of Pair where { .key ~~ KeyExtractor && .value ~~ Comparator };
    subset Ordering
        of Signature | KeyExtractor | Comparator | OrderingPair;

    module Prelude::Sort {
        our Order
        sub qby_cmp (Code @qby, $a, $b)
        {
            my $result        = Order::Same;
            my &return_ifn0 ::= -> $v { if $v { $result = $v; leave LOOP; } };

            LOOP: for @by -> $cmpr {
                return_ifn0 $cmpr($a, $b);
            }

            $result;
        }

        our bool
        sub in_order (Code @qby, *$x, *@xs)
        {
            my $result = 1;
            my $y := $x;

            for @xs -> $z {
                if by_cmp(@qby, $y, $z) > 0 {
                    $result = 0;
                    last;
                }

                $y := $z;
            }

            $result;
        }

        our Array of Code
        sub qualify_by (Ordering @by)
        {
            my Any sub keyex (KeyExtractor $ex, Any $v) is cached
                { $ex($v); }

            my Array sub sigkex (Signature $sig is copy, Any $v) is cached
                { $sig := $v; @$sig; }

            gather {
                for @by -> $criterion {
                    when Signature {
                        my Signature $sig := $crierion;
                        my Array &kex     := &sigkex;

                        my $cmpr -> $a, $b {
                            my $value;

                            for zip(@$a; @$b; @$sig) -> $x, $y, ::T {
                                my $u;
                                my $v;

                                if ( ::T ~~ canonicalized ) {
                                    $u = ::T.canonicalized.($x);
                                    $v = ::T.canonicalized.($y);
                                }
                                else {
                                    $u := $x;
                                    $v := $y;
                                }

                                last if $value = $u cmp $v;
                            }

                            $value;
                        }

                        if ( $sig ~~ descending ) {
                            $cmpr = -> $a, $b { $cmpr($b, $a) };
                        }

                        take( -> $a, $b {
                            $cmpr(kex($sig, $a), kex($sig, $b))
                            });
                    }

                    when KeyExtractor {
                        my KeyExtractor $ex := $criterion;
                        my &kex             := &keyex;

                        my $cmpr = &cmp;

                        if ( $ex ~~ canonicalized ) {
                            $cmpr = -> $a is copy, $b is copy {
                                $a = $ex.canonicalized.($a);
                                $b = $ex.canonicalized.($b);
                                $cmpr($a, $b)
                                };
                        }

                        if ( $ex ~~ descending ) {
                            $cmpr = -> $a, $b { $cmpr($b, $a) };
                        }

                        take( -> $a, $b { $cmpr(kex($ex, $a), kex($ex, $b)) } );
                    }

                    when Comparator {
                        my Comparator $cmpr = $criterion;

                        if ( $criterion ~~ insensitive ) {
                            $cmpr = -> $a, $b {
                                $a = $criterion.canonicalized.($a);
                                $b = $criterion.canonicalized.($b);
                                $cmpr($a, $b)
                                };
                        }

                        if ( $criterion ~~ descending ) {
                            $cmpr = -> $a, $b { $cmpr($b, $a) };
                        }

                        take($cmpr);
                    }

                    when Pair {
                        my OrderingPair $scp := $criterion;
                        my &kex              := &keyex;

                        my KeyExtractor $ex = $scp.key;
                        my Comparator $cmpr = $scp.value;

                        if ( $pair ~~ canonicalized ) {
                            $cmpr = -> $a, $b {
                                $a = $pair.canonicalized.($a);
                                $b = $pair.canonicalized.($b);
                                $cmpr($a, $b)
                                };
                        }

                        if ( $pair ~~ descending ) {
                            $cmpr = -> $a, $b { $cmpr($b, $a) };
                        }

                        take( -> $a, $b { $cmpr(kex($ex, $a), kex($ex, $b)) } );
                    }
                }
            }
        }

        # mergesort() --
        #   O(N*log(N)) time
        #   O(N*log(N)) space
        #   stable

        our Array
        sub mergesort (@values is rw, Ordering @by? = list(&infix:<cmp>),
            Bit $inplace?)
        {
            my @result;

            my @qby = qualify_by(@by);

            if $inplace {
                inplace_mergesort(@values, 0 => +@values, @qby);
                @result := @values;
            }
            else {
                my @copy = @values;
                inplace_mergesort(@copy, 0 => +@copy, @qby);
                @result := @copy;
            }

            @result;
        }

        our Pair
        sub inplace_mergesort (@values is rw, Pair $span, Code @qby)
        {
            my $result = $span;

            unless ( $span.value - $span.key == 1 || in_order(@qby, @values) ) {
                my $mid = $span.key + int( ($span.value - $span.key)/ 2 );

                $result = merge(
                    @values,
                    inplace_mergesort(@values, $span.key => $mid, @qby),
                    inplace_mergesort(@values, $mid => $span.value, @qby),
                    @qby
                );
            }

            $result;
        }

        our Pair
        sub merge (@values is rw, Pair $lspan, Pair $rspan, Code @qby)
        {
            # copy @left to a scratch area
            my @scratch = @values[$lspan.key ..^ $lspan.value];

            # merge @scratch and @right into and until @left is full
            my $lc = $lspan.key;
            my $rc = $rspan.key;
            my $sc = 0;

            while ( $lc < $lspan.value ) {
                @values[$lc++] = by_cmp(@qby, @scratch[$sc], @values[$rc]) <= 0
                    ?? @scratch[$sc++]
                    !! @values[$rc++];
            }

            # at this point @left is full.  start populating @right
            # until @scratch or @right is empty
            my $ri = $rspan.key;

            while ( $sc < +@scratch && $rc < $rspan.value ) {
                @values[$ri++] = by_cmp(@qby, @scratch[$sc], @values[$rc]) <= 0
                    ?? @scratch[$sc++]
                    !! @values[$rc++];
            }

            # anything remaining in @right is in the correct place.
            # anything remaining in @scratch needs to be filled into @right
                @values[$ri..^$rspan.value] = @scratch[$sc..^+@scratch];

            # return the merged span
            $lspan.key => $rspan.value;
        }
    }

    our Array multi Array::p6sort( @values is rw, *&by, Bit $inplace? )
    {
        Prelude::Sort::mergesort(@values, list(&by), $inplace);
    }

    our Array multi Array::p6sort( @values is rw, Ordering @by, Bit $inplace? )
    {
        Prelude::Sort::mergesort(@values, @by, $inplace);
    }

    our Array multi Array::p6sort( @values is rw, Ordering $by = &infix:<cmp>,
        Bit $inplace? )
    {
        Array::sort(@values, $by, $inplace);
    }

    our List multi List::p6sort( Ordering @by, *@values )
    {
        my @result = Prelude::Sort::mergesort(@values, @by);
        @result[];
    }

    our List multi List::p6sort( Ordering $by = &infix:<cmp>, *@values )
    {
        my @result = Prelude::Sort::mergesort(@values, list($by));
        @result[];
    }
END_PRELUDE_SORT

ok(eval($prelude_sort), 'prelude sort parses', :todo<sort>,
    :depends<subset and argument list return signatures>);

## tests

## sample() -- return a random sample of the input
sub sample (:$count, :$resample, *@data)
{
    my $max = $count ?? $count !! +@data;

    return gather {
        if ! ( $resample ) {
            my @copy = @data;

            loop (my $i = 0; $i < $max; ++$i ) {
                take( @copy.splice(int rand(+@copy), 1) );
            }
        }
        else {
            loop (my $i = 0; $i < $max; ++$i ) {
                take( @data[rand(+@data)] );
            }
        }
    }
}

my @num = sample   1..26;
my @str = sample 'a'..'z';
my @num_as_str = sample( '' >>~<< @num);

my @sorted_num =   1..26;
my @sorted_str = 'a'..'z';
my @sorted_num_as_str =
    <1 10 11 12 13 14 15 16 17 18 19 2 20 21 22 23 24 25 26 3 4 5 6 7 8 9>;

class Thingy {
    has $.name;
}

my @sorted_things = map { Thingy.new( :name($_) ) },
    ( reverse('N'..'Z'), reverse('a'..'m') );

my @unsorted_things = sample(@sorted_things);

{
    my @sorted;
    
    ok(eval('@sorted = p6sort @str;'), 'parse of p6sort',
        :todo<feature>);

    ok(@sorted eqv @sorted_str, 'string ascending; default cmp',
        :todo, :depends<p6sort>);
}

{
    my @sorted;
    
    ok(eval('@sorted = p6sort { $^a <=> $^b }, @num;'), 'parse of p6sort',
        :todo<feature>);

    ok(@sorted eqv @sorted_num, 'number ascending; Comparator',
        :todo, :depends<p6sort>);
}

{
    my @sorted;
    
    ok(eval('@sorted = p6sort { lc $^b.name cmp lc $^a.name }, @unsorted_things;'),
        'parse of p6sort', :todo<feature>);

    ok(@sorted eqv reverse(@sorted_things), 'string descending; Comparator',
        :todo, :depends<p6sort>);
}

{
    my @sorted;
    
    ok(eval('@sorted = p6sort { $^b.name cmp $^a.name } is insensitive, @str;'),
        'parse trait on block closure',
        :todo<feature>, 
        :depends<traits on block closures>);


    ok(@sorted eqv reverse(@sorted_str),
        'string descending; Comparator is insensitive',
        :todo, :depends<p6sort>);
}

{
    my @sorted;
    
    ok(eval('@sorted = p6sort { $^a.name cmp $^b.name } is descending is insensitive, @str;'),
        'parse trait on block closure',
        :todo<feature>,
        :depends<traits on block closures>);

    ok(@sorted eqv reverse(@sorted_str),
        'string descending; Comparator is descending is insensitive',
        :todo, :depends<p6sort>);
}

# TODO: Modtimewise numerically ascending...
# 
# my @files = sample { ... };
# my @sorted_files = qx( ls -t @files[] );

{
    # my @sorted = p6sort { $^a.:M <=> $^b.:M }, @files;
    #
    # ok(@sorted eqv @sorted_files, 'number ascending; Comparator',
    #     :todo<sort>);

}

sub fuzzy_cmp($x, $y) returns Int
{
    if ( 10 >= $x < 20 && 10 >= $y < 20 ) {
        return $y <=> $x;
    }

    return $x <=> $y;
}

{
    my @answer   = 5..9, reverse(10..19), 20..24;
    my @unsorted = sample(@answer);

    my @sorted;
    
    ok(eval('@sorted = p6sort &fuzzy_cmp, @unsorted;'),
        'parse of p6sort', :todo<feature>);

    ok(@sorted eqv @answer, 'number fuzzy; Comparator', :todo,
        :depends<sort>);
}

{
    my @sorted;
    
    ok(eval('@sorted = p6sort { + $^elem }, @num_as_str;'),
        'parse of p6sort', :todo<feature>);

    ok(@sorted eqv @sorted_num,
        'number ascending; KeyExtractor uses context',
        :todo, :depends<p6sort>);

    ok(eval('@sorted = p6sort { + $_ }, @num_as_str;'),
        'parse of p6sort', :todo<feature>);

    ok(@sorted eqv @sorted_num,
        'number ascending; KeyExtractor uses $_',
        :todo, :depends<p6sort>);
}

class Thingy {
    has $.name;
}

my @sorted_things = map { Thingy.new( :name($_) ) },
    ( reverse('N'..'Z'), reverse('a'..'m') );

my @unsorted_things = sample(@sorted_things);

{
    my @sorted;
    
    ok(eval('@sorted = p6sort { ~ $^elem.name } is descending is insensitive, @unsorted_things;'),
        'parse trait on block closure',
        :todo<feature>,
        :depends<traits on block closures>);

    ok(@sorted eqv @sorted_things,
        'string descending; KeyExtractor is descending is insensitive',
        :todo, :depends<p6sort>);

    ok(eval('@sorted = p6sort { lc $^elem.name } is descending, @unsorted_things;'),
        'parse trait on block closure',
        :todo<feature>,
        :depends<traits on block closures>);

    ok(@sorted eqv @sorted_things,
        'string descending; KeyExtractor is descending uses context',
        :todo, :depends<p6sort>);

    ok(eval('@sorted = p6sort { lc .name } is descending, @unsorted_things;'),
        'parse trait on block closure',
        :todo<feature>,
        :depends<traits on block closures>);

    ok(@sorted eqv @sorted_things,
        'string descending; KeyExtractor is descending uses dot',
        :todo, :depends<p6sort>);
}

{
    # my @sorted = p6sort { .:M } @files;
    #
    # ok(@sorted eqv @sorted_files, 'number ascending; KeyExtractor',
    #     :todo<sort>);
}

sub get_key ($elem) { return $elem.name; }

{
    my @sorted;
    
    ok(eval('@sorted = p6sort &get_key, @unsorted_things;'),
        'parse of p6sort', :todo<feature>);

    ok(@sorted eqv @sorted_things,
        'string ascending; KeyExtractor via sub',
        :todo, :depends<p6sort>);
}

my @numstr           = sample( 1..3, 'A'..'C', 'x'..'z', 10..12 );
my @sorted_di_numstr = list(<z y x>, <C B A>, reverse(1..3, 10..12)),

{
    my @sorted;

    # Not sure you can have traits on objects but
    # L<S29/List/=item sort>
    # says that any Ordering can have `descending` and `canonicalized($how)` traits.
    ok(eval('@sorted = p6sort ( { $_ } => {
        given $^a {
            when Num {
                given $^b {
                    when Num { $^a <=> $^b }
                    default { $^a cmp $^b }
                }
            }
            default { $^a cmp $^b }
        }
        }) is descending is canonicalized({$^v ~~ Str ?? lc($v) !! $v}),
        @numstr;'),
        'parse trait on object',
        :todo<feature>,
        :depends<traits on objects>);

    ok(@sorted eqv @sorted_di_numstr,
        'Num|Str fuzzy; Pair is descending is insensitive',
        :todo, :depends<p6sort>);

    # @sorted = p6sort { $_ ~~ :M } => { $^b cmp $^a }, @files;
    #
    # ok(@sorted eqv @sorted_modtime_cmp_files,
    #     'string descending; Pair uses cmp', 
    #     :todo<sort>);
    #
    # @sorted = p6sort { $_ ~~ :M } => &fuzzy_cmp, @files;
    #
    # ok(@sorted eqv @sorted_modtime_fuzzy_files,
    #     'number fuzzy; Pair',
    #     :todo<sort>);
    #
    # @sorted = p6sort ( { $_ ~~ :M } => { $^a cmp $^b } ) is descending, @files;
    #
    # ok(@sorted eqv @sorted_modtime_cmp_files,
    #     'string descending; Pair is descending', 
    #     :todo<sort>);
}

{
    # Need to think about this one to create a meaningful dataset.
    #
    #   # Numerically ascending
    #   # or else namewise stringifically descending case-insensitive
    #   # or else modtimewise numerically ascending
    #   # or else namewise fuzz-ifically
    #   # or else fuzz-ifically...
    #   @sorted = p6sort [ {+ $^elem},
    #                    {$^b.name cmp $^a.name} is insensitive,
    #                    {.TEST(:M)},
    #                    {.name}=>&fuzzy_cmp,
    #                    &fuzzy_cmp,
    #                  ],
    #                  @unsorted;
    #
    #   ok(@sorted eqv @sorted_whacky, 'obj whacky; @by', :todo<sort>);
}

my @inplace = @str;

{
    ok(@inplace !eqv @sorted_str, 'sampled data differs from answer');

    ok(eval('@inplace.p6sort(:inplace);', 'parse of p6sort with optional $inplace'),
        :todo<feature>);

    ok(@inplace eqv @sorted_str, 'inplace sort on array', :todo,
        :depends<p6sort>);
}
