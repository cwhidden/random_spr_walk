for n in  4 {6..10}; do
	walk_dir=walks/random_walks/$n-taxa
	walk_file=stationarity_$n
	grep -h '(' $walk_dir/stationarity_$n_* | sed 's/^/tree /' > $walk_dir/$walk_file
	process_mrbayes_posterior_for_commute_time.bash $walk_dir $walk_dir/$walk_file $walk_dir/$walk_file 0
	mean_access_time.pl --tree_list <( sed 's/;//' < ~/Research/tangle/tangletypes/tree$n.tre | convert_tree.pl convert_list) < $walk_dir/uniq_trees_T > $walk_dir/commute_time_$n
	perl combine_curvature_commute.pl $walk_dir/commute_time_$n ../curvature/results/ricci$n.mat > $walk_dir/commute$n.mat
done
