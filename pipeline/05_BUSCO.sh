#!/usr/bin/bash
#SBATCH --nodes 1 --ntasks 8 --mem 16G --time 24:00:00 --out logs/busco.%a.log -J busco
# This generates summary BUSCO for the genome assemblies
# # This expects to be run as slurm array jobs where the number passed into the array corresponds
# to the line in the samples.info file
module load busco

# for augustus training
export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config

CPU=${SLURM_CPUS_ON_NODE}
N=${SLURM_ARRAY_TASK_ID}
if [ ! $CPU ]; then
     CPU=2
fi

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi

if [ -z ${SLURM_ARRAY_JOB_ID} ]; then
        SLURM_ARRAY_JOB_ID=$$
fi
GENOMEFOLDER=genomes
EXT=sorted.fasta
BUSCODB=/srv/projects/db/BUSCO/v9/
LINEAGE=$BUSCODB/fungi_odb9
OUTFOLDER=BUSCO
TEMP=/scratch/${SLURM_ARRAY_JOB_ID}_${N}
mkdir -p $TEMP
SAMPLEFILE=samples.info
NAME=$(sed -n ${N}p $SAMPLEFILE | awk -F, '{print $1}')
SEED_SPECIES=rhizopus_stolonifer
GENOMEFILE=$(realpath $GENOMEFOLDER/${NAME}.${EXT})
LINEAGE=$(realpath $LINEAGE)
mkdir -p $OUTFOLDER
if [ -d "$OUTFOLDER/run_${NAME}" ];  then
    echo "Already have run $NAME in folder busco - do you need to delete it to rerun?"
    exit
else
    pushd $OUTFOLDER
    busco.py -i $GENOMEFILE -l $LINEAGE -o $NAME -m geno --cpu $CPU --tmp $TEMP -sp $SEED_SPECIES
    popd
fi

rm -rf $TEMP
