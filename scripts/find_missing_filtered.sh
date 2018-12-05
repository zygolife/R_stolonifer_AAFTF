#!/usr/bin/bash

DIR=working_AAFTF
IFS=,
N=1
while read BASE FWD REV
do
	if [ ! -f $DIR/${BASE}_filtered_1.fastq.gz ]; then
		echo "Missing $BASE ($N)"
	fi
	N=$(expr $N + 1)
done < samples.info
