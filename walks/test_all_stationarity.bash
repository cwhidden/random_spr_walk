iter=10000000;
freq=1;
out=stationarity

for i in 4 5 6 7; do
	echo "#!/bin/sh
		time ../random_spr_walk -ntax $i -niterations ${iter} -sfreq ${freq}" | sbatch -c 1 -t 2-0 -o random_walks/$i-taxa/${out}_${i}_${freq}_'%j'
done
	
