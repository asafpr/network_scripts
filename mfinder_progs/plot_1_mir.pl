#! /usr/bin/perl -w
#use strict;
use GD::Simple;

$in=shift@ARGV;
$size=shift@ARGV;
$pval=shift@ARGV;
$out = shift@ARGV;

$counter=0;

$cx=0;
$cy=0;

$pen = GD::Simple->new(650,750);
$pen->penSize(3,3);

$numpages=1;

$ch{1}='blue';
$ch{2}='black';
$ch{5}='red';
$ch{7}='green';

open (D,"<$in") || die;
while( $line = <D> ){
    chomp $line;
    if ($line =~m/.*\|.*/){
	@arr=split('\t' ,$line);
	if ((scalar @arr)==8){
	    if ($arr[5]<=$pval){
		if ($size==3) {
		    plot3($arr[6]);
		}
		elsif($size==4){
		    plot4($arr[6]);
		}
		else {

		    die "wrong size of motif (should be 3 or 4)\n";
		}
		$counter++;
		if($counter>30){
		    $counter=0;
		    print_page();
		    $pen = GD::Simple->new(650,750);
		    $pen->penSize(3,3);
		    $numpages++;
		}
		print "$arr[6]\n";
	    }
	}	
    }
}
close(D);

print_page();
#open(P,">$out.png") or die;
# make sure we are writing to a binary stream
#binmode P;
#print P $pen->png;
#close(P);

sub plot3 {
    $data = $_[0];
    $xmoves=$counter%5;
    $ymoves=int($counter/5);
    $cx=$xmoves * 130;
    $cy=$ymoves * 130;

    #print "$xmoves $ymoves\n";
	$pen->fgcolor('black');
	$pen->moveTo(0,90+$cy);
	$pen->lineTo(650,90+$cy);

#	$pen->line(0+
#print "$cx $cy\n";

    $pen->bgcolor('white');
    $pen->fgcolor('black');
    $pen->moveTo(20+$cx,70+$cy);
    $pen->ellipse(10,10);
    
    $pen->bgcolor('white');
    $pen->fgcolor('black');
    $pen->moveTo(80+$cx,70+$cy);
    $pen->ellipse(10,10);
    
    $pen->bgcolor('white');
    $pen->fgcolor('black');
    $pen->moveTo(50+$cx,20+$cy);
    $pen->ellipse(10,10);
    #print "$data\n";
    #$data =~ tr/" "//;
    #print "$data\n";
    @ardata=split(" ",$data);

    $pen->fgcolor('black');
    $pen->moveTo(2+$cx,12+$cy);
    $pen->string("$arr[5]");
    $pen->moveTo(48+$cx,12+$cy);
    $pen->string("$arr[7]");

    if ($ardata[2]!=0){
	$pen->fgcolor($ch{$ardata[2]});
	$pen->moveTo(48+$cx,30+$cy);
	$pen->lineTo(22+$cx,60+$cy);

	if ($ardata[2]==2){
	    $pen->fgcolor($ch{$ardata[2]});
	    $pen->moveTo(22+$cx,60+$cy);
	    $pen->ellipse(5,5);
	}
    }

    if ($ardata[3]!=0){
	
	$pen->fgcolor($ch{$ardata[3]});
	$pen->moveTo(52+$cx,30+$cy);
	$pen->lineTo(78+$cx,60+$cy);

	if ($ardata[3]==2){
	    $pen->fgcolor('black');
	    #$pen->fgcolor($ch{$ardata[5]});
	    $pen->moveTo(78+$cx,60+$cy);
	    $pen->ellipse(5,5);
	}
    }

     if ($ardata[5]!=0){
	#  print "ff $ardata[2] t\n";
	$pen->fgcolor($ch{$ardata[5]});
	$pen->moveTo(48+$cx,30+$cy);
	$pen->lineTo(22+$cx,60+$cy);

	if ($ardata[5]==2){
	$pen->fgcolor($ch{$ardata[5]});
	$pen->moveTo(48+$cx,30+$cy);
	$pen->ellipse(5,5);
	}
    }

    if ($ardata[7]!=0){

	$pen->fgcolor($ch{$ardata[7]});
	$pen->moveTo(28+$cx,70+$cy);
	$pen->lineTo(72+$cx,70+$cy);

	if ($ardata[7]==2){
	$pen->fgcolor($ch{$ardata[7]});
	$pen->moveTo(72+$cx,70+$cy);
	$pen->ellipse(5,5);
	}

    }

   if ($ardata[9]!=0){
	$pen->fgcolor($ch{$ardata[9]});

	$pen->moveTo(52+$cx,30+$cy);
	$pen->lineTo(78+$cx,60+$cy);

	if ($ardata[9]==2){
	$pen->fgcolor($ch{$ardata[9]});
	$pen->moveTo(52+$cx,30+$cy);
	$pen->ellipse(5,5);
	}

    }


  if ($ardata[10]!=0){
	$pen->fgcolor($ch{$ardata[10]});
	
	$pen->moveTo(28+$cx,70+$cy);
	$pen->lineTo(72+$cx,70+$cy);

	if ($ardata[10]==2){
	$pen->fgcolor($ch{$ardata[10]});
	$pen->moveTo(28+$cx,70+$cy);
	$pen->ellipse(5,5);
	}

    }
}

sub plot4 {
    $data = $_[0];
    $xmoves=$counter%5;
    $ymoves=int($counter/5);
    $cx=$xmoves * 130;
    $cy=$ymoves * 130;

    $pen->fgcolor('black');
    $pen->moveTo(0,105+$cy);
    $pen->lineTo(650,105+$cy);

    $pen->bgcolor('white');
    $pen->fgcolor('black');
    $pen->moveTo(25+$cx,75+$cy);
    $pen->ellipse(10,10);
    
    $pen->bgcolor('white');
    $pen->fgcolor('black');
    $pen->moveTo(75+$cx,75+$cy);
    $pen->ellipse(10,10);
    
    $pen->bgcolor('white');
    $pen->fgcolor('black');
    $pen->moveTo(25+$cx,25+$cy);
    $pen->ellipse(10,10);
    @ardata=split(" ",$data);

    $pen->bgcolor('white');
    $pen->fgcolor('black');
    $pen->moveTo(75+$cx,25+$cy);
    $pen->ellipse(10,10);
    @ardata=split(" ",$data);

    $pen->fgcolor('black');
    #$pen->moveTo(30+$cx,12+$cy);
    #$pen->string("$arr[5]");
    $pen->moveTo(2+$cx,12+$cy);
    $pen->string("$arr[5]");
    $pen->moveTo(48+$cx,12+$cy);
    $pen->string("$arr[7]");

    if ($ardata[2]!=0){

	$pen->fgcolor($ch{$ardata[2]});
	$pen->moveTo(33+$cx,23+$cy);
	$pen->lineTo(66+$cx,23+$cy);

	if ($ardata[2]==2){
	    $pen->fgcolor($ch{$ardata[2]});
	    $pen->moveTo(65+$cx,23+$cy);
	    $pen->ellipse(5,5);
	}
    }
    
    if ($ardata[3]!=0){
	
	$pen->fgcolor($ch{$ardata[3]});
	$pen->moveTo(25+$cx,33+$cy);
	$pen->lineTo(25+$cx,66+$cy);

	if ($ardata[3]==2){
	    $pen->fgcolor('black');
	    $pen->moveTo(25+$cx,64+$cy);
	    $pen->ellipse(5,5);
	}
    }

  if ($ardata[4]!=0){
	$pen->fgcolor($ch{$ardata[4]});
	$pen->moveTo(32+$cx,30+$cy);
	$pen->lineTo(71+$cx,65+$cy);
	
	if ($ardata[4]==2){
	    $pen->fgcolor('black');
	    $pen->moveTo(71+$cx,64+$cy);
	    $pen->ellipse(5,5);
	}
    }
    
     if ($ardata[6]!=0){
	 $pen->fgcolor($ch{$ardata[6]});
	 $pen->moveTo(33+$cx,23+$cy);
	 $pen->lineTo(66+$cx,23+$cy);
	 
	 if ($ardata[6]==2){
	     $pen->fgcolor('black');
	     $pen->moveTo(35+$cx,23+$cy);
	     $pen->ellipse(5,5);
	 }
     }
    
    if ($ardata[8]!=0){
	$pen->fgcolor($ch{$ardata[8]});
	$pen->moveTo(68+$cx,30+$cy);
	$pen->lineTo(28+$cx,66+$cy);
	
	if ($ardata[8]==2){
	    $pen->fgcolor($ch{$ardata[8]});
	    $pen->moveTo(31+$cx,64+$cy);
	    $pen->ellipse(5,5);
	}
    }

    if ($ardata[9]!=0){
	$pen->fgcolor($ch{$ardata[9]});
	#$pen->fgcolor("green");
	$pen->moveTo(75+$cx,33+$cy);
	$pen->lineTo(75+$cx,66+$cy);

	if ($ardata[9]==2){
	    $pen->fgcolor($ch{$ardata[9]});
	    $pen->moveTo(75+$cx,64+$cy);
	    $pen->ellipse(5,5);
	}
    }
    
    if ($ardata[11]!=0){
	$pen->fgcolor($ch{$ardata[11]});
	$pen->moveTo(25+$cx,33+$cy);
	$pen->lineTo(25+$cx,66+$cy);

	if ($ardata[11]==2){
	    $pen->fgcolor($ch{$ardata[11]});
	    $pen->moveTo(25+$cx,35+$cy);
	    $pen->ellipse(5,5);
	}
    }

    if ($ardata[12]!=0){
	$pen->fgcolor($ch{$ardata[12]});
	#	$pen->fgcolor("green");
	$pen->moveTo(68+$cx,30+$cy);
	$pen->lineTo(28+$cx,66+$cy);
	
	#$pen->moveTo(75+$cx,33+$cy);
	#$pen->lineTo(75+$cx,66+$cy);


	if ($ardata[12]==2){
	    $pen->fgcolor($ch{$ardata[12]});
	    $pen->moveTo(65+$cx,33+$cy);
	    $pen->ellipse(5,5);
	}
    }

    if ($ardata[14]!=0){
	$pen->fgcolor($ch{$ardata[14]});
	$pen->moveTo(33+$cx,74+$cy);
	$pen->lineTo(70+$cx,74+$cy);
	

	if ($ardata[14]==2){
	    $pen->fgcolor($ch{$ardata[14]});
	    $pen->moveTo(66+$cx,74+$cy);
	    $pen->ellipse(5,5);
	}
    }

    if ($ardata[16]!=0){
	$pen->fgcolor($ch{$ardata[16]});
	$pen->moveTo(32+$cx,30+$cy);
	$pen->lineTo(71+$cx,65+$cy);
	
	if ($ardata[16]==2){
	    $pen->fgcolor($ch{$ardata[16]});
	    $pen->moveTo(32+$cx,30+$cy);
	    $pen->ellipse(5,5);
	}
    }

    if ($ardata[17]!=0){
	$pen->fgcolor($ch{$ardata[17]});
	#$pen->moveTo(68+$cx,30+$cy);
#	$pen->lineTo(28+$cx,66+$cy);
	
	$pen->moveTo(75+$cx,33+$cy);
	$pen->lineTo(75+$cx,66+$cy);


	#$pen->fgcolor("green");
	#$pen->lineTo(28+$cx,96+$cy);
#	$pen->moveTo(68+$cx,30+$cy);
#	$pen->lineTo(28+$cx,66+$cy);

	

	if ($ardata[17]==2){
	    $pen->fgcolor($ch{$ardata[17]});
	    $pen->moveTo(75+$cx,34+$cy);
	    $pen->ellipse(5,5);
	}
    }

    if ($ardata[18]!=0){
	$pen->fgcolor($ch{$ardata[18]});
	$pen->moveTo(33+$cx,74+$cy);
	$pen->lineTo(70+$cx,74+$cy);

	if ($ardata[18]==2){
	    $pen->fgcolor($ch{$ardata[18]});
	    $pen->moveTo(34+$cx,74+$cy);
	    $pen->ellipse(5,5);
	}
    }
}

sub print_page{
    print "print page $numpages\n";
    open(P,">$out.$numpages.png") or die;
    # make sure we are writing to a binary stream
    binmode P;
    print P $pen->png;
    close(P);
    
}
