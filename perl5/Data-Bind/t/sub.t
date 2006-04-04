#!/usr/bin/perl -w
use strict;
use Test::More tests => 7;
use Data::Bind;
use Data::Dumper;
use Test::Exception;

# from S06/Named parameters
# sub db_formalize($title, :$case, :$justify) {...}
my $db_formalize_sig = Data::Bind->sig
    ({ var => '$title' },
     { var => '$subtitle' },
     { var => '$case', named_only => 1 },
     { var => '$justify', named_only => 1 });

#warn Dumper($db_formalize_sig);

sub db_formalize {
  my ($title, $subtitle, $case, $justify);
  $db_formalize_sig->bind({ positional => $_[0], named => $_[1] });
  no warnings 'uninitialized';
  return join(':', $title, $case, $justify);
}

is(db_formalize([\'this is title', \'subtitle'], { case => \'blah'}),
   'this is title:blah:');

is(db_formalize([\'this is title', \'subtitle'], { justify => \'blah'}),
   'this is title::blah');

throws_ok {
    db_formalize([\'this is title'], { justify => \'blah'}),
} qr/subtitle is required/;

$db_formalize_sig = Data::Bind->sig
    ({ var => '$title' },
     { var => '$subtitle', optional => 1 },
     { var => '$case', named_only => 1 },
     { var => '$justify', named_only => 1, required => 1});

is(db_formalize([\'this is title'], { justify => \'blah'}),
   'this is title::blah');

is(db_formalize([], { title => \'title by name', justify => \'blah'}),
   'title by name::blah');

throws_ok {
    db_formalize([\'this is title'], { case => \'blah'}),
} qr/justify is required/;

TODO: {
    local $TODO = 'do something with extra named arguments.';
throws_ok {
    db_formalize([\'this is title'], { unknown => \'blah'}),
} qr/extra/;

}

1;
