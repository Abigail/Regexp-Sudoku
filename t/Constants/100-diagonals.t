#!/usr/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../../lib];

use Test::More 0.88;

my $r = eval "require Test::NoWarnings; 1";

use Regexp::Sudoku::Constants qw [:Diagonals];

my %aliases = qw [
    MAIN          SUPER0
    MINOR         MINOR_SUPER0
    SUB0          SUPER0
    MINOR_SUB0    MINOR_SUPER0
    SUPER         SUPER1
    SUB           SUB1
    MINOR_SUPER   MINOR_SUPER1
    MINOR_SUB     MINOR_SUB1
];

my      @tokens =  map {("SUB$_", "SUPER$_")} "", 0 .. 35;
push    @tokens => map {"MINOR_$_"} @tokens;
#
# Aliases
#
push    @tokens => qw [MAIN MINOR SUPER SUB MINOR_SUPER MINOR_SUB];
#
# Sets
#
push    @tokens => qw [CROSS DOUBLE TRIPLE ARGYLE];

foreach my $token (@tokens) {
    no strict 'refs';
    ok defined $$token, "\$$token set";
}

print <<"--";
#
# Checking aliases
#
--

foreach my $alias (sort keys %aliases) {
    my $source = $aliases {$alias};
    no strict 'refs';
    is $$alias, $$source, "\$$alias is an alias for \$$source";
}


print <<"--";
#
# Checking sets
#
--

is $::CROSS,   $::MAIN |. $::MINOR, '$CROSS combines $MAIN and $MINOR';
is $::DOUBLE,  $::SUPER |. $::SUB |. $::MINOR_SUPER |. $::MINOR_SUB,
               '$DOUBLE combines $SUPER, $SUB, $MINOR_SUPER, $MINOR_SUB';
is $::TRIPLE,  $::SUPER |. $::SUB |. $::MINOR_SUPER |. $::MINOR_SUB |.
               $::MAIN  |. $::MINOR,
               '$TRIPLE combines $MAIN, $MINOR, $SUPER, $SUB, ' .
                                '$MINOR_SUPER, $MINOR_SUB';
is $::ARGYLE,  $::SUPER  |. $::SUB  |. $::MINOR_SUPER  |. $::MINOR_SUB |.
               $::SUPER4 |. $::SUB4 |. $::MINOR_SUPER4 |. $::MINOR_SUB4,
               '$ARGYLE combines $SUPER, $SUB, $MINOR_SUPER, $MINOR_SUB, ' .
                              '$SUPER4, $SUB4, $MINOR_SUPER4, $MINOR_SUB4';
                            

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
