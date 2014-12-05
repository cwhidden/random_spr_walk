for n in {4..7}; do

	echo processing $n-taxa;
	walk_dir=walks/random_walks/$n-taxa
	walk_file=stationarity_$n
	tangle_file=../curvature/tangle/rooted-symmetric/tangle$n.idx 
	ricci_file=../curvature/results-rspr/ricci$n.mat

	# make the tree list of tangletype trees only
	tree_list=`mktemp`;
###	num1=`awk '{print $1,$3}' ../curvature/tangles/tangle$n.idx | sort -g | uniq | wc -l`
###	(
###		awk '{print $1,$3}' ../curvature/tangles/tangle$n.idx |
###				sort -g |
###				uniq;
###		awk '{print $1,$3}' ../curvature/tangles/tangle$n.idx |
###				sort -g |
###				uniq;
###		awk '{print $2,$4}' ../curvature/tangles/tangle$n.idx |
###				sort -g  |
###				uniq;
###	) |
###			sort -g |
###			uniq -c |
###			sort -k1,1gr -k2,2g |
####			sed 's/;//' |
###			awk '{print $2,$3}' > $tree_list
###	num2=`cat $tree_list | wc -l`;
###
###	grep -h '(' $walk_dir/stationarity_${n}_* | sed 's/^/tree /' > $walk_dir/$walk_file
###	echo -e "\t"`wc -l $walk_dir/$walk_file | awk '{print $1}'`" trees";
###	process_mrbayes_posterior_for_commute_time.bash $walk_dir $walk_dir/$walk_file $walk_dir/$walk_file 0
###	mean_access_time.pl --num_trees $num1 --num_trees_2 $num2 --tree_list <(awk '{print $2}' $tree_list | convert_tree.pl convert_list) < $walk_dir/uniq_trees_T |
###			perl -e '
###				open(NUM_FILE, "<$ARGV[0]");
###				my @convert = ();
###				my $i = 0;
###				while(<NUM_FILE>) {
###					my ($num) = split();
###					$convert[$i] = $num;
###					$i++;
###				}
###				close(NUM_FILE);
###
###				my $line = 0;
###				while(<STDIN>) {
###					if ($line == 0) {
###						print;
###						$line++;
###						next;
###					}
###					chomp;
###					my @vals = split();
###					$vals[0] = $convert[$vals[0]];
###					$vals[2] = $convert[$vals[2]];
###					print "@vals\n";
###					$line++;
###				}
###			' $tree_list > $walk_dir/commute_time_$n

	perl combine_curvature_commute.pl $walk_dir/commute_time_$n $ricci_file > $walk_dir/commute$n.mat

	# cleanup temp file
	rm $tree_list
done

