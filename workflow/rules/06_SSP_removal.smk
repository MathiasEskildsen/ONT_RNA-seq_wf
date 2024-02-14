rule SSP_removal:
    input:
        os.path.join(config["output_pychopper"], "polyA_removed", "{sample}_polyA_removed.fastq")
    output:
        os.path.join(config["output_pychopper"], "SSP_removed", "{sample}_SSP_removed.fastq")
    params:
        SSP = config["SSP_sequence"] # Primer sequence for strand-switching primer in ONT direct cDNA protocol. Might be prone to change in the future. So check if it match the specific protocol used.
    threads:
        config["max_threads"]
    resources:
        mem_mb = 10480, # 10 GB
        runtime = "01:00:00" # 1 hour
    log:
        os.path.join(config["log_dir"], "logs", "{sample}_SSP_removed.log")
    shell:
        """
        cutadapt \
        -g {params.SSP} \
        -e 1 \
        -j {threads} \
        -o {output} \
        ${input}
        """
