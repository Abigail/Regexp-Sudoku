#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';

use lib qw [lib ../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Sudoku;
use Regexp::Sudoku::Constants qw [:Diagonals];


sub exp_cells ($type, $size) {
    my @exp_cells;
    if ($type == $MAIN) {
        @exp_cells = map {sprintf "R%dC%d", $_, $_} 1 .. $size;
    }
    elsif ($type == $MINOR) {
        @exp_cells = map {sprintf "R%dC%d", $size - $_ + 1, $_} 1 .. $size;
    }
    
    return sort @exp_cells;
}

my %type2name = (
    $MAIN     =>  "DM",
    $MINOR    =>  "Dm",
);

sub test ($name, $type, $size = 9) {
    my $sudoku = Regexp::Sudoku:: -> new -> init (size      => $size,
                                                  diagonals => $type);

    subtest $name, sub {
        foreach my $target_type ($MAIN, $MINOR) {
            if ($type & $target_type) {
                my $name = $type2name {$target_type};
                my @exp_cells = exp_cells $target_type, $size;
                my %exp_cells = map {$_ => 1} @exp_cells;
                my @got_cells = sort $sudoku -> house2cells ($name);
                is_deeply \@got_cells, \@exp_cells, "Cells in house '$name'";

                for my $r (1 .. $size) {
                    for my $c (1 .. $size) {
                        my $cell = "R${r}C${c}";
                        my %got_houses = map {$_ => 1}
                                              $sudoku -> cell2houses ($cell);
                        ok !($exp_cells {$cell} xor $got_houses {$name}),
                             $exp_cells {$cell} ?  "Cell $cell is in $name"
                                                :  "Cell $cell is not in $name";
                    }
                }
            }
        }
    }
}

test "Main diagonal",         $MAIN;
test "Minor diagonal",        $MINOR;
test "Both diagonals",        $DEFAULT;
test "Both diagonals (6x6)",  $DEFAULT, 6;
test "Main diagonal (16x16)", $MAIN,   16;

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
