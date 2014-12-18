# note: process_mrbayes_posteriors.bash and mean_access_time.pl are part of https://github.com/cwhidden/sprspace

NITER=10000000
SFREQ=1

for file in test/*.tre; do
	filename=`echo $file | sed 's/^.*\///'`;
	n=`echo $filename | grep -o '[0-9]-' | sed 's/-//'`;
	echo $filename 
	
	dirname=`echo $filename | sed 's/\..*//'`;
	dir=walks/random_walks/$n-taxa/$dirname

	walk_dir=$dir
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
	echo -en "$run\t..." 1>&2
	input_trees=`mktemp`
	grep '(' $run/${run}_${SFREQ}_${NITER}.t | sed 's/^/tree /' > $input_trees
	process_mrbayes_posterior_for_commute_time.bash $run $input_trees $input_trees 0
	data=$run;
	mean_access_time.pl --num_trees $num1 --num_trees_2 $num2 --tree_list <(awk '{print $2}' $tree_list) < $run/uniq_trees_T |
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
	echo -e "\tdone" 1>&2
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
	echo done
done

