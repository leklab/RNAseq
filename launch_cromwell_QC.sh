#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH -J launch_cromwell
#SBATCH --mem=8000

java -Dconfig.file=/gpfs/ycga/project/ysm/lek/shared/tools/cromwell_wdl/slurm.conf -jar \
/gpfs/ycga/project/ysm/lek/shared/tools/jars/cromwell-36.jar run \
/gpfs/ycga/project/ysm/lek/shared/tools/RNAseq/rnaseqc.wdl \
-i rnaseqc_inputs.json \
-o cromwell.options
