rule merge_cDNA_reads:
    input:
        full_length1 = os.path.join(config["output_pychopper"], "full_length", "{sample}_full_length1_cDNA.fastq"), 
        full_length2 = os.path.join(config["output_pychopper"], "full_length", "{sample}_full_length2_cDNA.fastq"),
        rescued1 = os.path.join(config["output_pychopper"], "rescued", "{sample}_rescued1.fastq"),
        rescued2 = os.path.join(config["output_pychopper"], "rescued", "{sample}_rescued2.fastq")
    output:
        os.path.join(config["output_pychopper"], "merged", "{sample}_merged_cDNA.fastq")
    threads:
        1
    shell:
        """
        cat {input.full_length1} {input.full_length2} {input.rescued1} {input.rescued2} > {output}
        """
