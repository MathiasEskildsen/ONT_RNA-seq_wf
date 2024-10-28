rule SSP_removal:
    input:
        os.path.join(config['output_dir'], "pychopper", "polyA_removed", "{sample}_polyA_removed.fastq")
    output:
        SSP = os.path.join(config['output_dir'], "pychopper", "{sample}", "{sample}_SSP_removed.fastq"),
        total_reads = os.path.join(config['tmp_dir'], "read_counts", "{sample}", "{sample}_total_reads_SSP_removed.tsv")
    params:
        SSP = config["SSP_sequence"] # Primer sequence for strand-switching primer in ONT direct cDNA protocol. Might be prone to change in the future. So check if it match the specific protocol used.
    threads:
        config["max_threads"]
    conda:
        "../envs/trimming.yml"
    resources:
        mem_mb = 10240, # 10 GB
        runtime = 60 # 1 hour
    log:
        os.path.join(config["log_dir"], "logs", "{sample}_SSP_removed.log")
    shell:
        """
        cutadapt \
        -g {params.SSP} \
        -e 1 \
        -j {threads} \
        -o {output.SSP} \
        {input}
        # Count total reads
        num_reads=$(($(wc -l < "{output.SSP}") / 4))
        # Put into a temporary file
        echo -e "Sample\tReads_Post_SSP\n{wildcards.sample}\t$num_reads" > {output.total_reads}
        """