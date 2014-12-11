
for n in {5..6}; do
	(
		echo "num1 num2 tree1 tree2 distance curvature MAT MATERR MCT MCTERR";
		column -t walks/random_walks/${n}-taxa/commute${n}.mat |
				sort -k5,5g
	) > walks/random_walks/${n}-taxa/commute${n}.frac.mat
#				awk '{$5 = ""; print}' |

	R --vanilla < plot_curvature_MCT.r --args walks/random_walks/${n}-taxa/commute${n}.frac.mat figs/commute${n}

done
