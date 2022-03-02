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

foreach my $name (qw [cross double triple]) {
    ok defined &{"Regexp::Sudoku::set_diagonal_${name}"},
                                 "set_diagonal_${name} defined";
}

ok defined &{"Regexp::Sudoku::set_argyle"},
                             "set_argyle defined";

foreach my $offset (1 .. 34) {
    ok defined &{"Regexp::Sudoku::set_diagonal_cross_${offset}"},
                                 "set_diagonal_cross_${offset} defined";
}



Test::NoWarnings::had_no_warnings () if $r;

done_testing;
