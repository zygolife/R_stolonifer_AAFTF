#!/bin/bash
#SBATCH -p batch --time 2-0:00:00 --ntasks 8 --nodes 1 --mem 24G --out logs/predict.%a.log
module unload python
module unload perl
module unload perl
module load perl/5.24.0
module load miniconda2
module load funannotate/git-live
module switch mummer/4.0
module unload augustus
module load augustus/3.3
module load lp_solve
module load genemarkHMM
module load diamond
module unload rmblastn
module load ncbi-rmblast/2.6.0
export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
TEMP=/scratch/$USER
mkdir -p $TEMP
AUGUSTUS_SPECIES="rhizopus_stolonifer"
SEED_SPECIES="rhizopus_stolonifer"
SPECIES="Rhizopus stolonifer"
CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

INDIR=genomes
OUTDIR=annotate

SAMPLEFILE=samples.info
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=`wc -l $SAMPLEFILE | awk '{print $1}'`

if [ $N -gt $MAX ]; then
    echo "$N is too big, only $MAX lines in $SAMPLEFILE"
    exit
fi
IFS=,

sed -n ${N}p $SAMPLEFILE | while read BASE FWD REV
do
    if [ ! -f $INDIR/$BASE.masked.fasta ]; then
	echo "No genome for $INDIR/$BASE.masked.fasta yet - run 00_mask.sh $N"
	exit
    fi
    PEPLIB=$(realpath lib/informant.aa)
    GENOMEFILE=$(realpath $INDIR/$BASE.masked.fasta)
    OUTDEST=$(realpath $OUTDIR/$BASE)
    mkdir $TEMP/$BASE.predict.$SLURM_JOB_ID
    pushd $TEMP/$BASE.predict.$SLURM_JOB_ID
    funannotate predict --cpus $CPU --keep_no_stops --SeqCenter UCR \
	--busco_db fungi_odb9 --strain "$BASE" \
	-i $GENOMEFILE --name $BASE \
	--protein_evidence $PEPLIB \
	-s "$SPECIES"  -o $OUTDEST --busco_seed_species $SEED_SPECIES \
	--augustus_species $AUGUSTUS_SPECIES --keep_evm
    popd

    rmdir $TEMP/$BASE.predict.$SLURM_JOB_ID
done
