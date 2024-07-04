#!/usr/bin/perl

use 5.038;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib];
use experimental qw [for_list];

use Test::More 0.88;
use Test::Exception;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Logic_Puzzles::Utils;
our $SENTINEL = $Regexp::Logic_Puzzles::Utils::SENTINEL;

my @tests = (
    0,         0, 0, "Basic clue on (0, 0)",
    1,         3, 5, "Clue elsewhere",
   "E",        4, 6, "Non-numeric clue",
   "\x{2735}", 7, 1, "Non-ASCII clue",
);

my @invalid = (
    "L", undef,     0, 0, "Undefined clue",
    "L", "",        1, 1, "Empty string as clue",
    "L", "01",      2, 2, "Clue too long",
    "C", "|",       3, 3, "Invalid character",
    "C", "\t",      4, 4, "White space clue",
);

foreach my ($clue, $row, $col, $name) (@tests) {
    my $cell = cell row => $row, col => $col;
    my $exp_sub = $clue             . $SENTINEL;
    my $exp_pat = "(?<$cell>$clue)" . $SENTINEL;
    my ($got_sub1, $got_pat1) =
                    statement_clue clue => $clue, row  => $row, col => $col;
    my ($got_sub2, $got_pat2) =
                    statement_clue clue => $clue, cell => $cell;

    subtest $name => sub {
        is $got_sub1, $exp_sub, "Subject by row/col";
        is $got_pat1, $exp_pat, "Pattern by row/col";
        is $got_sub2, $exp_sub, "Subject by cell";
        is $got_pat2, $exp_pat, "Pattern by cell";
    }
}


foreach my ($type, $clue, $row, $col, $name) (@invalid) {
    throws_ok {my $got = statement_clue clue => $clue, row => $row, col => $col}
              ($type eq "L" ? qr /'clue' must be a single character/
             : $type eq "C" ? qr /'clue' contains an invalid character/
             :                do {...}),
              "statement_clue () throws exception: $name";
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
