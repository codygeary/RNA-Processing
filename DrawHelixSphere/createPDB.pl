#!/usr/bin/env perl   
#  -*- perl -*-

# USAGE:
# perl createPDB.pl positions.txt > output.pdb


# Ebbe Sloth Andersen, esa@inano.au.dk, April 2013
# Updated by Cody Geary April 2016

use strict;
use warnings FATAL => qw ( all );
use Data::Dumper;

# >>>>>>>>>>>>>>>>>> RUN PROGRAM <<<<<<<<<<<<<<<<<<<<

my ( $file, $line, @cols, $ATOM, @ATOM );

( $file ) = @ARGV;

if ( not open FILE, "< $file" ) {
    die "file not found!";
}

while ( $line = <FILE> ) {
    @cols = ( );
    @cols = split(/\s+/, $line);
    if ( defined $cols[0] ) {
        if ( $cols[0] eq "LINE" ) {
            push @ATOM, {
                "c" => $cols[1],
                "r" => $cols[2],
                "x" => $cols[3],
                "y" => $cols[4],
                "z" => $cols[5],
            }
        }
        if ( $cols[0] eq "DOT" ) {
            push @ATOM, {
                "c"  => $cols[1],
                "r"  => $cols[2],
                "x"  => $cols[3],
                "y"  => $cols[4],
                "z"  => $cols[5],
            };
        }
    }
}

#print Dumper ( @ATOM );
#exit;

# PRINT PDB FILE

my $t = 1;
my @CHAIN = ( "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", 
              "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X",
              "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
              "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", 
              "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x",
              "y", "z" );

my $CHAIN = "A";

foreach $CHAIN ( @CHAIN ) {
    foreach $ATOM ( @ATOM ) {
        if ( $CHAIN eq $ATOM->{c} ) {
            printf "%-6s", "ATOM  ";
            printf "%5s", $t;
            print "  P     G $CHAIN";
            printf "%4s", $ATOM->{r};
            print "    ";
            printf "%8s", sprintf("%.3f", $ATOM->{x});
            printf "%8s", sprintf("%.3f", $ATOM->{y});
            printf "%8s", sprintf("%.3f", $ATOM->{z});
            print "  1.00100.00   ";
            print "\n";
            $t++;
        }
    }
}


# PRINT CROSSOVER POINTS

foreach $ATOM ( @ATOM ) {
    if ( $ATOM->{c} eq "Z" ) {
        printf "%-6s", "HETATOM";
        printf "%5s", $t;
        print "  C     G $ATOM->{c}";
        printf "%4s", $ATOM->{r};
        print "    ";
        printf "%8s", sprintf("%.3f", $ATOM->{x});
        printf "%8s", sprintf("%.3f", $ATOM->{y});
        printf "%8s", sprintf("%.3f", $ATOM->{z});
        print "  1.00100.00   ";
        print "\n";
        $t++;
    }

}

print "END\n";
