# RNAseq
Pipeline for RNAseq data processing. Pipeline is implemented by Sander Pajusalu, Lek Lab, Yale. 

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

To be compatible with human references downloaded from gtex I have used the following versions:
```
module load RSEM/1.3.0-foss-2016b
module load STAR/2.5.3a-foss-2016b
module load picard/2.9.0-Java-1.8.0_121
module load Python/3.5.1-foss-2016b
module load SAMtools/1.9-foss-2016b
```
These were saved into module collection `star` by `module save star253`.

Plotting script needs many python modules installed, see [here](https://github.com/broadinstitute/rnaseqc/tree/master/python). One way is to use conda environment. Make sure if you use conda environment not to have version or installed python modules issues between python installs.

# Building indices for STAR and RSEM

This has to be done only once per genome.
Scripts `makeRSEMindex.sh` and `makeSTARindex.sh` were used.

# Running the pipeline

First prepare the sample sheet. It has three columns: `SampleID|fastq1|fastq2`, make sure that fastq files have absolute paths.

I prefer to copy `RNAseq.inputs.json`, `launch_cromwell.sh` and `cromwell.options` file into working directory. No need to copy wdl. Make sure that all the files are correct and updated if needed.

And then you are ready to launch the script.

`sbatch launch_cromwell.sh`

# Outputs

The whole pipeline finished in 3h45min for 15 sample RNAseq project.

After the successfull completion of the pipeline, the outputs are buried into `RNAseq` directory (subdirectory of what you specified in `cromwell.options`). As the output directory still follows the directory structure from cromwell-executions, then it is best to move outputs to different directory, this can be achieved by the following.

```
mkdir output
find RNAseq/800514a8-8d1f-4d84-a99d-0525a8dfc5ae/ -type f -exec mv {} output/ \; #change hash to your project
rm output/std*
```

Now for each sample you should have the following output files:
```
${sample}.Aligned.sortedByCoord.out.md.bai
${sample}.Aligned.sortedByCoord.out.md.bam
${sample}.Aligned.sortedByCoord.out.md.marked_dup_metrics.txt
${sample}.Aligned.toTranscriptome.out.bam
${sample}.Log.final.out
${sample}.Log.out
${sample}.Log.progress.out
${sample}_QC.tar.gz
${sample}.ReadsPerGene.out.tab
${sample}.rsem.genes.results
${sample}.rsem.isoforms.results
${sample}.SJ.out.tab
```
In addition you have three quality metrics files for the project:
```
project_expression_df.csv
project_metrics.csv
project_QC.ipynb
```
The project_QC.ipynb is a python notebook, which can be opened either by launching jupyter server or by other tools like [Pineapple](https://nwhitehead.github.io/pineapple/). The python notebook has many QC plots.

# Running only QC

If you already have bams and you want to run only QC on them use `rnaseqc.wdl` with the corresponding inputs and launch files. The input `bams.list` has to be a tsv file with two columns: a) sample_name b) absolute path to bam file.

Moreover, if you have run RNASeqQC, but just want to make new plots, then you can just run the following command on interactive node. Be sure to have python3 and all necessary python modules in your environment.

```
#Only needed when you have QC as tar archives:
for filename in *.tar.gz
do
    tar zxf $filename
done

python /gpfs/ycga/project/lek/shared/tools/RNAseq/python_scripts/plot.py *_QC project_QC.ipynb
```

If you want to add cohorts to QC plots, then provide additional argument `-c cohorts.tsv`, where cohorts.tsv has two columns, sample ID and cohort.
