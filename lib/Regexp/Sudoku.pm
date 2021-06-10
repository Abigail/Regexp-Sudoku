package Regexp::Sudoku;

use 5.032;
use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

our $VERSION = '2021060901';

use Exporter ();
our @ISA       = qw [Exporter];
our @EXPORT    = qw [sudoku];
our @EXPORT_OK = qw [run_sudoku];

my $DEFAULT_SIZE    = 9;
my $CELL_SENTINEL   = ";";
my $CLAUSE_SENTINEL = ":";
my $CLAUSE_LIST     = ",";

#
# Given a cell name, and a value, return a sub string, and sub pattern
# which sets the capture '$cell' to '$value'
#
my sub clue ($cell, $value) {
    my $substr = $value;
    my $subpat = "(?<$cell>$value)";

    map {$_ . $CELL_SENTINEL} $substr, $subpat;
}


#
# Given a cell name, and a list of values, return a sub string and a
# sub pattern allowing the cell to pick up one of those values.
# The values should be alpha numerical.
#
my sub empty ($cell, $values) {
    my $substr = $values;
    my $subpat = "[$values]*(?<$cell>[$values])[$values]*";

    map {$_ . $CELL_SENTINEL} $substr, $subpat;
}


#
# Given two cell names, and a list of possible values, return a sub string
# an sub pattern which matches iff the values in the cell differ.
#
my sub diff_clause ($cell1, $cell2, $values) {
    my $substr = "";
    my @chars  = split // => $values;
    for my $c (@chars) {
        $substr .= join "" => $c, grep {$_ ne $c} @chars;
        $substr .= $CLAUSE_LIST;
    }
    my $subpat = "(?:[$values]+$CLAUSE_LIST)*"                             .
                 "\\g{$cell1}[$values]*\\g{$cell2}[$values]*$CLAUSE_LIST"  .
                 "(?:[$values]+$CLAUSE_LIST)*";

    map {$_ . $CLAUSE_SENTINEL} $substr, $subpat;
}


#
# Take the clues, and return a structure which maps cell
# names to clue values. For now, we take the clues as a 2-d array
#
sub make_clues ($in_clues) {
    my $clues = {};
    #
    # Turn a string into an array
    #
    if (!ref $in_clues) {
        my @rows = grep {/\S/} split /\n/ => $in_clues;
        $in_clues = [map {[split]} @rows];
    }
    foreach my $r (keys @$in_clues) {
        foreach my $c (keys @{$$in_clues [$r]}) {
            my $val  = $$in_clues [$r] [$c] or next;
            my $cell = "R" . ($r + 1) . "C" . ($c + 1);
            $$clues {$cell} = $val;
        }
    }
    $clues;
}


sub sudoku (%args) {
    state $def_values = join "" => 1 .. 9, 'A' .. 'Z';
    my $size   = $args {size}   || $DEFAULT_SIZE;
    my $values = $args {values} || substr $def_values, 0, $size;
    my $clues  = make_clues $args {clues} || [];

    #
    # Find the width and height of a box. If the size of the sudoku
    # is a square, the width and height of a box are equal, and the
    # square root of the size of the sudoku. Else, we'll find the
    # most squarish width and height (with the width larger than the
    # height).
    #
    my $box_height = int sqrt $size;
    $box_height -- while $size % $box_height;
    my $box_width  = $size / $box_height;


    #
    # For each of the cells, record in which houses they are.
    # For each house, record which cells they contain.
    #
    # Cells are named R1C1, R1C2, ..., RnCn, with R1C1 in the
    # top left corner and RnCn in the bottom right.
    #
    # Rows are named     R1, ..., Rn
    # Columns are named  C1, ..., Cn
    # Boxes are named   B11, ..., Bmp (m * p == n)
    #

    my %cell2houses;
    my %house2cells;
    for my $r (1 .. $size) {
        for my $c (1 .. $size) {
            my $cell   = "R${r}C${c}";
            my $row    = "R${r}";
            my $column = "C${c}";

            my $w      =  1 + int (($c - 1) / $box_width);
            my $h      =  1 + int (($r - 1) / $box_height);
            my $box    = "B${h}${w}";

            $cell2houses {$cell} {$_}    = 
            $house2cells {$_}    {$cell} = 1 for $row, $column, $box;
        }
    }

    #
    # Construct a string and a pattern
    #
    my $string  = "";
    my $pattern = "";

    my @cells = sort keys %cell2houses;

    foreach my $i (keys @cells) {
        my $cell1 = $cells [$i];
        #
        # First, pick a value. If there is a clue, use the clue.
        # Else, pick one of the possible values.
        #
        my ($substr, $subpat);
        if (my $value = $$clues {$cell1}) {
            ($substr, $subpat) = clue  ($cell1, $value);
        }
        else {
            ($substr, $subpat) = empty ($cell1, $values);
        }
        $string  .= $substr;
        $pattern .= $subpat;

        #
        # For each of the previous cells, if they share a house,
        # they need to be different.
        #
        for (my $j = 0; $j < $i; $j ++) {
            my $cell2  = $cells [$j];
            if (grep {$cell2houses {$cell1} {$_}}
                       keys %{$cell2houses {$cell2}}) {
                #
                # Cells share a house, so they must be different.
                #
                my ($substr, $subpat) = diff_clause ($cell1, $cell2, $values);
                $string  .= $substr;
                $pattern .= $subpat;
            }
        }
    }

    ($string, "^$pattern\$");
}


sub run_sudoku ($string, $pattern, $size) {
    if ($string =~ $pattern) {
        my $out = "";
        foreach my $r (1 .. $size) {
            $out .= join " ", map {$+ {"R${r}C${_}"}} 1 .. $size;
            $out .= "\n";
        }
        return $out;
    }
}

__END__

my $clues9 = [
   [5, 3, 0,   0, 7, 0,   0, 0, 0],
   [6, 0, 0,   1, 9, 5,   0, 0, 0],
   [0, 9, 8,   0, 0, 0,   0, 6, 0],

   [8, 0, 0,   0, 6, 0,   0, 0, 3],
   [4, 0, 0,   8, 0, 3,   0, 0, 1],
   [7, 0, 0,   0, 2, 0,   0, 0, 6],

   [0, 6, 0,   0, 0, 0,   2, 8, 0],
   [0, 0, 0,   4, 1, 9,   0, 0, 5],
   [0, 0, 0,   0, 8, 0,   0, 7, 9],
];

my $clues6 = [
    [0, 0, 0,   0, 0, 1],
    [0, 5, 6,   0, 0, 0],

    [0, 4, 5,   0, 0, 6],
    [0, 0, 0,   0, 4, 5],

    [0, 0, 0,   5, 0, 0],
    [5, 0, 1,   3, 0, 0],
];

my $clues =  $clues6;
my $size  = @$clues;

my ($string, $pattern) = sudoku (size  => $size,
                                 clues => $clues);
say run_sudoku ($string, $pattern, $size);

__END__

# say $string;
# say $pattern;

if ($string =~ /^$pattern$/) {
    for (my $r = 1; $r <= $size; $r ++) {
        for (my $c = 1; $c <= $size; $c ++) {
            print $+ {"R${r}C${c}"} . " ";
        }
        print "\n";
    }
}
else {
    say "No match"
}

1;

__END__

=head1 NAME

Regexp::Sudoku - Abstract

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

=head1 TODO

=head1 SEE ALSO

=head1 DEVELOPMENT

The current sources of this module are found on github,
L<< git://github.com/Abigail/Regexp-Sudoku.git >>.

=head1 AUTHOR

Abigail, L<< mailto:cpan@abigail.be >>.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2021 by Abigail.

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

=head1 INSTALLATION

To install this module, run, after unpacking the tar-ball, the 
following commands:

   perl Makefile.PL
   make
   make test
   make install

=cut
