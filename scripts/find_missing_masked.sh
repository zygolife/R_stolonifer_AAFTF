#!/usr/bin/bash

DIR=genomes
IFS=,
N=1
m=$(while read BASE FWD REV
do
	if [[ ! -f $DIR/${BASE}.sorted.fasta ]]; then
		echo "skipping $BASE it is missing an assembly" 1>2 
	elif [ ! -f $DIR/${BASE}.masked.fasta ]; then
		echo "Missing asm $BASE ($N)" 1>2
		echo $N
	fi
	N=$(expr $N + 1)
done < samples.info | perl -p -e 's/\n/,/' | perl -p -e 's/,$//')
echo "sbatch --array=$m pipeline/03_mask.sh"
