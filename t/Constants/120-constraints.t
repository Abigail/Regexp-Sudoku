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

foreach my $token (@tokens, "ALL_CONSTRAINTS") {
    no strict 'refs';
    ok defined $$token, "\$$token set";
}

for (my $i = 0; $i < @tokens; $i ++) {
    for (my $j = $i + 1; $j < @tokens; $j ++) {
        no strict 'refs';
        ok !(${$tokens [$i]} & ${$tokens [$j]}),
             sprintf '$%s and $%s share no bits', $tokens [$i], $tokens [$j];
    }
}

foreach my $token (@tokens) {
    no strict 'refs';
    is $$token, $$token & $::ALL_CONSTRAINTS,
      "\$$token is contained in \$ALL_CONSTRAINTS";
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
