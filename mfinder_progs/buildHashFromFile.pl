#!/usr/bin/perl 

use strict;
use Storable;

#################################
# Written by Gali, 16/3/06
# Program: Get a file which is tab seperated, key index, value index and output file name.
#          Build hash from the file, using the indices, and store it to output file.
#          value_is_list - if the value we want to hash is list, hash of lists will be built.
#################################


if (@ARGV < 5) { die "Usage: $0 <input_file> <key_ind> <value_ind> <output_file> <value_is_list [0/1]>\n";}

my $input = shift;
my $key_ind=shift;
my $val_ind=shift;
my $output=shift;
my $value_is_list=shift;

open (IN, "$input") || die ("Can't open $input input file!\n");
open (OUT, ">>$output") || die ("Can't open $output file for writing!\n");

my %hash;

while (<IN>) {
  chomp;

  my @w = split('\t');
  if($value_is_list){
    my @list =  split(/\|/,$w[$val_ind]);
    $hash{$w[$key_ind]} = [@list];
  }
  else{
    $hash{$w[$key_ind]}=$w[$val_ind];
  }
}

store (\%hash,"$output");


# save a hash:
#store(\%hash_name, "file_name");
#open a hash:
#%hash_name = %{ retrieve("file_name") };
