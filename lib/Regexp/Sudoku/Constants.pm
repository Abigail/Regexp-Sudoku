package Regexp::Sudoku::Constants;

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

our $VERSION = '2022030401';

use Exporter ();

our @ISA    = qw [Exporter];
our @EXPORT = qw [$SENTINEL $DEFAULT_SIZE $NR_OF_DIGITS $NR_OF_LETTERS
                  $NR_OF_LETTERS $NR_OF_SYMBOLS $ANTI_KING $ANTI_KNIGHT
                  $MAIN_DIAGONAL $MINOR_DIAGONAL];

our $SENTINEL       = "\n";

our $DEFAULT_SIZE   = 9;

our $NR_OF_DIGITS   =  9;
our $NR_OF_LETTERS  = 26;
our $NR_OF_SYMBOLS  = $NR_OF_DIGITS + $NR_OF_LETTERS;

our $ANTI_KNIGHT    = 1;
our $ANTI_KING      = 2;

our $MAIN_DIAGONAL  = 1;
our $MINOR_DIAGONAL = 2;


1;


__END__

=pod

=head1 NAME

Regexp::Sudoku::Constants -- Constants for Regexp::Sudoku

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
