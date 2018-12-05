#!/bin/bash
#SBATCH --nodes 1 --ntasks 16 --mem 96gb -J filterAAFTF --out logs/AAFTF_filter.%a.log -p batch --time 8:00:00

# This script run AAFTF steps for filtering contaminants, quality trimming reads and preparing dataset for assembly
# Because in some projects we have had a lot of Bacteria contamination and the number of possible reference bacteria genomes
# we use to screen the reads ends up requiring a lot of memory by BBTools bbduk - I have separated this step
# and allow it to use alot of memory

# This expects to be run as slurm array jobs where the number passed into the array corresponds
# to the line in the samples.info file

hostname
MEM=96
CPU=$SLURM_CPUS_ON_NODE
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi

module load AAFTF
FASTQDIR=input
SAMPLEFILE=samples.info
PHYLUM=Mucoromycota
ASM=genomes

mkdir -p $ASM

if [ -z $CPU ]; then
    CPU=1
fi
IFS=,
sed -n ${N}p $SAMPLEFILE | while read BASE FWD REV
do
ASMFILE=$ASM/${BASE}.spades.fasta
WORKDIR=working_AAFTF
VECCLEAN=$ASM/${BASE}.vecscreen.fasta
PURGE=$ASM/${BASE}.sourpurge.fasta
CLEANDUP=$ASM/${BASE}.rmdup.fasta
PILON=$ASM/${BASE}.pilon.fasta
SORTED=$ASM/${BASE}.sorted.fasta
STATS=$ASM/${BASE}.sorted.stats.txt
LEFTTRIM=$WORKDIR/${BASE}_1P.fastq.gz
RIGHTTRIM=$WORKDIR/${BASE}_2P.fastq.gz

LEFT=$WORKDIR/${BASE}_filtered_1.fastq.gz
RIGHT=$WORKDIR/${BASE}_filtered_2.fastq.gz

mkdir -p $WORKDIR

echo "$BASE"
if [ ! -f $ASMFILE ]; then    
    if [ ! -f $LEFT ]; then
	echo "$FASTQDIR/$FWD $FASTQDIR/$REV for $BASE"
	if [ ! -f $LEFTTRIM ]; then
	    AAFTF trim --method bbduk --memory $MEM --left $FASTQDIR/$FWD --right $FASTQDIR/$REV -c $CPU -o $WORKDIR/${BASE} -ml 50
	fi
	echo "$LEFTTRIM $RIGHTTRIM"
	AAFTF filter -c $CPU --memory $MEM -o $WORKDIR/${BASE} --left $LEFTTRIM --right $RIGHTTRIM --aligner bbduk -a NC_010943.1 CP014274.1 CP017483.1 CP011305.1 CP022053.1 CP007638.1 CP023269.1 NC_000964.3 NC_004461.1 NC_000964.3 NZ_LN831029.1 NZ_CP021111.1 NZ_LT907988.1
	#
	echo "$LEFT $RIGHT"
	unlink $LEFTTRIM
	unlink $RIGHTTRIM
    fi
fi
done
