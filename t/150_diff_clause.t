#!/usr/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Sudoku;

my $size = 9;

my $cell1 = "R1C1";
my $cell2 = "R2C2";

foreach my $size (4, 6, 9, 12, 16) {
    subtest "Size = $size" => sub {
        my $sudoku  = Regexp::Sudoku:: -> new -> init (size => $size);

        my ($string, $pattern) = $sudoku -> make_diff_clause ($cell1, $cell2);

        my @values = map {$_ >= 10 ? chr (ord ('A') + $_ - 10) : $_} 1 .. $size;

        for my $v1 (@values) {
            for my $v2 (@values) {
                my $str       = "$v1;$v2;$string";
                my $pat       = "(?<$cell1>$v1);(?<$cell2>$v2);$pattern";
                my $got_match = $str =~ /^$pat$/;
                my $exp_match = $v1 ne $v2;
                ok !($got_match xor $exp_match),
                         "Cell '$v1' vs cell '$v2' " .
                              ($exp_match ? "match" : "no match");
            }
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;