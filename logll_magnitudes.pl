my $prev = 0;
while(<>) {
	chomp;
	if ($prev != 0) {
		printf("%.2f,%.2f,", $prev, $_);
		print exp($_ - $prev);
		print "\n";
	}
	$prev = $_;
}
