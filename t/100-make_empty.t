#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Sudoku;

my $cell     = "R2C3";
my $SENTINEL = "\n";

my @tests = (
    ['', '',       '123456789',    "[1-9]*(?<$cell>[1-9])[1-9]*",
                   "Defaults"],
    [4,  '',       '1234',         "[1-4]*(?<$cell>[1-4])[1-4]*",
                   "Small size"],
    [12, '',       '123456789ABC', "[1-9A-C]*(?<$cell>[1-9A-C])[1-9A-C]*",
                   "Larger size"],
);

foreach my $test (@tests) {
    my ($size, $values, $exp_sub, $exp_pat, $name) = @$test;
    $exp_sub .= $SENTINEL;
    $exp_pat .= $SENTINEL;
    my %args = ();
       $args {size}   = $size   if $size;
       $args {values} = $values if $values;

    my $sudoku = Regexp::Sudoku:: -> new -> init (%args);

    my ($got_sub, $got_pat) = $sudoku -> make_empty ($cell);

    subtest $name => sub {
        is $got_sub, $exp_sub, "Subject";
        is $got_pat, $exp_pat, "Pattern";
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
