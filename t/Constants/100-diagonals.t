#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../../lib];

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Sudoku::Constants qw [:Diagonals];

my      @tokens =  map {("SUB$_", "SUPER$_")} "", 2 .. 35;
push    @tokens => map {"MINOR_$_"} @tokens;
push    @tokens => "DEFAULT";
unshift @tokens => "MAIN", "MINOR";

foreach my $token (@tokens) {
    no strict 'refs';
    ok defined $$token, "\$$token set";
}

is $::DEFAULT, $::MAIN |. $::MINOR, '$DEFAULT combines $MAIN and $MINOR';

done_testing;
