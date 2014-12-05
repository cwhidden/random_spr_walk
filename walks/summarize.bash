for i in {4..10}; do
	echo -ne "$i:\t";
	temp=`mktemp`
	cat random_walks/${i}-taxa/stationarity_${i}_* |
			grep -o '(.*;' |
			sort |
			uniq -c |
			awk '{print $1}' > $temp
			cat $temp | awk 'BEGIN{MIN=1000000000; MAX=0; SUM=0} $1 < MIN {MIN=$1} $1 > MAX {MAX=$1} {SUM += $1} END{print "MIN="MIN"\tMAX="MAX"\tUNIQUE="NR"\tTOTAL="SUM}' | perl -pe 'chomp;'
			cat $temp | averages_with_standard_error.pl -1 | awk -F, '{printf "\tMEAN=%.3f\tSTDERR=%.3f\n", $1, $2}'
	rm $temp
done
