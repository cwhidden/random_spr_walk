in_file=`mktemp`;
for file in `find walks/random_walks/ -name 'commute_time_all*'`; do
	name=`echo $file | sed 's/\/commute_time_all//; s/^.*\///'`;
	out_file=figs/$name-commute-all
	echo $file;
	echo "num1,num2,MAT,MATERR,MCT,MCTERR" > $in_file;
	cat $file >> $in_file;
	R --vanilla < plot_MCT.r --args $in_file $out_file
	echo ${out_file}.pdf
	echo;
done
# clean up
rm $in_file
