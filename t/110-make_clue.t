#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Sudoku;

my $SENTINEL = "\n";

my $sudoku = Regexp::Sudoku:: -> new -> init ();

for my $clue (1 .. 9) {
    my $cell = "R${clue}C${clue}";
    my ($got_str, $got_pat) = $sudoku -> make_clue ($cell, $clue);
    subtest "Clue $clue" => sub {
        is $got_str, "$clue$SENTINEL",           "String";
        is $got_pat, "(?<$cell>$clue)$SENTINEL", "Pattern";
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
