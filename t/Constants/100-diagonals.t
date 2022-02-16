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
    CROSS         CROSS0
    DOUBLE        CROSS1
];

my %sets = (
    TRIPLE    => [qw [CROSS CROSS1]],
    ARGYLE    => [qw [CROSS1 CROSS4]],
    CROSS0    => [qw [SUB0 MINOR_SUB0]],
);
foreach my $i (1 .. 35) {
    $sets {"CROSS$i"} = ["SUB$i", "SUPER$i", "MINOR_SUB$i", "MINOR_SUPER$i"];
}

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

foreach my $name (sort keys %sets) {
    my $elements = $sets {$name};
    my $test_name = "\$$name combines " . join ", " => map {"\$$_"} @$elements;
       $test_name =~ s/.*\K, / and /;
    no strict 'refs';
    my $result = ${shift @$elements};
    while (@$elements) {
        $result |.= ${shift @$elements};
    }
    is $$name, $result, $test_name;
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
