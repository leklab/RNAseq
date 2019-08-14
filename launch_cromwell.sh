#!/bin/bash
#SBATCH -n 1
#SBATCH -c 8
#SBATCH -J launch_cromwell
#SBATCH --mem=64000

java -Dconfig.file=/gpfs/ycga/project/ysm/lek/shared/tools/cromwell_wdl/slurm.conf -jar \
/gpfs/ycga/project/ysm/lek/shared/tools/jars/cromwell-36.jar run \
/gpfs/ycga/project/ysm/lek/shared/tools/RNAseq/RNAseq.wdl \
-i RNAseq.inputs.json \
-o cromwell.options
