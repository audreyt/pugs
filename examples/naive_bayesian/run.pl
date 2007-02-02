#!/usr/bin/perl

my $test_file = @*ARGS[0] || 'test';

print(('-' x 80), "\n");
print "Testing perl5 naive bayesian script with $test_file\n";
print(('-' x 80), "\n");

if ("words.db-p5.pl"~~:!e) {
    system("perl naive_bayesian-p5.pl add apples apples");
    system("perl naive_bayesian-p5.pl add oranges oranges");
    system("perl naive_bayesian-p5.pl add grapes grapes");
}
system("perl naive_bayesian-p5.pl classify $test_file");

print(('-' x 80), "\n");
print "Testing perl6 naive bayesian script with $test_file\n";
print(('-' x 80), "\n");

if ("words.db.pl"~~:!e) {
    system("pugs naive_bayesian.pl add apples apples");
    system("pugs naive_bayesian.pl add oranges oranges");
    system("pugs naive_bayesian.pl add grapes grapes");
}
system("pugs naive_bayesian.pl classify $test_file");
