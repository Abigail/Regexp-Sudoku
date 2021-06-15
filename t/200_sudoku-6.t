#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Sudoku qw [sudoku run_sudoku];

#
# Clues are prepended by a .
#

my @tests = (
    {
        sudoku => <<~ '--',
             4  3  2  6  5 .1
             1 .5 .6  4  2  3
             2 .4 .5  1  3 .6
             6  1  3  2 .4 .5
             3  6  4 .5  1  2
            .5  2 .1 .3  6  4
            --
        name   => "Gridlers",
    },
    {
        # https://www.funwithpuzzles.com/2013/01
        #        /quick-word-search-online-google-gadget.html
        sudoku => <<~ '--',
            .5 .4  3  1  2  6
            .6  1  2  3  4  5
            .4  2  5 .6  1  3
             3  6 .1  2  5 .4
             2  3  4  5  6 .1
             1  5  6  4 .3 .2
            --
        name   => "Fun with puzzles",
    },
);

foreach my $test (@tests) {
    my $name  = $$test {name};
    my $sudoku = $$test {sudoku};

    my ($string, $pattern) = sudoku (clues => $sudoku =~ s/ [1-9]/0/rg
                                                      =~ s/\.([1-9])/$1/rg,
                                     size  => 6);

    my $got = run_sudoku ($string, $pattern, 6);
    is $got, $sudoku =~ s/[ .]([1-6])/$1/gr, $name;
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
