#!/usr/bin/bash
IFS=,
TARGETDIR=input_renamed
mkdir -p $TARGETDIR
while read STRAIN FWD REV
do
	ln -s ../input/$FWD $TARGETDIR/${STRAIN}_R1.fastq.gz
	ln -s ../input/$REV $TARGETDIR/${STRAIN}_R2.fastq.gz
done < samples.info
