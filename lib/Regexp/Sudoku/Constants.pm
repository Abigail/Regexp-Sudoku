package Regexp::Sudoku::Constants;

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

our $VERSION = '2022022001';

################################################################################
#
# Diagonals
#
# TESTS: Constants/100-diagonals.t
#
################################################################################

my   @tokens  =  qw [SUPER0 MINOR_SUPER0];
push @tokens  => map {($_, "MINOR_$_")} map {("SUB$_", "SUPER$_")} "", 1 .. 34;

my   @aliases =  qw [MAIN MINOR SUB0 MINOR_SUB0
                     SUB SUPER MINOR_SUP MINOR_SUPER];
my   @sets    =  qw [CROSS DOUBLE TRIPLE ARGYLE];
push @sets    => map {"CROSS$_"} 0 .. 34;

our  $ALL_DIAGONALS;

foreach my $i (keys @tokens) {
    no strict 'refs';
    no warnings 'once';
    vec ($ALL_DIAGONALS, $i, 1) = 1;
    vec (${$tokens [$i]} = "", $i, 1) = 1;
}

our $MAIN        = our $SUPER0;
our $MINOR       = our $MINOR_SUPER0;
our $SUB0        =     $SUPER0;
our $MINOR_SUB0  =     $MINOR_SUPER0;
our $SUPER       = our $SUPER1;
our $SUB         = our $SUB1;
our $MINOR_SUPER = our $MINOR_SUPER1;
our $MINOR_SUB   = our $MINOR_SUB1;

foreach my $i (0 .. 34) {
    no strict 'refs';
    no warnings 'once';
    ${"CROSS$i"} = ${"SUB$i"}   |. ${"MINOR_SUB$i"} |.
                   ${"SUPER$i"} |. ${"MINOR_SUPER$i"};
}

our $CROSS       = our $CROSS0;
our $DOUBLE      = our $CROSS1;
our $TRIPLE      = $CROSS  |.     $CROSS1;
our $ARGYLE      = $CROSS1 |. our $CROSS4;

# our $ALL_DIAGONALS   = "";
#     $ALL_DIAGONALS |.= $_ foreach @tokens;

################################################################################
#
# Houses
#
# TESTS: Constants/110-diagonals.t
#
################################################################################

vec (our $NRC        = "", 0, 1) = 1;
vec (our $ASTERISK   = "", 1, 1) = 1;
vec (our $GIRANDOLA  = "", 2, 1) = 1;
vec (our $CENTER_DOT = "", 3, 1) = 1;
     our $ALL_HOUSES = $NRC |. $ASTERISK |. $GIRANDOLA |. $CENTER_DOT;


################################################################################
#
# Constraints
#
# TESTS: Constants/120-constraints.t
#
################################################################################

vec (our $ANTI_KNIGHT     = "", 0, 1) = 1;
vec (our $ANTI_KING       = "", 1, 1) = 1;
     our $ALL_CONSTRAINTS = $ANTI_KNIGHT |. $ANTI_KING;


################################################################################
#
# Exporting the symbols
#
################################################################################

use Exporter ();
our @ISA         = qw [Exporter];
our %EXPORT_TAGS = (
    Diagonals    => [map {"\$$_"} @tokens, @aliases, @sets, "ALL_DIAGONALS"],
    Houses       => [qw [$NRC $ASTERISK $GIRANDOLA $CENTER_DOT $ALL_HOUSES]],
    Constraints  => [qw [$ANTI_KNIGHT $ANTI_KING $ALL_CONSTRAINTS]],
);
our @EXPORT_OK   = map {@$_} values %EXPORT_TAGS;
    $EXPORT_TAGS {All} = \@EXPORT_OK;


1;


__END__


=head1 NAME

Regexp::Sudoku::Constants - Constants related to Regexp::Sudoku

=head1 SYNOPSIS

 use Regexp::Sudoku;
 use Regexp::Sudoku::Constants qw [:Houses :Constraints :Diagonals];

 my $sudoku = Regexp::Sudoku:: -> new -> init (
    clues      => "...",
    diagonals  => $MAIN |. $MINOR,
    houses     => $NRC,
    constaints => $ANTI_KING;

=head1 DESCRIPTION

This module exports constants to be used to configure Sudoku variants
when using C<< Regexp::Sudoku >>.

All constants are bitmasks based on C<< vec >>. Constants are grouped
based on L<< Exporter >> tags; constants exported by the same tag
can be mixed using the bitwise operators: C<< |. >>, C<< &. >>
and C<< ~. >>.

There are three tags C<< :Houses >>, C<< :Constraints >> and
C<< :Diagonals >>. There is also the tag C<< :All >>, which can
be used to import all the constants.

We'll discuss the constants below, grouped by the tag which imports
them. (You can still import each constant individually if you wish
to do so).

=head2 C<< :Houses >>

These are used to signal the Sudoku variant uses additional houses.
For a description of each additional house, see
L<< Regexp::Sudoku >>.

The constants are used for the C<< houses >> parameter of the
C<< init >> function of C<< Regexp::Sudoku >>.

=over 2

=item C<< $NRC >>

This is for I<< NRC Sudokus >>; also called I<< Windokus >> or
I<< Hyper Sudokus >>.

=item C<< $ASTERISK >>

This is for I<< Asterisk Sudokus >>. 

=item C<< $GIRANDOLA >>

This is for I<< Girandola Sudokus >>. 

=item C<< $CENTER_DOT >>

This is for I<< center dot Sudokus >>.

=back

=head2 C<< :Constraints >>

These constants are used for the C<< constraints >> parameter, and
indicate which additionally constraints apply to the Sudoku variant.

=over 2

=item C<< $ANTI_KNIGHT >>

In an I<< Anti-Knight Sudoku >>, cells which are a Knights move away
(as in Chess) must be different.

=item C<< $ANTI_KING >>

In an I<< Anti-King Sudoku >>, cells which touch each other (including cells 
which only touch by their corners) must be different. These cells
corresponds with a Kings move in Chess. This type of Sudoku is also
known as a I<< No Touch Sudoku >>.

=back 2

=head2 C<< :Diagonals >>

=head1 BUGS

There are no known bugs.

=head1 SEE ALSO

L<< Regexp::Sudoku >>.

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

=head1 INSTALLATION

To install this module, run, after unpacking the tar-ball, the 
following commands:

   perl Makefile.PL
   make
   make test
   make install

=cut
