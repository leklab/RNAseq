
workflow RNAseq {

	File inputSamplesFile
  	Array[Array[String]] inputSamples = read_tsv(inputSamplesFile)

  	String genes_gtf
  	String exons_bed

  	String rsem_index
  	String star_index


  	String run_STAR
  	String run_md
  	String run_RSEM
  	String rnaseqcfile
  	String plotscript

  	scatter (sample in inputSamples) {

		call star {
			input:
				star_index = star_index,
				sample = sample[0],
				fastq1 = sample[1],
				fastq2 = sample[2],
				run_STAR =run_STAR

		}

		call markdDuplicates{
			input:
				run_md = run_md,
				input_bam = star.bam_file,
				input_bam_index = star.bam_index,
				sample = sample[0]
		}

		call rsem {
			input:
				run_RSEM = run_RSEM,
				rsem_index = rsem_index,
				input_bam = star.transcriptome_bam,
				sample = sample[0]
		}

		call rnaseqc{
			input:
				input_bam = markdDuplicates.bam_file,
				input_bam_index = markdDuplicates.bam_index,
				genes_gtf = genes_gtf,
				exons_bed = exons_bed,
				sample = sample[0],
				rnaseqcfile = rnaseqcfile
		}

  	 
	}

	call plotqc {
		input:
			qc_results = rnaseqc.qc,
			plotscript = plotscript
	}




	output {

		Array[File] md_bam = markdDuplicates.bam_file
		Array[File] md_bam_index = markdDuplicates.bam_index
		Array[File] md_metricx = markdDuplicates.metrics
		Array[File] transcriptome_bam = star.transcriptome_bam
		#Array[File] chimeric_junctions = star.chimeric_junctions
		#Array[File] chimeric_bam_file = star.chimeric_bam_file
		#Array[File] chimeric_bam_index = star.chimeric_bam_index
		Array[File] junctions = star.junctions
		Array[File]	junctions_pass1 = star.junctions_pass1
		Array[File] read_counts = star.read_counts
		Array[Array[File]] logs = star.logs
		Array[File] genes = rsem.genes
		Array[File] isoforms = rsem.isoforms
		Array[File] qc = rnaseqc.qc
		File nb = plotqc.nb
		File expr = plotqc.expr
	        File metrics = plotqc.metrics

  	}


}


# TASK DEFINITIONS

task star {
  String star_index
  String fastq1
  String fastq2
  String sample
  String run_STAR

  command {
    python ${run_STAR} \
        ${star_index} \
        ${fastq1} \
        ${fastq2} \
        ${sample} \
        --threads 16 \
        --output_dir .
  }

  runtime {
    cpus: 16
    requested_memory: 64000
  }
  output {
    File bam_file = "${sample}.Aligned.sortedByCoord.out.bam"
    File bam_index = "${sample}.Aligned.sortedByCoord.out.bam.bai"
    File transcriptome_bam = "${sample}.Aligned.toTranscriptome.out.bam"
    #File chimeric_junctions = "${sample}.Chimeric.out.junction"
    #File chimeric_bam_file = "${sample}.Chimeric.out.sorted.bam"
    #File chimeric_bam_index = "${sample}.Chimeric.out.sorted.bam.bai"
    File read_counts = "${sample}.ReadsPerGene.out.tab"
    File junctions = "${sample}.SJ.out.tab"
    File junctions_pass1 = "${sample}._STARpass1/SJ.out.tab"
    Array[File] logs = ["${sample}.Log.final.out", "${sample}.Log.out", "${sample}.Log.progress.out"]
  }
}

task markdDuplicates {

	String run_md
	File input_bam
	File input_bam_index
	String sample


	command {
		python  ${run_md} \
        	--jar $EBROOTPICARD/picard.jar \
        	${input_bam} \
        	${sample}.Aligned.sortedByCoord.out.md \
        	--output_dir .

		java -jar $EBROOTPICARD/picard.jar BuildBamIndex I=${sample}.Aligned.sortedByCoord.out.md.bam
	}
	
	runtime {
	    cpus: 4
	    requested_memory: 16000
  	}
  	
  	output {
        File bam_file = "${sample}.Aligned.sortedByCoord.out.md.bam"
        File bam_index = "${sample}.Aligned.sortedByCoord.out.md.bai"
        File metrics = "${sample}.Aligned.sortedByCoord.out.md.marked_dup_metrics.txt"
  	}
	
}

task rsem {

	String run_RSEM
	String rsem_index
	File input_bam
	String sample


	command {
		python ${run_RSEM} \
        	${rsem_index} \
        	${input_bam} \
        	${sample} \
        	--threads 16
    }
	
	runtime {
	    cpus: 16
	    requested_memory: 64000
  	}
  	
  	output {
        File genes="${sample}.rsem.genes.results"
        File isoforms="${sample}.rsem.isoforms.results"
  	}
	
}

task rnaseqc {

	String rnaseqcfile
	String genes_gtf
	File input_bam
	File input_bam_index
	String exons_bed
	String sample


	command {
		
		${rnaseqcfile} ${genes_gtf} ${input_bam} ${sample}_QC -vv --coverage --bed ${exons_bed} -s ${sample}
		tar -czvf ${sample}_QC.tar.gz ${sample}_QC
    	}
	
	runtime {
	    cpus: 4
	    requested_memory: 8000
  	}
  	
  	output {
        File qc ="${sample}_QC.tar.gz"
  	}
	
}

task plotqc {

	Array[File] qc_results
	String plotscript


	command {
		
                cp ${sep=' ' qc_results} .

                for filename in *.tar.gz
                do
                        tar zxf $filename
                done

                dir=`dirname ${plotscript}`
                export PYTHONPATH=$PYTHONPATH:$dir

                python ${plotscript} *_QC project_QC.ipynb

    } 
	
	runtime {
	    cpus: 4
	    requested_memory: 8000
  	}
  	
  	output {
        File nb ="project_QC.ipynb"
        File expr = "project_expression_df.csv"
        File metrics = "project_metrics.csv"
  	}
	
}


