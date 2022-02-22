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
