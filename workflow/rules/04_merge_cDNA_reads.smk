rule merge_cDNA_reads:
    input:
        full_length1 = os.path.join(config['output_dir'], "pychopper", "full_length", "{sample}_full_length1_cDNA.fastq"), 
        full_length2 = os.path.join(config['output_dir'], "pychopper", "full_length", "{sample}_full_length2_cDNA.fastq"),
        rescued1 = os.path.join(config['output_dir'], "pychopper", "rescued", "{sample}_rescued1.fastq"),
        rescued2 = os.path.join(config['output_dir'], "pychopper", "rescued", "{sample}_rescued2.fastq")
    output:
        merged_fastq = os.path.join(config['output_dir'], "pychopper", "merged_full_length_cDNA", "{sample}_merged_cDNA.fastq"),
        total_reads = temp(os.path.join(config["tmp_dir"], "read_counts", "{sample}", "{sample}_total_reads_cDNA.tsv"))
    threads:
        1
    resources:
        mem_mb = 1024,
        runtime = 60
    log:
        os.path.join(config['log_dir'], "pychopper", "merge_cDNA_reads", "{sample}", "{sample}.log")
    conda:
        "../envs/generic.yml"
    shell:
        """
        cat {input.full_length1} {input.full_length2} {input.rescued1} {input.rescued2} > {output.merged_fastq}
        # Count total reads
        num_reads=$(($(wc -l < "{output.merged_fastq}") / 4))
        # Put into a temporary file
        echo -e "Sample\tReads_Post_Pychopper\n{wildcards.sample}\t$num_reads" > {output.total_reads}
        """

