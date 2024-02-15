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

our @ISA    = qw [Exporter];
our @EXPORT = qw [cell_name cell_row_column];

our $SENTINEL       = "\n";

################################################################################
#
# sub cell_name ($row, $column)
#
# Given a row number and a cell number, return the name of the cell.
#
# TESTS: 100-cell_name_row_column.t
#
################################################################################

sub cell_name ($row, $column) {
    "R" . $row . "C" . $column
}


################################################################################
#
# sub cell_row_column ($cell_name)
#
# Given the name of a cell, return its row and column.
# 
# TESTS: 100-cell_name_row_column.t
#
################################################################################

sub cell_row_column ($name) {
    $name =~ /R([0-9]+)C([0-9]+)/ ? ($1, $2) : (0, 0)
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
    my $name = $args {name} // cell_name ($args {row} || 0,
                                          $args {col} || 0);

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
