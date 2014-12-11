# note: process_mrbayes_posteriors.bash and mean_access_time.pl are part of https://github.com/cwhidden/sprspace
#for n in {4..7}; do
for n in {7..7}; do

	echo processing $n-taxa;
	walk_dir=walks/random_walks/$n-taxa
	tangle_file=../curvature/tangle/rooted-symmetric/tangle$n.idx 
	ricci_file=../curvature/results-rspr/ricci$n.mat

	# make the tree list of tangletype trees only
	tree_list=`mktemp`;
	num1=`awk '{print $1,$3}' $tangle_file | sort -g | uniq | wc -l`
	(
		awk '{print $1,$3}' $tangle_file |
				sort -g |
				uniq;
		awk '{print $1,$3}' $tangle_file |
				sort -g |
				uniq;
		awk '{print $2,$4}' $tangle_file |
				sort -g  |
				uniq;
	) |
			sort -g |
			uniq -c |
			sort -k1,1gr -k2,2g |
#			sed 's/;//' |
			awk '{print $2,$3}' > $tree_list
	num2=`cat $tree_list | wc -l`;


top_dir=`pwd`;
cd $walk_dir

(for run in run*; do
	input_trees=`mktemp`
	grep '(' $run/stationarity_* | sed 's/^/tree /' > $input_trees
	process_mrbayes_posterior_for_commute_time.bash $run $input_trees $input_trees 0
	data=$run;
	trees=$dir/$test/$DATASET/nchains_$NCHAINS/all_moves/g_r_test/;
	mean_access_time.pl --num_trees $num1 --num_trees_2 $num2 --tree_list <(awk '{print $2}' $tree_list | convert_tree.pl $top_dir/convert_list) < $run/uniq_trees_T |
			grep -- '->' |
			grep -v 'inf' |
			perl -e '
				open(NUM_FILE, "<$ARGV[0]");
				my @convert = ();
				my $i = 0;
				while(<NUM_FILE>) {
					my ($num) = split();
					$convert[$i] = $num;
					$i++;
				}
				close(NUM_FILE);

				my $line = 0;
				while(<STDIN>) {
					if ($line == 0) {
						print;
						$line++;
						next;
					}
					chomp;
					my @vals = split();
					$vals[0] = $convert[$vals[0]];
					$vals[2] = $convert[$vals[2]];
					print "@vals\n";
					$line++;
				}
			' $tree_list
	rm $input_trees
done) |
		sed 's/ -> /-/' |
		sort -V |
		sed 's/\s\+/,/g' |
		perl $top_dir/averages_with_standard_error.pl 1 |
		cut -d, -f2- |
		sed 's/-/,/' |
		cat > commute_time_$n

		cd - > /dev/null;





	perl ./combine_curvature_commute.pl $walk_dir/commute_time_$n $ricci_file > $walk_dir/commute$n.mat

	# cleanup temp file
	rm $tree_list
done

