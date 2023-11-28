#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib];

use Test::More 0.88;
use Test::Exception;

our $r = eval "require Test::NoWarnings; 1";

BEGIN {
    use_ok ('Regexp::Logic_Puzzles::Sudoku') or
        BAIL_OUT ("Loading of 'Regexp::Logic_Puzzles::Sudoku' failed");
}

ok defined $Regexp::Logic_Puzzles::Sudoku::VERSION, "VERSION is set";

my $sudoku = Regexp::Logic_Puzzles::Sudoku:: -> new;

isa_ok $sudoku, 'Regexp::Logic_Puzzles::Sudoku';

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
