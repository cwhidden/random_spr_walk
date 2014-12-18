out_dir=../curvature/results-rspr/commute-onesplit
for file in `find walks/random_walks/*-taxa/*/ -name '*.mat'`; do
	echo $file;
	name=`echo $file | grep -o '[^/]*\/[^/]*$'`;
	name=`echo $name | grep -o '^[^/]*'`.tsv
	out_file=$out_dir/$name
	if [ ! -f $out_file ] || [ "$1" = "-f" ]; then
		echo copied $name;
		cp $file $out_file;
	else
		echo $name already exists ;
	fi
	echo;
done


