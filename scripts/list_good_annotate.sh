#!/usr/bin/bash

STATFILE=assembly_stats.tsv
m=$(for n in `tail -n +2 $STATFILE | awk '$11 > 25000000 {print $1}'` ; do 
 if [ ! -f annotate/${n}/predict_results/Rhizopus_stolonifer_${n}.proteins.fa ]; then
	 grep -n "$n," samples.info | awk -F: '{print $1}' 
 fi
done | sort -n | perl -p -e 's/\n/,/g;' | perl -p -e 's/,$//')
echo "sbatch --array=$m pipeline/04_predict.sh"

