#!/usr/bin/bash

DIR=genomes
IFS=,
N=1
RUN=$(cat samples.info | while read BASE FWD REV
do
	if [ ! -f $DIR/${BASE}.sorted.fasta ]; then
		sleep 0
		#echo "Missing asm $BASE ($N)"
		echo "$N"
	fi
	N=$(expr $N + 1)
done | perl -p -e 's/\n/,/' | perl -p -e 's/,$//')

echo "sbatch --array=$RUN pipeline/02_AAFTF.sh"
