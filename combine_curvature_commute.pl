my $commute = "walks/random_walks/4-taxa/commute_time_4";
my $curvature = "../curvature/results/ricci4.mat";

if ($#ARGV < 1) { 
	die "usage: combine_curvature_commute.pl <commute_file> <curvature_file>\n";
}
else {
	$commute = $ARGV[0];
	$curvature = $ARGV[1];
}

open(COMMUTE, "<$commute") or die " could not open $commute\n";
open(CURVATURE, "<$curvature") or die " could not open $commute\n";

my @MAT = ();
my @MCT = ();

while(<COMMUTE>) {
	chomp;
	my ($start, $arrow, $end, $mat, $mct) = split();
	for my $i ($#MCT..$start) {
		push(@MCT, []);
	}
	for my $i ($#MAT..$start) {
		push(@MAT, []);
	}
	$MAT[$start][$end] = $mat;
	$MCT[$start][$end] = $mct;
}

#for my $i (0..$#MCT) {
#	for my $j (0..$#MCT) {
#		print "$i\t$j\t$MCT[$i][$j]\n";
#	}
#}

while(<CURVATURE>) {
	chomp;
	my ($start, $end) = split();
	print;
	print "\t";
	print $MAT[$start][$end];
	print "\t";
	print $MCT[$start][$end];
	print "\n";
}

exit;

#curvature
#0	0	(((1,2),3),4);	(((1,2),3),4);	12	0	-
#0	12	(((1,2),3),4);	(1,((2,4),3));	12	2	9/10
#0	10	(((1,2),3),4);	((1,(2,3)),4);	12	1	9/10
#0	14	(((1,2),3),4);	(1,((2,3),4));	12	1	4/5
#0	13	(((1,2),3),4);	(1,(2,(3,4)));	12	2	17/20
#0	2	(((1,2),3),4);	((1,(2,4)),3);	12	1	4/5
#0	4	(((1,2),3),4);	(((1,2),4),3);	12	1	9/10
#0	3	(((1,2),3),4);	((1,2),(3,4));	12	1	3/4
#0	7	(((1,2),3),4);	((1,3),(2,4));	12	1	3/4
#3	3	((1,2),(3,4));	((1,2),(3,4));	3	0	-
#
#commute 
#0 -> 0	16.07346956161	32.14693912322
#0 -> 1	14.9941275511636	29.9994050716466
#0 -> 2	14.9931269765357	30.0015535181288
