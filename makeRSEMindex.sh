#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH -J rsem
#SBATCH --mem=32000

module restore star

rsem-prepare-reference \
        GRCm38.p6.genome.fa \
        rsem_reference \
        --gtf gencode.vM22.annotation.gtf \
        --num-threads 4
