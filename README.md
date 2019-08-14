# RNAseq
Pipeline for RNAseq data processing

# General comments
The pipeline follows [gtex-TOPMed pipeline](https://github.com/broadinstitute/gtex-pipeline/blob/master/TOPMed_RNAseq_pipeline.md), but is optimized for Yale HPC, which uses slurm queueing system.

The python scripts are downloaded from [gtex github](https://github.com/broadinstitute/gtex-pipeline/tree/master/rnaseq/src), the RNA-SeQC was downloaded and setup as instructedf [here](https://github.com/broadinstitute/rnaseqc). The plot script was slightly modified to meet needs, for example metrics and expression databases are now output as csv files. 

The scripts currently use mouse genome, but are applicable for human genome as well.

# Reference files

The gtf and fasta files were downloaded from gencode and unzipped with `gzip -d`

`wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M22/gencode.vM22.annotation.gtf.gz`
`wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M22/GRCm38.p6.genome.fa.gz`

To make collapsed gtf file [gtex instructions and script](https://github.com/broadinstitute/gtex-pipeline/tree/master/gene_model) were used: `python3 collapse_annotation.py gencode.vM22.annotation.gtf gencode.vM22.genes.gtf`

Plotting script needs an exons bed file to assess fragment sizes. This was made by using the following command:
```
cat gencode.vM22.genes.gtf | grep 'exon' | cut -f1,4,5 | sort -V -k1,1 -k2,2 > gencode.vM22.exons.sorted.bed
```


# Modules

The following modules were used on Ruddle cluster.
```
 module load RSEM/1.3.0-foss-2016b
 module load STAR/2.7.1a-foss-2016b
 module load picard/2.9.0-Java-1.8.0_121
 module load Python/3.5.1-foss-2016b
 module load SAMtools/1.9-foss-2016b
```
These were saved into module collection `star` by `module save star`.

Plotting script needs many python modules installed, see [here](https://github.com/broadinstitute/rnaseqc/tree/master/python). One way is to use conda environment.

# Building indices for STAR and RSEM

This has to be done only once per genome.
Scripts `makeRSEMindex.sh` and `makeSTARindex.sh` were used.

# Running the pipeline

First prepare the sample sheet. It has three columns: `SampleID|fastq1|fastq2`, make sure that fastq files have absolute paths.

I prefer to copy `RNAseq.inputs.json`, `launch_cromwell.sh` and `cromwell.options` file into working directory. No need to copy wdl. Make sure that all the files are correct and updated if needed.

And then you are ready to launch the script.

`sbatch launch_cromwell.sh`


