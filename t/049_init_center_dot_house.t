#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Sudoku;

my $size = 9;

my $sudoku = Regexp::Sudoku:: -> new -> init (center_dot => 1);

my @exp_cells = sort map {"R" . $$_ [0] . "C" . $$_ [1]} [2, 2], [2, 5], [2, 8],
                                                         [5, 2], [5, 5], [5, 8],
                                                         [8, 2], [8, 5], [8, 8];
my %exp_cells = map {$_ => 1} @exp_cells;
my @got_cells = sort $sudoku -> house2cells ("CD");

is_deeply \@got_cells, \@exp_cells, "Center dot cells";

for my $r (1 .. $size) {
    for my $c (1 .. $size) {
        my $cell = "R${r}C${c}";
        my %got_houses = map {$_ => 1} $sudoku -> cell2houses ($cell);
        ok !($exp_cells {$cell} xor $got_houses {"CD"}),
             $exp_cells {$cell} ?  "Cell $cell is a center dot"
                                :  "Cell $cell is not a center dot";
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
