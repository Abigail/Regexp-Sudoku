#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Sudoku::Constants qw [:Diagonals];

ok defined $::MAIN,    '$MAIN set';
ok defined $::MINOR,   '$MINOR set';
ok defined $::DEFAULT, '$DEFAULT set';

is $::DEFAULT, $::MAIN | $::MINOR, '$DEFAULT combines $MAIN and $MINOR';

done_testing;
