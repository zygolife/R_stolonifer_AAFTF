#!/usr/bin/bash

DIR=genomes
IFS=,
N=1
m=$(cat samples.info | while read BASE FWD REV
do
	if [ ! -f $DIR/${BASE}.sorted.fasta ]; then
		sleep 0
#		echo "Missing asm $BASE ($N)" 1>&2
#		echo -n "$N,"
	fi
	N=$(expr $N + 1)
done)
echo $m
