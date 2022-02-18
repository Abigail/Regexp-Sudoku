package Regexp::Sudoku;

use 5.028;
use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

our $VERSION = '2021060901';

use Hash::Util::FieldHash qw [fieldhash];
use List::Util            qw [min];
use Math::Sequence::DeBruijn;
use Regexp::Sudoku::Constants qw [:Diagonals :Houses];

use Exporter ();
our @ISA       = qw [Exporter];
our @EXPORT    = qw [sudoku];
our @EXPORT_OK = qw [run_sudoku];

my $DEFAULT_SIZE   = 9;
my $SENTINEL       = "\n";
my $CLAUSE_LIST    = ",";

my $NR_OF_DIGITS   =  9;
my $NR_OF_LETTERS  = 26;
my $NR_OF_SYMBOLS  = $NR_OF_DIGITS + $NR_OF_LETTERS;


fieldhash my %size;
fieldhash my %values;
fieldhash my %box_width;
fieldhash my %box_height;
fieldhash my %values_range;
fieldhash my %cell2houses;
fieldhash my %house2cells;
fieldhash my %clues;
fieldhash my %subject;
fieldhash my %pattern;

################################################################################
#
# new ($class)
#
# Create an uninitialized object.
#
################################################################################

sub new ($class) {bless \do {my $v} => $class}


################################################################################
#
# sub cell_name ($row, $column)
#
# Given a row number and a cell number, return the name of the cell.
#
# TESTS: 090-cell_name.t
#
################################################################################

sub cell_name ($row, $column) {
    "R" . $row . "C" . $column
}


################################################################################
#
# init_sizes ($self, $size)
#
# Initialize the sizes of the soduko.
#
# Calls init_size () and init_box () doing the work.
#
# TESTS: 010_size.t
#
################################################################################

sub init_sizes ($self, %args) {
    $self -> init_size (%args)
          -> init_box  (%args);
}


################################################################################
#
# init_size ($self, $size)
#
# Initialize the size of a sudoku. If the size is not given, use the default.
#
# TESTS: 010_size.t
#
################################################################################

sub init_size ($self, %args) {
    $size {$self} = $args {size} || $DEFAULT_SIZE;
    $self;
}


################################################################################
#
# size ($self)
#
# Returns the size of the sudoku. If there is no size supplied, use 
# the default (9).
#
# TESTS: 010_size.t
#
################################################################################

sub size ($self) {
    $size {$self}
}


################################################################################
#
# init_values ($self)
#
# Initializes the values. We calculate them from the range (1-9, A-Z),
# as many as needed.
#
# TESTS: 020_values.t
#
################################################################################

sub init_values ($self, %args) {
    my $size   = $self -> size;
    my $values = join "" => 1 .. min $size, $NR_OF_DIGITS;
    if ($size > $NR_OF_DIGITS) {
        $values .= join "" =>
            map {chr (ord ('A') + $_ - $NR_OF_DIGITS - 1)}
                ($NR_OF_DIGITS + 1) .. min $size, $NR_OF_SYMBOLS;
    }

    $values {$self} = $values;

    $self -> init_values_range (%args);
}


################################################################################
#
# init_value_ranges ($self)
#
# Processes the values to turn them into ranges for use in a character class
#
# TESTS: 020_values.t
#
################################################################################

sub init_values_range ($self, %args) {
    my @values = sort {$a cmp $b} $self -> values;
    my $size   = $self -> size;
    my $range  = "1-";

    if    ($size <  10) {$range .=         $values [-1];}
    elsif ($size == 10) {$range .= "9A";                }
    else                {$range .= "9A-" . $values [-1];}

    $values_range {$self} = $range;

    $self;
}


################################################################################
#
# values ($self)
#
# Return the set of values used in the sudoku. In list context, this will
# be an array of characters; in scalar context, a string.
#
# TESTS: 020_values.t
#
################################################################################

sub values ($self) {
    wantarray ? split // => $values {$self} : $values {$self};
}


################################################################################
#
# values_range ($self)
#
# Return the set of values used in the sudoku, as ranges to be used in
# a character class. Calls $self -> values () to get the values.
#
# TESTS: 020_values.t
#
################################################################################

sub values_range ($self) {
    $values_range {$self}
}


################################################################################
#
# box_init ($self)
#
# Find the width and height of a box. If the size of the sudoku is a square,
# the width and height of a box are equal, and the square root of the size
# of the sudoku. Else, we'll find the most squarish width and height (with
# the width larger than the height). The width and height are stored as
# attributes. If they are already set, the function immediately returns.
#
# TESTS: 030-box.t
#
################################################################################

sub init_box ($self, %args) {
    return if $box_height {$self} && $box_width {$self};
    my $size = $self -> size;
    my $box_height = int sqrt $size;
    $box_height -- while $size % $box_height;
    my $box_width  = $size / $box_height;

    $box_height {$self} = $box_height;
    $box_width  {$self} = $box_width;

    $self;
}


################################################################################
#
# box_height ($self)
# box_width  ($self)
#
# Return the height and width of a box in the sudoku. These methods will
# call $self -> box_init first, to calculate the values if necessary.
#
# TESTS: 030_values.t
#
################################################################################

sub box_height ($self) {
    $box_height {$self};
}

sub box_width ($self) {
    $box_width {$self};
}


################################################################################
#
# create_house ($self, $house_name, @cells)
#
# Create a house with the given name, containing the passed in cells.
#
# TESTS: 040-create_house.t
#
################################################################################

sub create_house ($self, $name, @cells) {
    for my $cell (@cells) {
        $cell2houses {$self} {$cell} {$name} = 1;
        $house2cells {$self} {$name} {$cell} = 1;
    }
    $self;
}


################################################################################
#
# init_rows ($self, %args)
#
# Initialize the rows in the sudoku. Calculates which cells belong to which
# rows, and calls create_house for each row. Called from init_houses.
# Rows are named "R1" .. "Rn", where n is the size of the sudoku.
#
# TESTS: 041-init_rows
#
################################################################################

sub init_rows ($self, %args) {
    my $size = $self -> size;
    for my $r (1 .. $size) {
        my $row_name = "R$r";
        my @cells    = map {cell_name $r, $_} 1 .. $size;
        $self -> create_house ($row_name, @cells);
    }
    $self;
}


################################################################################
#
# init_columns ($self, %args)
#
# Initialize the columns in the sudoku. Calculates which cells belong to which
# columns, and calls create_house for each column. Called from init_houses.
# Columns are named "C1" .. "Cn", where n is the size of the sudoku.
#
# TESTS: 042-init_columns
#
################################################################################

sub init_columns ($self, %args) {
    my $size = $self -> size;
    for my $c (1 .. $size) {
        my $col_name = "C$c";
        my @cells    = map {cell_name $_, $c} 1 .. $size;
        $self -> create_house ($col_name, @cells);
    }
    $self;
}


################################################################################
#
# init_boxes ($self, %args)
#
# Initialize the boxes in the sudoku. Calculates which cells belong to which
# boxes, and calls create_house for each box. Called from init_houses.
# Boxes are named "B1-1" .. "Bh-w" where we have h rows of w boxes.
#
# TESTS: 043-init_boxes
#
################################################################################

sub init_boxes ($self, %args) {
    my $size       = $self -> size;
    my $box_width  = $self -> box_width;
    my $box_height = $self -> box_height;

    my $bc = $size / $box_width;
    my $br = $size / $box_height;
    for my $r (1 .. $br) {
        for my $c (1 .. $bc) {
            my $box_name = "B${r}-${c}";
            my $tlr = 1 + ($r - 1) * $box_height;
            my $tlc = 1 + ($c - 1) * $box_width;
            my @cells;
            for my $dr (1 .. $box_height) {
                for my $dc (1 .. $box_width) {
                    my $cell = cell_name $tlr + $dr - 1, $tlc + $dc - 1;
                    push @cells => $cell;
                }
            }
            $self -> create_house ($box_name, @cells);
        }
    }
    $self;
}


################################################################################
#
# init_houses ($self, %args)
#      init_rows    ($self)
#      init_columns ($self)
#      init_boxes   ($self)
#
# Calculate which cells go into which houses.
#
# Calls init_rows (), init_columns (), and init_boxes () to initialize
# the rows, columns and boxes. 
#
# Depending on the parameters, it may call:
#   - init_nrc_houses () 
#   - init_asterisk_house ()
#
# TESTS: 045-init_houses.t
#
################################################################################

sub init_houses ($self, %args) {
    $self -> init_rows             (%args)
          -> init_columns          (%args)
          -> init_boxes            (%args)
          -> init_nrc_houses       (%args)
          -> init_asterisk_house   (%args)
          -> init_girandola_house  (%args)
          -> init_center_dot_house (%args)
          -> init_diagonals        (%args);
}


################################################################################
#
# init_nrc_houses ($self, %args)
#
# For NRC style puzzles, handle creating the houses.
#
# TESTS: 046-init_nrc_houses.t
#
################################################################################

sub init_nrc_houses ($self, %args) {
    return $self unless $self -> size == $DEFAULT_SIZE &&
                        $args {houses} && $args {houses} & $NRC;

    my @top_left = ([2, 2], [2, 6], [6, 2], [6, 6]);
    foreach my $i (keys @top_left) {
        my $top_left = $top_left [$i];
        my $house = "NRC" . ($i + 1);
        my @cells;
        foreach my $dr (0 .. 2) {
            foreach my $dc (0 .. 2) {
                my $cell = cell_name $$top_left [0] + $dr,
                                     $$top_left [1] + $dc;
                push @cells => $cell;
            }
        }
        $self -> create_house ($house, @cells);
    }

    $self;
}


################################################################################
#
# sub init_asterisk_house ($self)
#
# An asterisk sudoku has an additional house: one cell from each box.
# This method initializes that house.
#
# An asterisk is defined for a 9 x 9 sudoku as follows:
#
#     . . .  . . .  . . .
#     . . .  . * .  . . .
#     . . *  . . .  * . .
#
#     . . .  . . .  . . .
#     . * .  . * .  . * .
#     . . .  . . .  . . .
#
#     . . *  . . .  * . .
#     . . .  . * .  . . .
#     . . .  . . .  . . .
#
# TESTS: 047-init_asterisk_house.t
#
################################################################################

sub init_asterisk_house ($self, %args) {
    return $self unless $self -> size == $DEFAULT_SIZE &&
                        $args {houses} && $args {houses} & $ASTERISK;

    $self -> create_house ("AS" => map {cell_name @$_}
                                       [3, 3], [2, 5], [3, 7],
                                       [5, 2], [5, 5], [5, 8],
                                       [7, 3], [8, 5], [7, 7]);
}


################################################################################
#
# sub init_girandola_house ($self, %args)
#
# An asterisk sudoku has an additional house: one cell from each box.
# This method initializes that house.
#
# An asterisk is defined for a 9 x 9 sudoku as follows:
#
#     * . .  . . .  . . *
#     . . .  . * .  . . .
#     . . .  . . .  . . .
#
#     . . .  . . .  . . .
#     . * .  . * .  . * .
#     . . .  . . .  . . .
#
#     . . .  . . .  . . .
#     . . .  . * .  . . .
#     * . .  . . .  . . *
#
# TESTS: 048-init_girandola_house.t
#
################################################################################

sub init_girandola_house ($self, %args) {
    return $self unless $self -> size == $DEFAULT_SIZE &&
                        $args {houses} && $args {houses} & $GIRANDOLA;

    $self -> create_house ("GR" => map {cell_name @$_}
                                       [1, 1], [2, 5], [1, 9],
                                       [5, 2], [5, 5], [5, 8],
                                       [9, 1], [8, 5], [9, 9]);
}

################################################################################
#
# sub init_center_dot_house ($self)
#
# An asterisk sudoku has an additional house: one cell from each box.
# This method initializes that house.
#
# An asterisk is defined for a 9 x 9 sudoku as follows:
#
#     . . .  . . .  . . .
#     . * .  . * .  . * .
#     . . .  . . .  . . .
#
#     . . .  . . .  . . .
#     . * .  . * .  . * .
#     . . .  . . .  . . .
#
#     . . .  . . .  . . .
#     . * .  . * .  . * .
#     . . .  . . .  . . .
#
# TESTS: 049-init_center_dot_house.t
#
################################################################################

sub init_center_dot_house ($self, %args) {
    my $width  = $self -> box_width;
    my $height = $self -> box_height;
    my $size   = $self -> size;

    #
    # We can only do center dots if boxes are odd sized width and heigth.
    #
    return $self unless $width % 2 && $height % 2 &&
                        $args {houses} && $args {houses} & $CENTER_DOT;

    my $width_start  = ($width  + 1) / 2;
    my $height_start = ($height + 1) / 2;

    my @center_cells;
    for (my $x = $width_start; $x <= $size; $x += $width) {
        for (my $y = $height_start; $y <= $size; $y += $height) {
            push @center_cells => [$x, $y];
        }
    }

    $self -> create_house ("CD" => map {cell_name @$_} @center_cells);
}


################################################################################
#
# sub init_diagonals ($self)
#
# If we have diagonals, it means cells on one or more diagonals 
# should differ. This method initializes the houses for that.
#
# The main diagonal for a 9 x 9 sudoku is defined as follows:
#
#     * . .  . . .  . . .
#     . * .  . . .  . . .
#     . . *  . . .  . . .
#
#     . . .  * . .  . . .
#     . . .  . * .  . . .
#     . . .  . . *  . . .
#
#     . . .  . . .  * . .
#     . . .  . . .  . * .
#     . . .  . . .  . . *
#
# The minor diagonal for a 9 x 9 sudoku is defined as follows:
#
#     . . .  . . .  . . *
#     . . .  . . .  . * .
#     . . .  . . .  * . .
#
#     . . .  . . *  . . .
#     . . .  . * .  . . .
#     . . .  * . .  . . .
#
#     . . *  . . .  . . .
#     . * .  . . .  . . .
#     * . .  . . .  . . .
#
# TESTS: 050-init_diagonals.t
#
################################################################################


sub init_diagonals ($self, %args) {
    my $diagonals = $args {diagonals} or return $self;

    my $size = $self -> size;

    my sub has_bit ($vec) {$vec =~ /[^\x{00}]/};
    #
    # Top left to bottom right
    #
    if (has_bit ($diagonals &. $MAIN)) {
        $self -> create_house ("DM" => map {cell_name $_, $_} 1 .. $size)
    }

    #
    # Bottom left to top right
    #
    if (has_bit ($diagonals &. $MINOR)) {
        $self -> create_house ("Dm" => map {cell_name $size - $_ + 1, $_}
                                                              1 .. $size)
    }

    #
    # Offsets
    #
    foreach my $s (1 .. $size - 1) {
        my ($sub, $super, $minor_sub, $minor_super) = do {
            no strict 'refs';
            (${"SUB$s"}, ${"SUPER$s"}, ${"MINOR_SUB$s"}, ${"MINOR_SUPER$s"});
        };
        if (has_bit ($diagonals &. $super)) {
            my $name = "DMS$s";
            $self -> create_house ($name =>
                            map {cell_name $_, $_ + $s} 1 .. $size - $s);
        }
        if (has_bit ($diagonals &. $sub)) {
            my $name = "DMs$s";
            $self -> create_house ($name =>
                            map {cell_name $_, $_ - $s} 1 + $s .. $size);
        }
        if (has_bit ($diagonals &. $minor_super)) {
            my $name = "DmS$s";
            $self -> create_house ($name =>
                     map {cell_name $size - $_ + 1, $_ - $s} 1 + $s .. $size);
        }
        if (has_bit ($diagonals &. $minor_sub)) {
            my $name = "Dms$s";
            $self -> create_house ($name =>
                     map {cell_name $size - $_ + 1, $_ + $s} 1 .. $size - $s);
        }
    }

    $self
}


################################################################################
#
# cell2houses ($self, $cell)
#
# Give the name of a cell, return the names of all the houses this cell
# is part off.
#
# TESTS: 040-houses.t
#
################################################################################

sub cell2houses ($self, $cell) {
    keys %{$cell2houses {$self} {$cell} || {}}
}


################################################################################
#
# house2cells ($self, $house)
#
# Give the name of a house, return the names of all the cells in this house.
#
# TESTS: 040-houses.t
#
################################################################################

sub house2cells ($self, $house) {
    keys %{$house2cells {$self} {$house} || {}}
}


################################################################################
#
# cells ($self)
#
# Return the names of all the cells in the sudoku.
#
# TESTS: 040-houses.t
#
################################################################################

sub cells  ($self, $sorted = 0) {
    my @cells = sort keys %{$cell2houses  {$self}};
    if ($sorted) {
        #
        # For each cell, determine how many different clues it sees.
        #
        my %sees;
        foreach my $cell1 (@cells) {
            next if $self -> clue ($cell1);  # Don't care about clues
            foreach my $cell2 (@cells) {
                if ($self -> clue ($cell2) &&
                    $self -> must_differ ($cell1, $cell2)) {
                    $sees {$cell1} {$self -> clue ($cell2)} = 1;
                }
            }
        }

        @cells = map  {$$_ [0]}
                 sort {$$b [1] <=> $$a [1]  ||           # Clues first
                       $$b [2] <=> $$a [2]  ||           # Favour nr clues seen
                       $$b [3] <=> $$a [3]  ||           # More houses is better
                       $$a [0] cmp $$b [0]}
                 map  {
                     [$_,                                # Cell name
                      $self -> clue ($_) ? 1 : 0,        # Is a clue
                      scalar keys (%{$sees {$_} || {}}), # Nr of clues cell sees
                      scalar $self -> cell2houses ($_),  # Nr of houses
                                                         #       cell is in
                     ]
                 }
                 @cells;
    }
    @cells;
}


################################################################################
#
# houses ($self)
#
# Return the names of all the houses in the sudoku.
#
# TESTS: 040-houses.t
#
################################################################################

sub houses ($self) {
    keys %{$house2cells  {$self}}
}


################################################################################
#
# init_clues ($self, %args)
#
# Take the supplied clues (if any!), and return a structure which maps cell
# names to clue values.
#
# The clues could be one of:
#   - A 2-d array, with false values indicating the cell doesn't have a clue.
#     A "." will also be consider to be not a clue.
#   - A string, newlines separating rows, and whitespace clues. A value
#     of 0 or "." indicates no clue.
#
# We wil populate the clues attribute, mapping cell names to clue values.
# Cells without clues won't be set.
#
# TESTS: 080-clues.t
#
################################################################################

sub init_clues ($self, %args) {
    my $in_clues = $args {clues} or return $self;

    my $clues = {};
    #
    # Turn a string into an array
    #
    if (!ref $in_clues) {
        my @rows  = grep {/\S/} split /\n/ => $in_clues;
        $in_clues = [map {[split]} @rows];
    }
    foreach my $r (keys @$in_clues) {
        foreach my $c (keys @{$$in_clues [$r]}) {
            my $val  = $$in_clues [$r] [$c];
            next if !$val || $val eq ".";
            my $cell = cell_name $r + 1, $c + 1;
            $$clues {$cell} = $val;
        }
    }
    $clues {$self} = $clues;

    $self;
}


################################################################################
#
# clues ($self)
#
# Return an hashref mapping cell names to clues.
#
# TESTS: 080-clues.t
#
################################################################################

sub clues ($self) {
    $clues {$self};
}


################################################################################
#
# clue ($self, $cell)
#
# Returns the clue in the given cell. If the cell does not have a clue,
# return false.
#
# TESTS: 080-clues.t
#
################################################################################

sub clue ($self, $cell) {
    $clues {$self} {$cell}
}


################################################################################
#
# init ($self, %args)
#
# Configure the Regexp::Sudoku object. 
#
# TESTS: *.t
#
################################################################################


sub init ($self, %args) {
    #
    # Copy some values into attributes. If they're undefined, that's fine.
    #
    if ($args {size} && $args {size} > $NR_OF_SYMBOLS) {
        $args {size} = $NR_OF_SYMBOLS;
    }

    $self -> init_sizes               (%args)
          -> init_values              (%args)
          -> init_houses              (%args)
          -> init_clues               (%args)
          -> init_subject_and_pattern ();

}


################################################################################
#
# make_clue ($self, $cell, $value)
#
# Given a cell name, and a value, return a sub subject, and sub pattern
# which sets the capture '$cell' to '$value'
#
# TESTS: 110-make_clue.t
#        120-make_cell.t
#
################################################################################

sub make_clue ($self, $cell, $value) {
    my $subsub = $value;
    my $subpat = "(?<$cell>$value)";

    map {$_ . $SENTINEL} $subsub, $subpat;
}


################################################################################
#
# make_empty ($cell)
#
# Given a cell name, return a sub subject and a sub pattern allowing the
# cell to pick up one of the values in the sudoku.
#
# TESTS: 100-make_empty.t
#        120-make_cell.t
#
################################################################################

sub make_empty ($self, $cell) {
    my $subsub = $self -> values;
    my $range  = $self -> values_range;
    my $subpat = "[$range]*(?<$cell>[$range])[$range]*";

    map {$_ . $SENTINEL} $subsub, $subpat;
}


################################################################################
#
# make_cell ($cell)
#
# Given a cell name, return a subsubject and subpattern to set a value for
# this cell. Either the cell has a clue (and we dispatch to make_clue),
# or not (and we dispatch to make_empty).
#
# TESTS: 120-make_cell.t
#
################################################################################

sub make_cell ($self, $cell) {
    my $clue = $self -> clue ($cell);

    $clue ? $self -> make_clue  ($cell, $clue)
          : $self -> make_empty ($cell);
}



################################################################################
#
# semi_debruijn_seq
#
# Return, for the given values, a De Bruijn sequence of size 2 with
#  1) Duplicates removed and
#  2) The first character copied to the end
#
# TESTS: 130-semi_debruijn_seq.t
#
################################################################################

sub semi_debruijn_seq ($self, $values = $values {$self}) {
    state $cache;
    $$cache {$values} //= do {
        my $seq = debruijn ($values, 2);
        $seq .= substr $seq, 0, 1;  # Copy first char to the end.
        $seq  =~ s/(.)\g{1}/$1/g;   # Remove duplicates.
        $seq;
    };
}



################################################################################
#
# make_diff_clause ($self, $cell1, $cell2)
#
# Given two cell names, return a sub subject and a sub pattern which matches
# iff the values in the cell differ.
#
# TESTS: 140-make_diff_clause.t
#
################################################################################

sub make_diff_clause ($self, $cell1, $cell2) {
    my $subsub = "";
    my @values = $self -> values;
    my $range  = $self -> values_range;

    my $seq = $self -> semi_debruijn_seq;
    my $pat = "[$range]*\\g{$cell1}\\g{$cell2}[$range]*";

    map {$_ . $SENTINEL} $seq, $pat;
}


################################################################################
#
# must_differ ($self, $cell1, $cell2)
#
# Returns a true value if the two given cells must have different values.
#
# TESTS: 150-must_differ.t
#
################################################################################

sub must_differ ($self, $cell1, $cell2) {
    my %seen;
    $seen {$_} ++ for $self -> cell2houses ($cell1),
                      $self -> cell2houses ($cell2);

   (grep {$_ > 1} values %seen) ? 1 : 0;
}


################################################################################
#
# init_subject_and_pattern ($self)
#
# Create the subject we're going to match against, and the pattern
# we use to match.
#
# TESTS: TODO
#
################################################################################

sub init_subject_and_pattern ($self) {
    my $subject  = "";
    my $pattern = "";

    my @cells   = $self -> cells (1);

    for my $i (keys @cells) {
        #
        # First the part which picks up a value for this cell
        #
        my $cell1 = $cells [$i];

        my ($subsub, $subpat) = $self -> make_cell ($cell1);
        $subject .= $subsub;
        $pattern .= $subpat;

        #
        # Now, for all the previous cells, if they must differ,
        # add a clause for that.
        #
        for my $j (0 .. $i - 1) {
            my $cell2 = $cells [$j];
            #
            # If both cells are a clue, we don't need a restriction
            # between the cells.
            #
            next if $self -> clue ($cell1) && $self -> clue ($cell2);

            if ($self -> must_differ ($cell1, $cell2)) {
                my ($subsub, $subpat) =
                             $self -> make_diff_clause ($cell1, $cell2);
                $subject .= $subsub;
                $pattern .= $subpat;
            }
        }
    }

    $subject {$self} =       $subject;
    $pattern {$self} = "^" . $pattern . '$';

    $self;
}


################################################################################
#
# subject ($self)
#
# Return the subject we're matching against.
#
# TESTS: Test.pm
#
################################################################################

sub subject ($self) {
    $subject {$self}
}


################################################################################
#
# pattern ($self)
#
# Return the pattern we're matching with.
#
# TESTS: Test.pm
#
################################################################################

sub pattern ($self) {
    $pattern {$self}
}

__END__

=head1 NAME

Regexp::Sudoku - Abstract

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

=head1 TODO

=head1 SEE ALSO

=head1 DEVELOPMENT

The current sources of this module are found on github,
L<< git://github.com/Abigail/Regexp-Sudoku.git >>.

=head1 AUTHOR

Abigail, L<< mailto:cpan@abigail.freedom.nl >>.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2021 by Abigail.

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
