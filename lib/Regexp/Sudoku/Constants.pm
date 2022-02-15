package Regexp::Sudoku::Constants;

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

our $VERSION     = '202202015';

use Exporter ();
our @ISA         = qw [Exporter];
our %EXPORT_TAGS = (
    Diagonals    => [qw [$DEFAULT $MAIN $MINOR]]
);
our @EXPORT_OK   = map {@$_} values %EXPORT_TAGS;

our $MAIN    = 1 << 0;
our $MINOR   = 1 << 1;
our $DEFAULT = $MAIN | $MINOR;


1;


__END__
