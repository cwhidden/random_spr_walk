
for n in {4..6}; do
	(
		echo "num1 num2 tree1 tree2 distance curvature MAT MCT";
		column -t walks/random_walks/${n}-taxa/commute${n}.mat |
				awk '{$5 = ""; print}' |
				perl -e 'while(<>) { chomp; my @val = split(); my @frac = split("\/", $val[5]); if ($frac[1] > 0) {$val[5] = $frac[0] / $frac[1]; } else {$val[5] = NA} print "@val"; print "\n"; }' |
				sort -k6,6g
	) > walks/random_walks/${n}-taxa/commute${n}.frac.mat

	R --vanilla < plot_curvature_MCT.r --args walks/random_walks/${n}-taxa/commute${n}.frac.mat commute${n}

done
