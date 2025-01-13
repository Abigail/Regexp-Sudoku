#!/usr/bin/perl

use 5.038;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib ../../lib];
use experimental qw [for_list];

use Test::More 0.88;
use Test::Exception;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Logic_Puzzles::Utils;
our $SENTINEL = $Regexp::Logic_Puzzles::Utils::SENTINEL;


my @tests = (
    binaro     =>  1,  1, [0, 1],               "01",
    sudoku     =>  3,  4, [1 .. 9],             "1-9",
   "sudoku-16" =>  7, 12, [1 .. 9, "A" .. "F"], "1-9A-F",
);


foreach my ($name, $row, $col, $set, $range) (@tests) {
    my $cell    = "R${row}C${col}";
    my $exp_sub = join ("", @$set)                       . $SENTINEL;
    my $exp_pat = "[$range]*(?<$cell>[$range])[$range]*" . $SENTINEL;
    my ($got_sub1, $got_pat1) =
                    statement_select set => $set,
                                     row => $row, col => $col;
    my ($got_sub2, $got_pat2) =
                    statement_select set => $set, cell => $cell;

    subtest $name => sub {
        is $got_sub1, $exp_sub, "Subject by row/col";
        is $got_pat1, $exp_pat, "Pattern by row/col";
        is $got_sub2, $exp_sub, "Subject by cell";
        is $got_pat2, $exp_pat, "Pattern by cell";
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
