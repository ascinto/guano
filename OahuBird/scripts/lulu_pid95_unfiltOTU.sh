#!/bin/bash

#SBATCH -D /mnt/lustre/macmaneslab/devon/guano/NAU/OahuBird/lulu/pid95Unfilt
#SBATCH -p macmanes,shared
#SBATCH --job-name="ampLulu_pid95unfilt"
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --output=lulu_pid95Unfilt.log

module purge
module load linuxbrew/colsa
PATH=/mnt/lustre/macmaneslab/devon/bin:$PATH

srun echo "      /\^._.^/\     starting process: `date`"

amptk lulu \
-i /mnt/lustre/macmaneslab/devon/guano/NAU/OahuBird/clust/all/OahuBird.otu_table.txt \
-f /mnt/lustre/macmaneslab/devon/guano/NAU/OahuBird/clust/all/OahuBird.cluster.otus.fa \
-o pid95Unfilt \
--min_match 95
echo "      /\^._.^/\     ending process: `date`"
