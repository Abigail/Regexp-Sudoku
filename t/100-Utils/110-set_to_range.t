#!/usr/bin/perl

use 5.038;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib];
use experimental qw [for_list];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Logic_Puzzles::Utils;

my @tests = (
    [1]                                       => "1",     "Single character",
    [1, 2]                                    => "[12]",  "Two characters",
    [1, 3, 4]                                 => "[134]", "Multiple characters",
    [1, 2, 3]                                 => "[1-3]",
                                                 "Single three character range",
    [1 .. 6]                                  => "[1-6]",
                                                 "Single, longer, range",
    ["A" .. "D"]                              => "[A-D]", "Letter range",
    ["A", "E" .. "I", "M"]                    => "[AE-IM]",
                                                 "Range and singletons",
    [1, 4 .. 7, 9, "B", "D" .. "L"]           => "[14-79BD-L]",
                                                 "Multiple ranges",
    [4 .. 7, reverse ("D" .. "L"), 9, "B", 1] => "[14-79BD-L]",
                                                 "Sort the set",
    [1 .. 9]                                  => "[1-9]", "Standard Sudoku",
    [0, 1]                                    => "[01]", "Binairo",
);

foreach my ($set, $exp, $name) (@tests) {
    my $got = set_to_character_class @$set;
    is $got, $exp, $name;
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
