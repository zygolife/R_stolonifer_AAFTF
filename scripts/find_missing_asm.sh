#!/usr/bin/bash

DIR=genomes
IFS=,
N=1
while read BASE FWD REV
do
	if [ ! -f $DIR/${BASE}.sorted.fasta ]; then
		echo "Missing asm $BASE ($N)"
	fi
	N=$(expr $N + 1)
done < samples.info
