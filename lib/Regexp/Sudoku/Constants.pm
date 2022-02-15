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
    Diagonals    => [qw [$DEFAULT $MAIN $MINOR $SUB $SUPER],
                     map {(      "\$SUPER$_",       "\$SUB$_", 
                           "\$MINOR_SUPER$_", "\$MINOR_SUB$_")} 2 .. 8]
);
our @EXPORT_OK   = map {@$_} values %EXPORT_TAGS;

our $MAIN          = 1 <<  0;
our $MINOR         = 1 <<  1;
our $DEFAULT       = $MAIN | $MINOR;
our $SUPER         = 1 <<  2;
our $SUB           = 1 <<  3;
our $SUPER2        = 1 <<  4;
our $SUPER3        = 1 <<  5;
our $SUPER4        = 1 <<  6;
our $SUPER5        = 1 <<  7;
our $SUPER6        = 1 <<  8;
our $SUPER7        = 1 <<  9;
our $SUPER8        = 1 << 10;
our $SUB2          = 1 << 11;
our $SUB3          = 1 << 12;
our $SUB4          = 1 << 13;
our $SUB5          = 1 << 14;
our $SUB6          = 1 << 15;
our $SUB7          = 1 << 16;
our $SUB8          = 1 << 17;
our $MINOR_SUPER   = 1 << 18;
our $MINOR_SUB     = 1 << 19;
our $MINOR_SUPER2  = 1 << 20;
our $MINOR_SUPER3  = 1 << 21;
our $MINOR_SUPER4  = 1 << 22;
our $MINOR_SUPER5  = 1 << 23;
our $MINOR_SUPER6  = 1 << 24;
our $MINOR_SUPER7  = 1 << 25;
our $MINOR_SUPER8  = 1 << 26;
our $MINOR_SUB2    = 1 << 27;
our $MINOR_SUB3    = 1 << 28;
our $MINOR_SUB4    = 1 << 29;
our $MINOR_SUB5    = 1 << 30;
our $MINOR_SUB6    = 1 << 31;
our $MINOR_SUB7    = 1 << 32;
our $MINOR_SUB8    = 1 << 33;


1;


__END__


1;


__END__
