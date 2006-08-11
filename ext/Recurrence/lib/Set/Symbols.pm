use v6-alpha;

role Set::Symbols;

=for LATER

# parsefail :(

sub ∅ {
    set();
}

=cut

# unicode intersection
multi sub *infix:<∩> (Set $one, Set $two) {
    $one.intersection($two);
}

# unicode union
multi sub *infix:<∪> (Set $one, Set $two) {
    $one.union($two);
}

# addition is union
multi sub *infix:<+> (Set $one, Set $two) {
    $one.union($two);
}

# subtraction is difference
multi sub *infix:<-> (Set $one, Set $two) {
    $one.difference($two);
}

# unicode difference operator
#  note the difference - ∖ vs \ (backslash)
multi sub *infix:<∖> (Set $one, Set $two) {
    $one.difference($two);
}

# multiplication is intersection
multi sub *infix:<*> (Set $one, Set $two) {
    $one.intersection($two);
}

# modulus is symmetric difference
multi sub *infix:<%> (Set $one, Set $two) {
    $one.symmetric_difference($two);
}

# XXX define multisubs
# comparison is subset/superset
#multi sub *infix:<==> (Set $one, Set $two) {
#    $one.equal($two);
#}
#multi sub *infix:<!=> (Set $one, Set $two) {
#    $one.not_equal($two);
#}
#multi sub *infix:<≠> (Set $one, Set $two) {
#    $one.not_equal($two);
#}

# what will be used for stringify?
method prefix:<~> ($self) returns Str {
    self.stringify
}

# removed - spans can be numerically compared
# multi sub *infix:«<» (Set $one, Set $two) {
#    $one.proper_subset($two);
#}
#multi sub *infix:«>» (Set $one, Set $two) {
#    $one.proper_superset($two);
#}
#multi sub *infix:«<=» (Set $one, Set $two) {
#    $one.subset($two);
#}
#multi sub *infix:«>=» (Set $one, Set $two) {
#    $one.superset($two);
#}

# look at all these great unicode operators!  :D
multi sub *infix:«⊂» (Set $one, Set $two) {
    $one.proper_subset($two);
}
multi sub *infix:«⊃» (Set $one, Set $two) {
    $one.proper_superset($two);
}
multi sub *infix:«⊆» (Set $one, Set $two) {
    $one.subset($two);
}
multi sub *infix:«⊇» (Set $one, Set $two) {
    $one.superset($two);
}
multi sub *infix:«⊄» (Set $one, Set $two) {
    !$one.proper_subset($two);
}
multi sub *infix:«⊅» (Set $one, Set $two) {
    !$one.proper_superset($two);
}
multi sub *infix:«⊈» (Set $one, Set $two) {
    !$one.subset($two);
}
multi sub *infix:«⊉» (Set $one, Set $two) {
    !$one.superset($two);
}
multi sub *infix:«⊊» (Set $one, Set $two) {
    $one.proper_subset($two);
}
multi sub *infix:«⊋» (Set $one, Set $two) {
    $one.proper_superset($two);
}

# several unicode operators for includes!
multi sub *infix:<∋> (Set $one, $member) returns Bool {
    $one.includes($member);
}
multi sub *infix:<∈> ($member, Set $set) returns Bool {
    $set.includes($member);
}
multi sub *infix:<∍> (Set $one, $member) returns Bool {
    $one.includes($member);
}
multi sub *infix:<∊> ($member, Set $set) returns Bool {
    $set.includes($member);
}
multi sub *infix:<∌> (Set $one, $member) returns Bool {
    !$one.includes($member);
}
multi sub *infix:<∉> ($member, Set $set) returns Bool {
    !$set.includes($member);
}

# these methods are for overloaded operations with non-sets
multi sub *infix:<+> (Set $one, *@args) {
    $one.union(@args);
}
multi sub *infix:<-> (Set $one, *@args) {
    $one.difference(@args);
}
multi sub *infix:<*> (Set $one, *@args) {
    $one.intersection(@args);
}
multi sub *infix:<%> (Set $one, *@args) {
    $one.symmetric_difference(@args);
}
multi sub *infix:<~~> (Set $one, $member) returns Bool {
    $one.includes($member);
}
# XXX -- IIRC, there's a "is commutative" or such, so duplicating shouldn't be
# necessary.
multi sub *infix:<~~> ($member, Set $one) returns Bool {
    $one.includes($member);
}

# Subs to make operations on arrays
# E.g. [1,2,3] +# [2,5]  ==>  [1,2,3,5]
# (Similar to Ruby)
## multi sub *infix:<+#> (@a, @b) returns Array { set(@a).union(@b).members }
## multi sub *infix:<-#> (@a, @b) returns Array { set(@a).difference(@b).members }
## multi sub *infix:<*#> (@a, @b) returns Array { set(@a).intersection(@b).members }
## multi sub *infix:<%#> (@a, $b) returns Array { set(@a).symmetric_difference(@b).members }

=head1 NAME

Set::Symbols - A Role of unicode symbols for "set" operations

=head1 AUTHORS

Organized by Flavio S. Glock; the unicode methods were extracted from
Set.pm, written by Sam "mugwump" Vilain

=cut
