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

	# copy graph attributes, adding sqrt_size, log_size, uniq_id fields
	file=$dir/graph_attr.tab
	out_file=$out_dir/${name}.graph.attr.tab
	if [ ! -f $out_file ] || [ "$1" = "-f" ]; then
		echo copied $file;
		cat $file |
				awk 'BEGIN {OFS="\t"}; NR == 1 {print $0,"sqrt_size","log_size"}; NR > 1 {print $0,sqrt($5),log($5)/log(10)}' | 
				perl -e '
						my $NR = 1;
						while(<>) {
							chomp;
							my @field = split();
							print;
							if ($NR > 1) {
								my $line = $field[0]+1;
								my $tree = `head -n $line '$dir'/../uniq_shapes_C_sorted_by_PP | tail -n1 | grep -o '\''(.*)'\''`;
								my $new_num = `grep -no "$tree" test/'$name'.rooted.tre | grep -o '\''^[0-9]*'\''`;
								my $new_num = $new_num-1;
								print "\t$new_num\n";
							}
							else {
								print "\tuniq_id\n";
							}
							$NR++;
						}' > $out_file;
	else
		echo $out_file already exists ;
	fi
	echo;
done


