use v6-pugs;

use Test;

plan 1;

my $dollar_underscore;
{
    $_ = 42;
    {
        $dollar_underscore = $_;
    }
}

is $dollar_underscore, 42, 'bare blocks containing $_ work correctly';
