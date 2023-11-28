#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib ../../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Logic_Puzzles::Sudoku::Test;

run_sudoku "renban-1";
run_sudoku "renban-2";
SKIP: {
    skip "Takes too long", 1 unless $ENV {PERL_TEST_LONG} || $ENV {TEST_LONG};
    run_sudoku "renban-3";
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
