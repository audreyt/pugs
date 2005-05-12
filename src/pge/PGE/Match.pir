=head1 NAME

PGE::Match - implementation of PGE match objects

=head1 DESCRIPTION

This file implements match objects returned by the Parrot Grammar Engine.

=cut

.namespace [ "PGE::Match" ]

.sub "__onload" 
    .local pmc base
    newclass base, "PGE::Match"
    addattribute base, "$:target"                  # target
    addattribute base, "$:from"                    # start of match
    addattribute base, "$:to"                      # end of match
    addattribute base, "&:yield"                   # match's yield
    addattribute base, "@:capt"                    # subpattern captures
    addattribute base, "%:capt"                    # subpattern captures
.end

=head2 Functions

=item C<start(STR target, PMC yield)>

This subroutine is normally called from a rule subroutine to
initiate a match object on C<target> using the rule coroutine
given by C<yield>.

=cut

.sub "start"
    .param string target                           # target
    .param pmc yield                               # coroutine
    .param int pos                                 # where to start
    .param int lastpos                             # length of target
    .local pmc me                                  # newly created match obj
    .local int offset                              # offset for attributes

    $P0 = new String
    $P0 = target
    $I0 = find_type "PGE::Match"
    me = new $I0, $P0
    setattribute me, "PGE::Match\x0&:yield", yield
    yield(me, target, pos, lastpos)                  # start match
    .return (me)
.end

=head2 Methods

=item C<__init(PMC target)>

Initializes a Match object with the string given by C<target>.  

=cut

.sub "__init" method
    .param pmc target
    $I0 = classoffset self, "PGE::Match"
    setattribute self, $I0, target
    inc $I0
    $P0 = new Integer
    setattribute self, $I0, $P0
    inc $I0
    $P0 = new Integer
    $P0 = -1
    setattribute self, $I0, $P0
.end

=item C<next()>

Tell a Match object to continue the previous match from where it left off.

=cut

.sub "next" method
    .local pmc yield

    yield = getattribute self, "PGE::Match\x0&:yield"
    .pcc_begin prototyped
    .pcc_call yield
    .pcc_end
.end

=item C<from()>

Returns the offset in the target string of the first item
this object matched.

=cut

.sub "from" method
    .local pmc from
    from = getattribute self, "PGE::Match\x0$:from"
    $I0 = from
    .return ($I0)
.end

=item C<to()>

Returns the offset at the end of this match.

=cut

.sub "to" method
    .local pmc to
    to = getattribute self, "PGE::Match\x0$:to"
    $I0 = to
    .return ($I0)
.end

=item C<__get_bool()>

Returns 1 if this object successfully matched the target string,
0 otherwise.

=cut

.sub "__get_bool" method
    $P0 = getattribute self, "PGE::Match\x0$:to"
    $I0 = $P0
    isge $I1, $I0, 0
    .return ($I1)
.end

=item C<__get_integer()>

Returns 1 if this object successfully matched the target string,
0 otherwise.

=cut

.sub "__get_integer" method
    $P0 = getattribute self, "PGE::Match\x0$:to"
    $I0 = $P0
    isge $I1, $I0, 0
    .return ($I1)
.end

=item C<__get_string()>

Returns the portion of the target string matched by this object.

=cut

.sub "__get_string" method
    $P0 = getattribute self, "PGE::Match\x0$:target"
    $P1 = getattribute self, "PGE::Match\x0$:from"
    $P2 = getattribute self, "PGE::Match\x0$:to"
    if $P2 < 0 goto false
    if $P2 <= $P1 goto false
    $I1 = $P1
    $I2 = $P2
    $I2 -= $I1
    $S1 = substr $P0, $I1, $I2
    .return ($S1)
  false:
    .return ("")
.end

=item C<__get_pmc_keyed(PMC key)>

Returns the subpattern or subrule capture associated with C<key>.  
If the first character of C<key> is a digit then return the
subpattern, otherwise return the subrule.  Note that this will 
return either a single Match object or an array of match objects 
depending on the rule.

=cut

.sub "__get_pmc_keyed" method
    .param pmc key
    .local pmc capt
    $S0 = key
    $I0 = is_digit $S0, 0
    unless $I0 goto keyed_1
    capt = getattribute self, "PGE::Match\x0@:capt"
    goto keyed_2
  keyed_1:
    capt = getattribute self, "PGE::Match\x0%:capt"
  keyed_2:
    $P0 = capt[key]
    $P1 = getprop "isarray", $P0
    if $P1 goto end
    $P0 = $P0[-1]
  end:
    .return ($P0)
.end

=item C<dump()>

Produces a data dump of the match object and all of its subcaptures.

=cut
   
.sub "dump" method
    .param string prefix
    .param string b1
    .param string b2
    .local pmc capt
    .local int spi, spc
    .local pmc iter
    .local string prefix1, prefix2
    unless argcS < 3 goto start
    b2 = "]"
    unless argcS < 2 goto start
    b1 = "["
  start:
    print prefix
    print ":"
    $I0 = self
    unless $I0 goto subpats
    print " <"
    print self
    print " @ "
    $I0 = self."from"()
    print $I0
    print "> "

  subpats:
    $I0 = self
    print $I0
    print "\n"
    capt = getattribute self, "PGE::Match\x0@:capt"
    isnull capt, subrules
    spi = 0
    spc = elements capt
  subpats_1:
    unless spi < spc goto subrules
    prefix1 = concat prefix, b1
    $S0 = spi
    concat prefix1, $S0
    concat prefix1, b2
    $I0 = defined capt[spi]
    unless $I0 goto subpats_2
    $P0 = capt[spi]
    bsr dumper
  subpats_2:
    inc spi
    goto subpats_1

  subrules:
    capt = getattribute self, "PGE::Match\x0%:capt"
    isnull capt, end
    iter = new Iterator, capt
    iter = 0
  subrules_1:
    unless iter goto end
    $S0 = shift iter
    prefix1 = concat prefix, "<"
    concat prefix1, $S0
    concat prefix1, ">"
    $I0 = defined capt[$S0]
    unless $I0 goto subrules_1
    $P0 = capt[$S0]
    bsr dumper
    goto subrules_1

  dumper:
    $I0 = 0
    $I1 = elements $P0
    unless $I0 < $I1 goto dumper_1
    $P1 = getprop "isarray", $P0
    if $P1 goto dumper_2
    $P1 = $P0[-1]
    $P1."dump"(prefix1, b1, b2)
  dumper_1:
    ret
  dumper_2:
    unless $I0 < $I1 goto dumper_1
    $P1 = $P0[$I0]
    prefix2 = concat prefix1, b1
    $S0 = $I0
    concat prefix2, $S0
    concat prefix2, b2
    $P1."dump"(prefix2, b1, b2)
    inc $I0
    goto dumper_2
  end:
.end

=head1 AUTHOR

Patrick Michaud (pmichaud@pobox.com) is the author and maintainer.
Patches and suggestions should be sent to the Perl 6 compiler list
(perl6-compiler@perl.org).

=cut
