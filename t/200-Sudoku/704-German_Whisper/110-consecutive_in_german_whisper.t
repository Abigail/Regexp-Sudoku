#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

use lib qw [lib ../lib ../../lib ../../../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Logic_Puzzles::Sudoku;

my $sudoku = Regexp::Logic_Puzzles::Sudoku:: -> new -> init
             -> set_german_whisper (qw [R2C1 R2C2 R2C3 R2C4 R2C5
                                        R2C6 R2C7 R2C8 R2C9])
             -> set_german_whisper (qw [R8C1 R8C2 R8C3 R8C4 R8C5
                                        R8C6 R8C7 R8C8 R8C9])
             -> set_german_whisper (qw [R1C2 R2C2 R3C2 R4C2 R5C2
                                        R6C2 R7C2 R8C2 R9C2])
             -> set_german_whisper (qw [R1C8 R2C8 R3C8 R4C8 R5C8
                                        R6C8 R7C8 R8C8 R9C8]);

my @cells = map {my $r = $_; map {"R${r}C${_}"} 1 .. 9} 1 .. 9;

for (my $i = 0; $i < @cells; $i ++) {
    my $cell1 = $cells [$i];
    my ($r1, $c1) = $cell1 =~ /R([1-9]+)C([1-9]+)/;
    for (my $j = $i + 1; $j < @cells; $j ++) {
        my $cell2 = $cells [$j];
        my ($r2, $c2) = $cell2 =~ /R([1-9]+)C([1-9]+)/;
        my $exp1 = ($r1 == $r2 && ($r1 == 2 || $r1 == 8)
                               && abs ($c1 - $c2)  == 1) || 0;
        my $exp2 = ($c1 == $c2 && ($c1 == 2 || $c1 == 8)
                               && abs ($r1 - $r2)  == 1) || 0;
        my $exp = $exp1 || $exp2;

        my $got = $sudoku -> consecutive_in_german_whisper ($cell1, $cell2);

        is $got || 0, $exp || 0,
          ($exp ? " " : "!") . "consecutive_in_german_whisper ($cell1, $cell2)";

    }
}



Test::NoWarnings::had_no_warnings () if $r;

done_testing;
