#! /usr/bin/perl -w
#use strict;
use GD::Simple;

$in=shift@ARGV;
$pval=shift@ARGV;
$directness=shift@ARGV; # 0 undirected: 1 = pp, 2,4 = regulation, directed = all reglation
#$undirected=shift@ARGV; # 1 (only one value)
#$directed=shift@ARGV; # 24 / 124 (one to three values)
$out = shift@ARGV;

$counter=0;

$cx=0;
$cy=0;

$pen = GD::Simple->new(650,750);
$pen->penSize(3,3);

$numpages=1;
if ($directness){
    
    $ch{1}='red';    
    $ch{2}='green';
    $ch{3}='peru';
    $ch{4}='blue';
    $ch{5}='darkviolet';
    $ch{6}='cyan';
    $ch{7}='black';
}

else {
    $ch{1}='black';    
    $ch{2}='red';
    $ch{4}='green';
    $ch{6}='blue';
}

open (D,"<$in") || die;
while( $line = <D> ){
    chomp $line;
    if ($line =~m/.*\|.*/){
	@arr=split('\t' ,$line);
	if ((scalar @arr)==8){
	    if ($arr[5]<=$pval) {
		prepare_plot();
		if ($directness){
		    plot3d($arr[6]);
		}
		else {
		    plot3ud($arr[6]);
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
sub prepare_plot{
  
    $xmoves=$counter%5;
    $ymoves=int($counter/5);
    $cx=$xmoves * 130;
    $cy=$ymoves * 130;

    $pen->fgcolor('black');
    $pen->moveTo(0,90+$cy);
    $pen->lineTo(650,90+$cy);

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


    $pen->fgcolor('black');
    $pen->moveTo(2+$cx,12+$cy);
    $pen->string("$arr[5]");
    $pen->moveTo(48+$cx,12+$cy);
    $pen->string("$arr[7]");
    $pen->moveTo(2+$cx,24+$cy);
    $pen->string("$arr[1]");
}
sub plot3ud{    
    $data = $_[0];  
    @ardata=split(" ",$data);
    if ($ardata[2]!=0){
	draw($ardata[2],48,22,30,60,0,0);
    }
    
    if ($ardata[3]!=0){
	draw($ardata[3],52,78,30,60,-6,0);
    }
    if ($ardata[5]!=0){
	draw($ardata[5],22,48,60,30,-12,0);
    }
    if ($ardata[7]!=0){
	draw($ardata[7],28,65,70,70,0,-9);
    }
    if ($ardata[9]!=0){
	draw($ardata[9],78,52,60,30,5,0);
    }
    if ($ardata[10]!=0){
	draw($ardata[10],65,28,70,70,0,5);
    }
}


sub plot3d{

    $data = $_[0];  
    @ardata=split(" ",$data);
    
    # HERE    
    if ($ardata[2]!=0){
	draw($ardata[2],48,22,30,60,0,0);
    }
    if ($ardata[3]!=0){
	draw($ardata[3],52,78,30,60,-6,0);
    }
    if ($ardata[5]!=0){
	draw($ardata[5],22,48,60,30,-12,0);
    }
    if ($ardata[7]!=0){
	draw($ardata[7],28,65,70,70,0,-9);
    }
    if ($ardata[9]!=0){
	draw($ardata[9],78,52,60,30,5,0);
    }
    if ($ardata[10]!=0){
	draw($ardata[10],65,28,70,70,0,-2);
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

sub draw{

    ($color,$x1,$x2,$y1,$y2,$addx,$addy)=@_;
    
    $pen->fgcolor($ch{$color});
    $pen->moveTo($x1+3+$addx+$cx,$y1+3+$addy+$cy);
    $pen->lineTo($x2+3+$addx+$cx,$y2+3+$addy+$cy);
    $pen->moveTo($x2+3+$addx+$cx,$y2+3+$addy+$cy);
    $pen->ellipse(5,5);
}
