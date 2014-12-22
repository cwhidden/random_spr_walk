in_file=`mktemp`;
for file in `find walks/random_walks/ -name 'commute_time_all*'`; do
	echo $file;
	name=`echo $file | sed 's/\/commute_time_all_[0-9]*//; s/^.*\///'`;
	out_file=figs/$name-commute-all
	interesting_file=interesting_trees/${name}.rooted.tre
	if [ ! -f $interesting_file ]; then
		interesting_file=""
	fi
	echo "num1,num2,MAT,MATERR,MCT,MCTERR" > $in_file;
	cat $file >> $in_file;
	R --vanilla < plot_MCT.r --args $in_file $out_file $interesting_file
	echo ${out_file}.pdf
	echo;
done
# clean up
rm $in_file
