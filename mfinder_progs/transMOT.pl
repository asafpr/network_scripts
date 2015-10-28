#!/usr/bin/perl -w
use Getopt::Long;
use Switch;
use Storable;

$file =shift;#  mot_68264.sortu 
$trans_file =shift; # prot2index.txt
$output_file = "$file.out";

open (TRANS, $trans_file) || die ("can't open $trans_file arg file");
while ($line=<TRANS>){
    chomp $line;
    @arr=split('\t',$line);
    $trans{$arr[1]}=$arr[0];
}

close(TRANS);

open (IND, $file) || die ("can't open $file arg file");
open (OUT, ">$output_file") || die ("Can't open $output_file for writing!");

#%trans = %{ retrieve($trans_file) };

while (<IND>){
  chomp;
  @w = split/[ \t]+/;
  
  for $i (0 .. $#w){
    if (exists $trans{$w[$i]}){
      print OUT "$trans{$w[$i]}\t";
    }
    else {
      print "no value for key $w[$i]\n";
    }
  }
  print OUT "\n";
}

