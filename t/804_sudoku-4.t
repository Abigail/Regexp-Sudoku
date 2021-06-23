#!/usr/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib t .];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Test;

run_sudoku "sudokus/sudoku_4_25764";

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
