rule polyA_removal:
    input:
        lambda wildcards: os.path.join(
            config['output_dir'], 
            "pychopper" if config["include_pychopper"] else "samples",
            "merged_full_length_cDNA" if config["include_pychopper"] else "",
            "{sample}_merged_cDNA.fastq" if config["include_pychopper"] else "{sample}_concat.fastq"
        )
    output:
        polyA = os.path.join(config['output_dir'], "pychopper", "polyA_removed", "{sample}_polyA_removed.fastq"),
        total_reads = temp(os.path.join(config['tmp_dir'], "read_counts", "{sample}", "{sample}_total_reads_polyA.tsv"))
    conda:
        "../envs/trimming.yml"
    threads:
        config["max_threads"]
    resources:
        mem_mb = 10240, # 10GB
        runtime = 60
    log:
        os.path.join(config["log_dir"], "polyA_removed", "{sample}.log")
    shell:
        """
        cutadapt \
        -a "A{{10}}" \
        -e 1 \
        -j {threads} \
        -o {output.polyA} \
        {input}
        # Count total reads
        num_reads=$(($(wc -l < "{output.polyA}") / 4))
        # Put into a temporary file
        echo -e "Sample\tReads_Post_PolyA\n{wildcards.sample}\t$num_reads" > {output.total_reads}
        """
