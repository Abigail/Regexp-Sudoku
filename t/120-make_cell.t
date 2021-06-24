#!/usr/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Sudoku;

my $SENTINEL = "\n";

my $test = << '--';  # Does not have to have a solution
5  3  0  0  7  0  0  0  0
6  0  0  1  9  5  0  0  0
0  9  8  0  0  0  0  6  0
8  0  0  0  6  0  0  0  3
4  0  0  8  0  3  0  0  1
7  0  0  0  2  0  0  0  6
0  6  0  0  0  0  2  8  0
0  0  0  4  1  9  0  0  5
0  0  0  0  8  0  0  7  9
--

my $sudoku = Regexp::Sudoku:: -> new -> init (size  => 9,
                                              clues => $test);

my @rows = split /\n/ => $test;
for my $r (keys @rows) {
    my @row = split /\s+/ => $rows [$r];
    for my $c (keys @row) {
        my $value   = $row [$c];
        my $cell    = "R" . ($r + 1) . "C" . ($c + 1);
        my ($got_str, $got_pat) = $sudoku -> make_cell ($cell);
        my ($exp_str, $exp_pat, $name);

        if ($value) {
            $exp_str = "$value"                      . $SENTINEL;
            $exp_pat = "(?<$cell>$value)"            . $SENTINEL;
            $name    = "Cell $cell (clue)";
        }
        else {
            $exp_str = "123456789"                   . $SENTINEL;
            $exp_pat = "[1-9]*(?<$cell>[1-9])[1-9]*" . $SENTINEL;
            $name    = "Cell $cell (empty)";
        }
        subtest $name => sub {
            is $got_str, $exp_str, "String";
            is $got_pat, $exp_pat, "Pattern";
        }
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
