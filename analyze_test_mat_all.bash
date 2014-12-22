# note: process_mrbayes_posteriors.bash and mean_access_time.pl are part of https://github.com/cwhidden/sprspace

NITER=10000000
SFREQ=1

for file in `ls test/*-equal.rooted.tre | grep -v 6`; do
#for file in `ls test/*-1v5c.rooted.tre test/*-equal.rooted.tre | grep -v 6`; do
	filename=`echo $file | sed 's/^.*\///'`;
	n=`echo $filename | grep -o '[0-9]-' | sed 's/-//'`;
	echo $filename 
	
	dirname=`echo $filename | sed 's/\..*//'`;
	dir=walks/random_walks/$n-taxa/$dirname

	walk_dir=$dir
	tangle_file=../curvature/tangle/rooted-symmetric/tangle$n.idx 
	ricci_file=../curvature/results-rspr/ricci$n.mat

	tree_list=`pwd`/../curvature/tangle/rooted-symmetric/tree$n.tre

	num=`cat $tree_list | wc -l`;


top_dir=`pwd`;
cd $walk_dir

(for run in run*; do
	echo -en "$run\t..." 1>&2
	input_trees=`mktemp`;
##	grep '(' $run/${run}_${SFREQ}_${NITER}.t | sed 's/^/tree /' > $input_trees
##	process_mrbayes_posterior_for_commute_time.bash $run $input_trees $input_trees 0
	data=$run;
	cat $run/uniq_trees_T |
			mean_access_time.pl --num_trees $num --num_trees_2 $num --tree_list $tree_list |
			grep -- '->' |
			grep -v 'inf'
##	rm $input_trees
	echo -e "\tdone" 1>&2
done) |
		sed 's/ -> /-/' |
		sort -V |
		sed 's/\s\+/,/g' |
		perl $top_dir/averages_with_standard_error.pl 1 |
		cut -d, -f2- |
		sed 's/-/,/' |
		cat > commute_time_all_$n

		cd - > /dev/null;

##	perl ./combine_curvature_commute.pl $walk_dir/commute_time_$n $ricci_file > $walk_dir/commute$n.mat

	echo done
done

