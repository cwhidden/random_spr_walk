NITER=10000000
SFREQ=1
NRUNS=5

for file in test/*; do
	filename=`echo $file | sed 's/^.*\///'`;
	n=`echo $filename | grep -o '[0-9]-' | sed 's/-//'`;
	echo $filename 
	
	dirname=`echo $filename | sed 's/\..*//'`;
	dir=walks/random_walks/$n-taxa/$dirname
	echo $dir;
	mkdir -p $dir

	run=1;
	while [ $run -le $NRUNS ]; do
	echo "#!/bin/sh
		echo -en \"\t$run\t...\";
		./random_spr_walk -ntax $n -niterations $NITER -sfreq $SFREQ -tprobs $file > $dir/run${run}_${SFREQ}_${NITER}.t
		echo -e \"\tdone\"
	" | sbatch -t 7-0 -o output/${dirname}_%j
	run=$(($run+1))
	done
	echo "done";
done
