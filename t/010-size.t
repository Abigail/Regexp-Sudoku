#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Sudoku;


my @tests = (
    [{},            9, "Handle default size"],
    [{size =>  4},  4, "Small size"],
    [{size =>  9},  9, "Normal size"],
    [{size => 16}, 16, "Large size"],
    [{size => 42}, 35, "Over sized"],
);

foreach my $test (@tests) {
    my ($args, $exp, $name) = @$test;

    my $sudoku = Regexp::Sudoku:: -> new -> init (%$args);
    is $sudoku -> size, $exp, $name;
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
