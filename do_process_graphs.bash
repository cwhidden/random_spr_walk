NITER=10000000
SFREQ=1

mkdir -p output/process_graph
top_dir=`pwd`
for file in test/*.rooted.tre; do
	filename=`echo $file | sed 's/^.*\///'`;
	n=`echo $filename | grep -o '[0-9]-' | sed 's/-//'`;
	echo $filename 
	
	dirname=`echo $filename | sed 's/\..*//'`;
	dir=walks/random_walks/$n-taxa/$dirname

	cd $dir

# todo: only do this once
for run in run*; do
	echo -en "$run\t..." 1>&2
	cd $run
	input_trees=${dirname}.${run}.t
	input_likelihoods=${dirname}.${run}.p
	grep '(' ${run}_${SFREQ}_${NITER}.t |
			sed 's/^/tree /' > $input_trees
	# todo: put in the real likelihoods
	cat $input_trees | awk '{print $2" "$2" "$3}' > $input_likelihoods
	cd ..
	echo -e "done" 1>&2
done

	cd $top_dir

	echo "#!/bin/sh
	process_mrbayes_posteriors.bash $dir $dir 1.0 0;
	process_graph.sh $dir 4096 -rooted" |
	sbatch -t 7-0 -o output/process_graph/${dirname}
done

