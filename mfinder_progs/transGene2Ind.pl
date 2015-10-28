#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Switch;
use Storable;

#################
#
# Written by Gali, 9/4/06
# Program: Translate gene acc to numerical index.
#          Usage:  transGene2Ind.pl <gene_file> <trans_file> (.hash file!)
#
#################

if (@ARGV < 2) { die "Usage: $0 <gene_file> <trans_file> (.hash file!)\n";}

my $file =shift;
my $trans_file =shift;

#my $trans_file = "/home/users/galin/networks/EColi_integ_ppi_tri/May_06/data/gene2index.hash";
#my $output_file = "$file.ind";
#my $trans_file = "/home/users/galin/networks/EColi_integ_ppi_tri/May_06/data/gene2index_w_sRNA.hash";
my $output_file = "$file.ind";
#print "out is: $output_file\n";
#open (TRANS, $trans_file) || die ("can't open $trans_file arg file");
open (GENE, $file) || die ("can't open $file arg file");
open (OUT, ">$output_file") || die ("Can't open $output_file for writing!");

my %trans = %{ retrieve($trans_file) };

while (<GENE>){
  chomp;
  my @w = split/[ \t]+/;
#  print "line: @w\n";
  for my $i (0 .. $#w){
    if (exists $trans{$w[$i]}){
      print OUT "$trans{$w[$i]}\t";
    }
    else {
      print "no value for key $w[$i]\n";
    }
  }
  print OUT "\n";
}


