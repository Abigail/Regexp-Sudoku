#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

BEGIN {
    use_ok ('Regexp::Sudoku::Constants') or
        BAIL_OUT ("Loading of 'Regexp::Sudoku::Constants' failed");
}

ok defined $Regexp::Sudoku::Constants::VERSION, 
           "Regexp::Sudoku::Constants::VERSION is set";

done_testing;
