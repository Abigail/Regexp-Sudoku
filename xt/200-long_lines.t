#!/usr/bin/perl

use 5.028;

use Test::More;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

use lib qw [lib ../lib];

my ($manifest) = grep {-f} "./MANIFEST", "../MANIFEST";

die "Cannot find MANIFEST" unless $manifest;

open my $fh,  "<",  $manifest       or die "open $manifest: $!";
open my $fhs, "<", "$manifest.SKIP" or die "open $manifest.SKIP: $!";
chomp (my @files = (<$fh>, <$fhs>));

foreach my $file (@files) {
    next if $file =~ /\.tar\.gz$/;
    next if $file =~ /\.tmp/;
    next if $file =~ /\.html/;

    open my $fh2, "<", $file or die "Failed to open $file: $!";
    chomp (my @lines = <$fh2>);
    @lines = grep {length ($_) > 80} @lines;
    #
    # URL: lines are fine.
    #
    if ($file =~ m !t/sudokus/!) {
        @lines = grep {!/^URL:/} @lines;
    }
    ok !@lines, "$file does not have overly long lines";
}


done_testing ();


__END__
