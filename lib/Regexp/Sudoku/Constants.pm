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
my   @sets    =  qw [CROSS DOUBLE TRIPLE ARGYLE];
push @sets    => map {"CROSS$_"} 0 .. 35;

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

foreach my $i (0 .. 35) {
    no strict 'refs';
    no warnings 'once';
    ${"CROSS$i"} = ${"SUB$i"}   |. ${"MINOR_SUB$i"} |.
                   ${"SUPER$i"} |. ${"MINOR_SUPER$i"};
}

our $CROSS       = our $CROSS0;
our $DOUBLE      = our $CROSS1;
our $TRIPLE      = $CROSS  |.     $CROSS1;
our $ARGYLE      = $CROSS1 |. our $CROSS4;

1;


__END__
