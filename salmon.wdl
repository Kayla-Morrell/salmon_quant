version 1.0
task salmon_index {
    File transcriptome_fasta
    String transcriptome_index_name

    command {
        salmon index -t ${transcriptome_fasta} -i ${transcriptome_index_name}
    }

    runtime {
        docker: "combinelab/salmon:latest"
    }

    output {
        File transcriptome_index = "${transcriptome_index_name}"
    }
}

task salmon_quant {
    File fastq1
    File fastq2
    File transcriptome_index
    String quant_name

    command {
        salmon quant -i ${transcriptome_index} -l A \
        -1 ${fastq1} \
        -2 ${fastq2} \
        -p 8 --validateMappings -o ${quant_name}
    }

    runtime {
        docker: "combinelab/salmon:latest"
    }
}

workflow salmon {
    File transcriptome_fasta
    Array[Array[File]] fastqs
    String transcriptome_index_name

    call salmon_index {
        input:
        transcriptome_fasta = transcriptome_fasta,
        transcriptome_index_name = transcriptome_index_name
    }

    scatter (fastq in fastqs) {
        call salmon_quant {
            input:
            fastq1 = fastq[0],
            fastq2 = fastq[1],
            transcriptome_index = salmon_index.transcriptome_index,
            quant_name = "my_quant"
        }
    }

    meta {
        author: "Kayla Interdonato"
        email : "Kayla.Morrell@roswellpark.org"
        description: "Utilizing the salmon Docker container, perform salmon   quantification."
    }
}
