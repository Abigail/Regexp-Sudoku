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

foreach my $r (1 .. 9) {
    foreach my $c (1 .. 9) {
        my $exp = "R${r}C${c}";

        my $got = cell (row => $r, col => $c);
        is $got, $exp,  "cell (row => $r, col => c)  = '$exp'";

        my $got2 = cell (cell => $exp);
        is $got2, $exp, "cell (cell => '$exp')      = '$exp'";

        my $got3 = cell_name ($r, $c);
        is $got3, $exp, "cell_name ($r, $c)           = '$exp'";

        my ($got_r, $got_c) = cell_row_column ($exp);
        ok $got_r == $r && $got_c == $c,
                        "cell_row_column ('$exp')   = ($r, $c)";
    }
}

{
    my $exp = "R1C3";
    my $got = cell (cell => $exp, row => 4, col => 5);
    is $got, $exp, "'cell' takes priority";
}

{
    my $exp = "R0C0";
    my $got = cell;
    is $got, $exp, "cell () with no arguments returns '$exp'";
}

my @invalid = (
    "Wrong cell format" => {cell => 'C3R2'},
    "Lowercase usage"   => {cell => 'r3R2'},
    "Not an integer"    => {cell => "R2C2.3"},
    "Row is negative"   => {row  => -1, col =>  3},
    "Col is negative"   => {row  =>  1, col => -3},
);

foreach my ($name, $args) (@invalid) {
    throws_ok {my $got = cell %$args}
               qr /No acceptable cell name can be formed/,
              "cell () throws exception: $name";
}



Test::NoWarnings::had_no_warnings () if $r;

done_testing;
