#!/usr/bin/perl

use 5.038;

use strict;
use warnings;
no  warnings 'syntax';

BEGIN {
    #
    # Make sure Test2::Formatter::TAP picks this up.
    #
    binmode STDOUT, ":utf8";
    binmode STDERR, ":utf8";
}

use lib qw [lib ../lib];
use experimental qw [for_list];

use Test::More 0.88;
use charnames ":full";

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Logic_Puzzles::Utils;

my @ok = ("A" .. "Z", "a" .. "z", "0" .. "9", "_",   # Allowed ASCII
          "\N{EIGHT POINTED PINWHEEL STAR}",
          "\N{ELECTRIC LIGHT BULB}");

my @fail = (
    undef,                                 "Character not defined",
    "",                                    "No character in string",
    "AB",                                  "More than one character",
    " ",                                   "Space",
    "|",                                   "ASCII Punctuation",
    "\n",                                  "Newline",
    "\N{COMBINING REVERSED COMMA ABOVE}",  "Combining character",
);

foreach my $ch (@ok) {
    ok char_is_ok ($ch), "'$ch' is valid";
}

foreach my ($ch, $reason) (@fail) {
    my $ch_cl = defined $ch ? $ch =~ s/\n/\\n/r : "UNDEF";
    ok !char_is_ok ($ch), "'$ch_cl' not valid: $reason";
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
