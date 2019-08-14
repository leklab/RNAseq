#!/bin/bash
#SBATCH -n 1
#SBATCH -c 16
#SBATCH -J vep
#SBATCH --mem=64000

module load STAR/2.7.1a-foss-2016b

STAR --runThreadN 16 \
    --runMode genomeGenerate \
    --genomeDir starIndex_GRCm38.p6 \
    --genomeFastaFiles GRCm38.p6.genome.fa \
    --sjdbGTFfile gencode.vM22.annotation.gtf \
    --sjdbOverhang 100 
