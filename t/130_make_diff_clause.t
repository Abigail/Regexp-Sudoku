#!/usr/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Sudoku;

my $SENTINEL = "\n";

my $cell1 = "R2C3";
my $cell2 = "R3C1";

my %range = (4  =>  '1-4',
             9  =>  '1-9',
            16  =>  '1-9A-G');

for my $size (4, 9, 16) {
    my $sudoku  = Regexp::Sudoku:: -> new -> init (size => $size);
    my $exp_str = "";
    my @values  = map {$_ >= 10 ? chr (ord ('A') + $_ - 10) : $_} 1 .. $size;
    my $range   = $range {$size};

    foreach my $d (@values) {
        $exp_str .= $d;
        $exp_str .= join "" => grep {$_ ne $d} @values;
        $exp_str .= ",";
    }
    $exp_str .= $SENTINEL;

    my $exp_pat = "(?:[$range]{$size},)*"                      .
                  "\\g{$cell1}[$range]*\\g{$cell2}[$range]*,"  .
                  "(?:[$range]{$size},)*" . $SENTINEL;

    my ($got_str, $got_pat) = $sudoku -> make_diff_clause ($cell1, $cell2);

    subtest "Size: $size", sub {
        is $got_str, $exp_str, "String";
        is $got_pat, $exp_pat, "Pattern";
    };
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;