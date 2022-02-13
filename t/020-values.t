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
    [{},           "123456789",                            "1-9",
                   "Default values"],
    [{size =>  4}, "1234",                                 "1-4",
                   "Small size"],
    [{size =>  9}, "123456789",                            "1-9",
                   "Default size"],
    [{size => 16}, "123456789ABCDEFG",                     "1-9A-G",
                   "Large size"],
    [{size => 35}, "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",  "1-9A-Z",
                   "Max size"],
    [{size => 42}, "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",  "1-9A-Z",
                   "Over sized"],
);


foreach my $test (@tests) {
    my ($args, $exp_v, $exp_vr, $name) = @$test;

    my @exp_v = split // => $exp_v;

    my $sudoku = Regexp::Sudoku:: -> new -> init (%$args);
    subtest "$name (values)" => sub {
        is         $sudoku -> values,   $exp_v, "scalar context";
        is_deeply [$sudoku -> values], \@exp_v, "list context";
    };
    is $sudoku -> values_range, $exp_vr, "$name (range)";
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
