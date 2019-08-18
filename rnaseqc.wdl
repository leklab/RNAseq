
workflow RNASeQC {

	File inputSamplesFile
  	Array[Array[String]] inputSamples = read_tsv(inputSamplesFile)

  	String genes_gtf
  	String exons_bed


  	String rnaseqcfile
  	String plotscript

  	scatter (sample in inputSamples) {

		call rnaseqc{
			input:
				input_bam = sample[1],
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

		Array[File] qc = rnaseqc.qc
		File nb = plotqc.nb
		File expr = plotqc.expr
        File metrics = plotqc.metrics

  	}


}


task rnaseqc {

	String rnaseqcfile
	String genes_gtf
	String input_bam
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


