package Test;

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

chdir "t" if -d "t";

#
# Little module to help use test a sudoku
#

use lib qw [lib ../lib];

use Exporter ();
our @ISA    = qw [Exporter];
our @EXPORT = qw [run_sudoku];

use Regexp::Sudoku;
use Test::More;


sub run_sudoku ($file) {
    #
    # First, slurp in the file
    #
    my $test = do {local (@ARGV, $/) = ($file); <>};
    my @chunks = split /\n==\n/ => $test;

    #
    # First one is always the sudoku.
    #
    my $clues = shift @chunks;

    #
    # Find a solution
    #
    my ($solution) = grep {/^Solution/} @chunks;

    #
    # Find args, if any
    #
    my ($arg_section) = grep {/^Args/} @chunks;
    my  $args = {};
    if ($arg_section) {
        $arg_section =~ s/^.*\n//;
        $args = eval $arg_section;
        die $@ if $@;
    }

    #
    # Find the size
    #
    my ($first) = split /\n/ => $clues;
    my  $size   = () = $first =~ /\S+/g;

    #
    # Find the name, if any
    #
    my ($name)   = $test =~ /^Name:\s*(.*)/m;
        $name  //= "Sudoku size $size";

    subtest $name => sub {
        #
        # Sudoku object
        #
        my $sudoku = Regexp::Sudoku:: -> new -> init (size  => $size,
                                                      clues => $clues,
                                                      %$args);

        ok $sudoku, "Regexp::Sudoku object";
        return unless $sudoku;

        #
        # Get the string and pattern
        #
        my $string  = $sudoku -> string;
        my $pattern = $sudoku -> pattern;

        ok $string,  "Got a string";
        ok $pattern, "Got a pattern";
        return unless $string && $pattern;

        #
        # Do the actual match
        #
        my $r = $string =~ $pattern;
        ok $r, "Match";
        return unless $r;

        my %plus = %+;

        if ($solution) {
            $solution =~ s/^.*\n//;
            my @exp = map {[/\S+/g]} grep {/\S/} split /\n/ => $solution;
            foreach my $r (1 .. $size) {
                foreach my $c (1 .. $size) {
                    my $cell = "R${r}C${c}";
                    is $plus {$cell}, $exp [$r - 1] [$c - 1], "Cell $cell";
                }
            }
        }
    }
}
