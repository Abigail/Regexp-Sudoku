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
use Regexp::Logic_Puzzles::Sudoku::Constants;

my $sudoku  = Regexp::Logic_Puzzles::Sudoku:: -> new -> init;

my $cell1   = "R3C4";
my $cell2   = "R3C5";

my $exp_sub = "1617181927282938394961717281828391929394" . $SENTINEL;
my $exp_pat = "(?:[1-9][1-9])*\\g{$cell1}\\g{$cell2}(?:[1-9][1-9])*"
                                                         . $SENTINEL;

my ($got_sub, $got_pat) = $sudoku ->
                           make_german_whisper_statement ($cell1, $cell2);

is $got_sub, $exp_sub, "Expected sub subject";
is $got_pat, $exp_pat, "Expected sub pattern";

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
