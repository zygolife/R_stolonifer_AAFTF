This set is for De novo assembled and cleaned R.stolonifer genomes. It utillizes AAFTF for cleanup and assembly.
Data files are large so are not included in the repository but will be archived under BioProject; XXXX

* 01_AAFTF_filter.sh

This script run AAFTF steps for filtering contaminants, quality trimming reads and preparing dataset for assembly
Because in some projects we have had a lot of Bacteria contamination and the number of possible reference bacteria genomes
we use to screen the reads ends up requiring a lot of memory by BBTools bbduk - I have separated this step
and allow it to use alot of memory

This expects to be run as slurm array jobs where the number passed into the array corresponds
to the line in the samples.info file

* 02_AAFTF.sh
This script runs genome assembly for the Rhizopus stolonifer project
It uses AAFTF https://github.com/stajichlab/AAFTF
which relies on other software like spades and pilon
The steps are intended to be run all at one time but it can restart if a process has failed
or run out of runtime (rmdup and pilon can be very slow if a very fragmented assembly)
The steps are to:
- run the assembly
- remove vector sequence and split contigs if necessary
- remove contamination using sourmash to quickly screen for known bacteria signatures
   this screens at the Phylum level so for this project we set it to Mucoromycota and if
   any contigs have strong matches outside this phylum they are remove as well as
   very low coverage contigs
 - remove duplicate contigs by searching all vs all of contigs < N50
 - run pilon to polish the assembly
 - sort and rename contigs largest to smallest
 currently min contig size is 1000 bp but 500 bp can work okay too

This expects to be run as slurm array jobs where the number passed into the array corresponds
to the line in the samples.info file

* 03_mask.sh
This script runs Funannotate mask step
Because this a project focused on population genomics we are assuming the repeat library
generated for one R.stolonifer is suitable for all to save time this is used
This expects to be run as slurm array jobs where the number passed into the array corresponds
to the line in the samples.info file

* 04_predict.sh
This script runs funannotate predict steps - if you need specialized runs with raw RNAseq you will need to tweak
but this is a good quick annotation run
the slowest aspect is currently the protein to gene model spliced alignments which is a function of
the size of the informant.aa file. Smaller file of just swissprot plus one or two proteomes of close species
probably would be smarter but I am running a large set of Rhizopus proteins and it is perhaps overkill
in general these runs take ~12 hrs per genome and 90% of that is the protein alignment + spliced alignment runs
This expects to be run as slurm array jobs where the number passed into the array corresponds
to the line in the samples.info file

* 05_BUSCO.sh
This generates summary BUSCO for the genome assemblies

This expects to be run as slurm array jobs where the number passed into the array corresponds
to the line in the samples.info file

Jason Stajich
