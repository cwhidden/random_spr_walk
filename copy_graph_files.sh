out_dir=./spr_graphs
for dir in `find walks/random_walks/*-taxa/*/ -name 'spr_graphs'`; do
	echo $dir
	name=`echo $dir | grep -o '[^/]*\/[^/]*$'`;
	echo $name;
	name=`echo $name | grep -o '^[^/]*'`
	echo $name;
	echo;

	file=$dir/graph.csv
	out_file=$out_dir/${name}.graph.csv
	if [ ! -f $out_file ] || [ "$1" = "-f" ]; then
		echo copied $file;
		cp $file $out_file;
	else
		echo $out_file already exists ;
	fi

	file=$dir/graph_attr.tab
	out_file=$out_dir/${name}.graph.attr.tab
	if [ ! -f $out_file ] || [ "$1" = "-f" ]; then
		echo copied $file;
		cat $file |
				awk 'BEGIN {OFS="\t"}; NR == 1 {print $0,"sqrt_size","log_size"}; NR > 1 {print $0,sqrt($5),log($5)/log(10)}' > $out_file;
	else
		echo $out_file already exists ;
	fi
	echo;
done


