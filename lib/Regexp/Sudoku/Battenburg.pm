package Regexp::Sudoku::Battenburg;

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

our $VERSION = '2022030401';

use Hash::Util::FieldHash qw [fieldhash];
use Regexp::Sudoku::Utils;

fieldhash my %battenburg2cells;
fieldhash my %cell2battenburgs;

use List::Util qw [min max];

        
################################################################################
#
# set_battenburg ($self, @cells)
#
# Set one or more batterburg constraints. For each constraint, we give
# the top left cell. (Multiple cells mean *different* constraints, not
# the cells of a single constraint)
#
# TESTS: 180-set_battenburg.t
#
################################################################################
            
sub set_battenburg ($self, @cells) {
    foreach my $name (@cells) {
        #
        # Calculate all the cells of the constraint
        #
        my ($r, $c) = cell_row_column ($name);
        my @cells = (cell_name ($r,     $c), cell_name ($r,     $c + 1),
                     cell_name ($r + 1, $c), cell_name ($r + 1, $c + 1));
        foreach my $cell (@cells) {  
            $cell2battenburgs {$self} {$cell} {$name} = 1;
            $battenburg2cells {$self} {$name} {$cell} = 1;
        }
    }
    $self;
}
    
    
################################################################################
#
# cell2battenburgs ($self, $cell)
#
# Return a list of battenburgs a cell belongs to.
#
# TESTS: 170-set_renban.t
#
################################################################################
 
sub cell2battenburgs ($self, $cell) {
    keys %{$cell2battenburgs {$self} {$cell} || {}}
}
  

################################################################################
#
# battenburg2cells ($self, $name)
#
# Return a list of cells in a battenburg.
#
# TESTS: 170-set_battenburg.t
#
################################################################################
        
sub battenburg2cells ($self, $name) {
    keys %{$battenburg2cells {$self} {$name} || {}}
}
            

################################################################################
#
# make_battenburg_statement ($self, $cell1, $cell2)
#           
# Return a statement which implements a Battenburg constraint between
# the two cells. We will assume the given cells belong to the same
# Battenburg contraint. If the cells are on the same row or column,
# the constraint is that they have a different parity. Else, the
# cells must have the same parity.
# 
# TESTS: 183-make_battenburg_statement.t
# 
################################################################################

sub make_battenburg_statement ($self, $cell1, $cell2) {
    my ($r1, $c1) = cell_row_column ($cell1);
    my ($r2, $c2) = cell_row_column ($cell2);
    my ($subsub, $subpat);
    
    #
    # Case 1, cells are diagonally opposite.
    # Then the parity must be the same.
    #
    if ($r1 != $r2 && $c1 != $c2) {
        my $md = $self -> must_differ ($cell1, $cell2);
        return $self -> make_same_parity_statement ($cell1, $cell2, $md);
    }
    else {
        return $self -> make_different_parity_statement ($cell1, $cell2);
    }
}
 

################################################################################
#
# same_battenburg ($self, $cell1, $cell2)
#
# Return a list of battenburg to which both $cell1 and $cell2 belong.
# In scalar context, returns the number of battenburg the cells both belong.
#
# TESTS: 184-same_battenburg.t
#
################################################################################

sub same_battenburg ($self, $cell1, $cell2) {
    my %seen;
    $seen {$_} ++ for $self -> cell2battenburgs ($cell1),
                      $self -> cell2battenburgs ($cell2);

    grep {$seen {$_} > 1} keys %seen;
}
 

__END__

=pod

=head1 NAME

Regexp::Sudoku::Battenburg -- Battenburg related method

=head1 DESCRIPTION

This module is part of C<< Regexp::Sudoku >> and is not intended
as a standalone module.

See L<< Regexp::Sudoku >> for the documentation.

=head1 DEVELOPMENT

The current sources of this module are found on github,
L<< git://github.com/Abigail/Regexp-Sudoku.git >>.

=head1 AUTHOR

Abigail, L<< mailto:cpan@abigail.freedom.nl >>.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2021-2022 by Abigail.

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
