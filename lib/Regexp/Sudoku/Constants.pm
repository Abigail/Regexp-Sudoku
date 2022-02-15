package Regexp::Sudoku::Constants;

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

our $VERSION     = '202202015';

my   @tokens = qw [MAIN MINOR];
push @tokens => map {($_, "MINOR_$_")} map {("SUB$_", "SUPER$_")} "", 2 .. 35;

use Exporter ();
our @ISA         = qw [Exporter];
our %EXPORT_TAGS = (
    Diagonals    => [qw [$DEFAULT], map {"\$$_"} @tokens],
);
our @EXPORT_OK   = map {@$_} values %EXPORT_TAGS;

foreach my $i (keys @tokens) {
    no strict 'refs';
    no warnings 'once';
    vec (${$tokens [$i]} = "", $i, 1) = 1;
}


our $DEFAULT = our $MAIN |. our $MINOR;

1;


__END__
