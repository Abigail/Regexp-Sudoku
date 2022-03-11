#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

use lib qw [lib ../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Sudoku;
my $SENTINEL = "\n";

my $sudoku = Regexp::Sudoku:: -> new -> init;

my $cell1 = "R1C1";
my $cell2 = "R1C2";
my $cell3 = "R2C2";

my ($sub_r, $pat_r) = $sudoku -> make_battenburg_statement ($cell1, $cell2);
my ($sub_d, $pat_d) = $sudoku -> make_battenburg_statement ($cell1, $cell3);

foreach my $val1 (1 .. 9) {
    foreach my $val2 (1 .. 9) {
        my $exp_r = ($val1 % 2) != ($val2 % 2);
        my $exp_d = ($val1 % 2) == ($val2 % 2);
        my $s_r   = "$val1$SENTINEL$val2$SENTINEL$sub_r";
        my $p_r   = "(?<$cell1>$val1)$SENTINEL(?<$cell2>$val2)$SENTINEL$pat_r";
        my $s_d   = "$val1$SENTINEL$val2$SENTINEL$sub_d";
        my $p_d   = "(?<$cell1>$val1)$SENTINEL(?<$cell3>$val2)$SENTINEL$pat_d";
        ok !($exp_r xor $s_r =~ /^$p_r$/), 
             $exp_r ? "Row: Match different parity of '$val1' and '$val2'"
                    : "Row: Do not match same parity of '$val1' and '$val2'";
        ok !($exp_d xor $s_d =~ /^$p_d$/), 
             $exp_d ? "Diagonal: Match same parity of '$val1' and '$val2'"
                    : "Diagonal: Do not match different parity of " .
                               "'$val1' and '$val2'";
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
