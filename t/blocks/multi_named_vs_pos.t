use v6;
use Test;
plan 26;

# check the subroutine with the closest matching signature is called
#
#L<S06/"Longname parameters">
#L<S12/"Multisubs and Multimethods">

multi earth (:$me)               {"me $me"};
multi earth (:$him)              {"him $him"};
multi earth (:$me, :$him)        {"me $me him $him"};
multi earth (:$me, :$him, :$her) {"me $me him $him her $her"};
multi earth ($me)                {"pos $me"};
multi earth ($me, :$you)         {"pos $me you $you"};
multi earth ($me, :$her)         {"pos $me her $her"};
multi earth ($me, $you)          {"pos $me pos $you"};
multi earth ($me, $you, :$her)   {"pos $me pos $you her $her"};

is( earth(me => 1),                     'me 1',             'named me');
is( earth(him => 2),                    'him 2',            'named you');
is( earth(me => 1, him => 2),           'me 1 him 2',       'named me, named him');
is( earth(him => 2, me => 1),           'me 1 him 2',       'named him, named me');
is( earth(me => 1, him => 2, her => 3), 'me 1 him 2 her 3', 'named me named him named her');
is( earth(him => 2, me => 1, her => 3), 'me 1 him 2 her 3', 'named him named me named her');
is( earth(her => 3, me => 1, him => 2), 'me 1 him 2 her 3', 'named her named me named him');
is( earth(her => 3, him => 2, me => 1), 'me 1 him 2 her 3', 'named her named him named me');

is( earth('a'),                'pos a',             'pos');
is( earth('b', you => 4),      'pos b you 4',       'pos, named you');
is( earth('c', her => 3),      'pos c her 3',       'pos, named her');
is( earth('d', 'e'),           'pos d pos e',       'pos, pos');
is( earth('f', 'g', her => 3), 'pos f pos g her 3', 'pos, pos, named');


# ensure we get the same results when the subroutines are 
# defined in reverse order
#

multi wind ($me, $you, :$her)   {"pos $me pos $you her $her"};
multi wind ($me, $you)          {"pos $me pos $you"};
multi wind ($me, :$her)         {"pos $me her $her"};
multi wind ($me, :$you)         {"pos $me you $you"};
multi wind ($me)                {"pos $me"};
multi wind (:$me, :$him, :$her) {"me $me him $him her $her"};
multi wind (:$me, :$him)        {"me $me him $him"};
multi wind (:$him)              {"him $him"};
multi wind (:$me)               {"me $me"};

is( wind(me => 1),                     'me 1',             'named me');
is( wind(him => 2),                    'him 2',            'named you');
is( wind(me => 1, him => 2),           'me 1 him 2',       'named me, named him');
is( wind(him => 2, me => 1),           'me 1 him 2',       'named him, named me');
is( wind(me => 1, him => 2, her => 3), 'me 1 him 2 her 3', 'named me named him named her');
is( wind(him => 2, me => 1, her => 3), 'me 1 him 2 her 3', 'named him named me named her');
is( wind(her => 3, me => 1, him => 2), 'me 1 him 2 her 3', 'named her named me named him');
is( wind(her => 3, him => 2, me => 1), 'me 1 him 2 her 3', 'named her named him named me');

is( wind('a'),                'pos a',             'pos');
is( wind('b', you => 4),      'pos b you 4',       'pos, named you');
is( wind('c', her => 3),      'pos c her 3',       'pos, named her');
is( wind('d', 'e'),           'pos d pos e',       'pos, pos');
is( wind('f', 'g', her => 3), 'pos f pos g her 3', 'pos, pos, named');

