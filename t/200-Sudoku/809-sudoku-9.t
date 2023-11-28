#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib ../../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Logic_Puzzles::Sudoku::Test;

run_sudoku "sudoku_9_wikipedia";
run_sudoku "sudoku_9_hanabi";
# run_sudoku "sudoku_9_17-clue";   # Takes way too long.


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
