#!/bin/bash
#SBATCH --nodes 1 --ntasks 8 --mem 96gb -J RstolAsmAAFTF --out logs/asm_AAFTF.%a.log -p intel --time 48:00:00

# This script runs genome assembly for the Rhizopus stolonifer project
# It uses AAFTF https://github.com/stajichlab/AAFTF
# which relies on other software like spades and pilon
# The steps are intended to be run all at one time but it can restart if a process has failed
# or run out of runtime (rmdup and pilon can be very slow if a very fragmented assembly)
# The steps are to:
# - run the assembly
# - remove vector sequence and split contigs if necessary
# - remove contamination using sourmash to quickly screen for known bacteria signatures
#   this screens at the Phylum level so for this project we set it to Mucoromycota and if 
#   any contigs have strong matches outside this phylum they are remove as well as
#   very low coverage contigs
# - remove duplicate contigs by searching all vs all of contigs < N50
# - run pilon to polish the assembly
# - sort and rename contigs largest to smallest
# currntly min contig size is 1000 bp but 500 bp can work okay too

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

LEFT=$WORKDIR/${BASE}_filtered_1.fastq.gz
RIGHT=$WORKDIR/${BASE}_filtered_2.fastq.gz

mkdir -p $WORKDIR
mkdir -p /scratch/$USER
echo "$BASE"
if [ ! -f $ASMFILE ]; then    
    if [ ! -f $LEFT ]; then
	echo "Cannot find LEFT $LEFT or RIGHT $RIGHT - did you run 01_AAFTF_filter.sh"
	exit
    fi
    AAFTF assemble -c $CPU --left $LEFT --right $RIGHT  \
	-o $ASMFILE -w $WORKDIR/spades_$BASE --spades_tmpdir /scratch/$USER
    
    if [ -s $ASMFILE ]; then
	rm -rf $WORKDIR/spades_${BASE}
    else
	echo "SPADES must have failed, exiting"
	exit
    fi
fi

if [ ! -f $VECCLEAN ]; then
    AAFTF vecscreen -i $ASMFILE -c $CPU -o $VECCLEAN 
fi

if [ ! -f $PURGE ]; then
    AAFTF sourpurge -i $VECCLEAN -o $PURGE -c $CPU --phylum $PHYLUM --left $LEFT  --right $RIGHT
fi

if [ ! -f $CLEANDUP ]; then
   AAFTF rmdup -i $PURGE -o $CLEANDUP -c $CPU -m 1000
fi

if [ ! -f $PILON ]; then
   AAFTF pilon -i $CLEANDUP -o $PILON -c $CPU --left $LEFT  --right $RIGHT 
fi

if [ ! -f $PILON ]; then
    echo "Error running Pilon, did not create file. Exiting"
    exit
fi

if [ ! -f $SORTED ]; then
    AAFTF sort -i $PILON -o $SORTED
fi

if [ ! -f $STATS ]; then
    AAFTF assess -i $SORTED -r $STATS
fi

done
