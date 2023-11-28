#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib ../../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Logic_Puzzles::Sudoku::Test;

SKIP: {
    skip "Takes too long", 3 unless $ENV {PERL_TEST_LONG} || $ENV {TEST_LONG};
    run_sudoku "german_whisper-1";
    run_sudoku "german_whisper-2";
    run_sudoku "german_whisper-3";
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
