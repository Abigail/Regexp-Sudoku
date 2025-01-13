#!/usr/bin/perl

use 5.038;

use strict;
use warnings;
no  warnings 'syntax';

use lib qw [lib ../lib ../../lib];
use experimental qw [for_list];

use Test::More 0.88;
use Test::Exception;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Logic_Puzzles::Utils;
our $SENTINEL = $Regexp::Logic_Puzzles::Utils::SENTINEL;

my $STAR = chr 0x2735;

my @tests = (
    simple =>  1,  1, "A",
    big    => 17, 23, $STAR,
);


foreach my ($name, $row, $col, $optional) (@tests) {
    my $cell    = "R${row}C${col}";
    my $exp_sub = $optional                        . $SENTINEL;
    my $exp_pat = "(?<$cell>$optional?)$optional?" . $SENTINEL;
    my ($got_sub1, $got_pat1) =
                    statement_select optional => $optional,
                                     row      => $row, col => $col;
    my ($got_sub2, $got_pat2) =
                    statement_select optional => $optional, cell => $cell;

    subtest $name => sub {
        is $got_sub1, $exp_sub, "Subject by row/col";
        is $got_pat1, $exp_pat, "Pattern by row/col";
        is $got_sub2, $exp_sub, "Subject by cell";
        is $got_pat2, $exp_pat, "Pattern by cell";
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
