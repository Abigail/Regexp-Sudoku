package Regexp::Logic_Puzzles::Utils;

################################################################################
#
# This module contains utility functions shared by various logical puzzles
#
# All test files are in t/100-Utils
#
################################################################################

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

our $VERSION = '2023112701';

use Exporter ();

our @ISA      = qw [Exporter];
our @EXPORT   = qw [cell cell_name cell_row_column set_to_character_class
                    char_is_ok
                    statement_clue];

our $SENTINEL = "\n";
my  $ALLOWED  = "[A-Za-z0-9_\\N{U+A1}-\\N{U+10FFFF}]";


################################################################################
#
# sub cell (%args) 
#
# Given a set of arguments, return a cell name, in a "R<number>C<number>"
# format.
#
#    IN:  - cell:     If given, use this name.
#         - row:      The row number of the cell; used if cell is not given.
#                     Defaults to 0.
#         - col:      The column number of the cell; used if cell is not given.
#                     Defaults to 0.
#         - column:   Alias for 'col'; 'col' takes priority.
#
#   OUT:  - Cell name.
#
# EXCEP:  "No acceptable cell name can be formed" if no cell name can be
#          formed.
#
# TESTS: 100-cell.t
#
################################################################################

sub cell (%args) {
    my $cell = $args {cell} //
                     "R" . ($args {row}                   || 0) .
                     "C" . ($args {col} || $args {column} || 0);

    die "No acceptable cell name can be formed" if $cell !~ /^R[0-9]+C[0-9]+$/;
    return $cell;
}


################################################################################
#
# sub cell_name ($row, $col)
#
# Wrapper around cell. Mostly here for backwards compatability.
#
#    IN:  - $row:  The row the cell is in.
#         - $col:  The column the cell is in.
#
#   OUT:  Cell name of the form "R<number>C<number>
#
################################################################################

sub cell_name ($row, $col) {
    cell row => $row, col => $col
}

################################################################################
#
# sub cell_row_column ($cell_name)
#
# Given the name of a cell, return its row and column.
# 
# TESTS: 100-cell.t
#
################################################################################

sub cell_row_column ($name) {
    $name =~ /R([0-9]+)C([0-9]+)/ ? ($1, $2) : (0, 0)
}

################################################################################
#
# sub char_is_ok ($value)
#
# Returns true iff $value is a character which we allow in a logic puzzle
# (One character string, its value either an ASCII word character, an
# underscore, or a printable, non-space, non-combining, Unicode character
# exceeding 0xA0.
#
#    IN:  - $value:  String
#
#   OUT:  - True iff we allow the character to be in the puzzle.
#
# TESTS: 105-char_is_ok.t
#
################################################################################


sub char_is_ok ($value) {
    return defined ($value)      &&
           length  ($value) == 1 &&
                   ($value  =~ /\p{PerlWord}/ ||
               ord ($value) >   0xA0
                 && $value  =~ /\p{XPosixPrint}/
                 && $value  =~ /\S/
                 && $value  =~ /\P{Control}/
                 && $value  =~ /\P{Combining_Diacritical_Marks_Extended}/
                 && $value  =~ /\P{Combining_Mark}/
                 && $value  =~ /\P{Combining_Marks_For_Symbols}/)
}


################################################################################
#
# sub set_to_character_class (@chars)
#
# Given a set of characters, return a character class (or single character)
# matching the set of charactes. 
#
# It is assumed none of the given characters is special
# ("[", "]", "^", "-", etc)
#
#    IN:  - @chars: List of characters
# 
#   OUT:  - Character class
#
# TESTS: 110-set_to_character_class.t
#
################################################################################

sub set_to_character_class (@chars) {
    return $chars [0] if @chars == 1;
    @chars = sort {$a cmp $b} @chars;
    my $class = "[";
    while (@chars > 2) {
        my $i = 0;
        while ($i + 1 < @chars && ord ($chars [0]) + $i + 1 ==
                                  ord ($chars       [$i + 1])) {
            $i ++;
        }
        if ($i <= 1) {
            $class .= shift @chars for 0 .. $i;
        }
        else {
            $class .= $chars [0] . "-" . $chars [$i];
            splice @chars, 0, $i + 1;
        }
    }
    $class .= join "" => @chars;
    $class .= "]";
    return $class;
}



################################################################################
#
# sub statement_clue (%args)
#
# Retuns a subjec/pattern pair which can be used to set the appropriate
# backreference for the clue.
#
#    IN:  - cell:     The name of the cell.
#         - row:      The row number of the cell; used if cell is not given.
#                     Defaults to 0.
#         - col:      The column number of the cell; used if cell is not given.
#                     Defaults to 0.
#         - clue:     The value of the clue. (Ought to be a single character)
#
#   OUT:  ($subject, $pattern)
#
################################################################################

sub statement_clue (%args) {
    my $cell = cell %args;
    my $clue = $args {clue};
    die "'clue' must be a single character"
                unless defined $clue && length ($clue) == 1;
    die "'clue' contains an invalid character"
                if $clue !~ /^$ALLOWED$/;

    my $statement = $clue;
    my $pattern   = "(?<$cell>$clue)";

    map {$_ . $SENTINEL} $statement, $pattern;
}



################################################################################
#
# sub cell_value (%args)
#
# Returns a subject/pattern which can be used to select the value of a cell.
#
# For now, we have two moves:
#     - Select a value from a range      (range)
#     - Either empty, or a single value  (select)
#
#    IN:  - name:     The name of the cell.
#         - row:      The row number of the cell; used if name is not given.
#                     Defaults to 0.
#         - col:      The column number of the cell; used if name is not given.
#                     Defaults to 0.
#         - max:      The maximum value of a cell.                 (range)
#         - min:      The minumum value of a cell (default 1).     (range)
#         - select:   Either select this value, or be empty        (select)
# 
# TESTS:
#
################################################################################

sub cell_value (%args) {
    my $name = cell %args;

    my ($sub, $pat);

    if (exists $args {select}) {
        my $value = $args {select};
        $sub =             $value;
        $pat = "(?<$name>\Q$value\E?)\Q$value\E?";
    }
    elsif (exists $args {max}) {
        my $max    = $args {max};
        my $min    = $args {min} // 1;
        die "The maximum value cannot exceed the minimum value\n"
                                                        if $max < $min;
        die "The maximum value cannot exceed 36\n"      if $max > 36;
        die "The minimum value cannot be less than 0\n" if $min <  0;

        my $values = join "" => map {$_ >= 10 ? chr (ord ('A') + $_ - 10) : $_}
                                     $min .. $max;

        $sub =   $values;
        $pat = "[$values]*(?<$name>[$values])[$values]*";
    }

    map {$_ . $SENTINEL} $sub, $pat;
}

1;


__END__

=pod

=head1 NAME

Regexp::Logic_Puzzles::Utils -- Utilities for various Regexp::* modules.

=head1 DESCRIPTION

This module is part of C<< Regexp::Sudoku >> (and friends) and is not intended
as a standalone module.

See L<< Regexp::Sudoku >> for the documentation.

=head1 DEVELOPMENT

The current sources of this module are found on github,
L<< git://github.com/Abigail/Regexp-Sudoku.git >>.

=head1 AUTHOR

Abigail, L<< mailto:cpan@abigail.freedom.nl >>.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2021-2023 by Abigail.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

=cut
