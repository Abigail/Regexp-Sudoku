package Regexp::Sudoku::Constants;

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

our $VERSION     = '202202015';

my   @tokens  =  qw [SUPER0 MINOR_SUPER0];
push @tokens  => map {($_, "MINOR_$_")} map {("SUB$_", "SUPER$_")} "", 1 .. 35;

my   @aliases =  qw [MAIN MINOR SUB0 MINOR_SUB0
                     SUB SUPER MINOR_SUP MINOR_SUPER];
my   @sets    =  qw [DEFAULT DOUBLE TRIPLE ARGYLE];

use Exporter ();
our @ISA         = qw [Exporter];
our %EXPORT_TAGS = (
    Diagonals    => [map {"\$$_"} @tokens, @aliases, @sets],
);
our @EXPORT_OK   = map {@$_} values %EXPORT_TAGS;

foreach my $i (keys @tokens) {
    no strict 'refs';
    no warnings 'once';
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

our $DEFAULT     = $MAIN   |. $MINOR;
our $DOUBLE      = $SUPER  |. $SUB |. $MINOR_SUPER |. $MINOR_SUB;
our $TRIPLE      = $DOUBLE |. $DEFAULT;
our $ARGYLE      = $DOUBLE |. our $SUB4 |. our $SUPER4 |.
                              our $MINOR_SUB4 |. our $MINOR_SUPER4;

1;


__END__
