#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../../lib];

use Test::More 0.88;

my $r = eval "require Test::NoWarnings; 1";

use Regexp::Sudoku::Constants qw [:Constraints];

my @tokens = qw [ANTI_KNIGHT ANTI_KING];

foreach my $token (@tokens) {
    no strict 'refs';
    ok defined $$token, "\$$token set";
}

foreach my $token_1 (@tokens) {
    foreach my $token_2 (@tokens) {
        next if $token_1 eq $token_2;
        no strict 'refs';
        isnt $$token_1, $$token_2, "\$$token_1 != \$$token_2";
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
