#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib ../../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Logic_Puzzles::Sudoku::Test;

run_sudoku "nrc";
run_sudoku "nrc-2018-12-31";


Test::NoWarnings::had_no_warnings () if $r;

done_testing;