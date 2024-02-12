rule SSP_removal:
    input:
        os.path.join(config["output_pychopper"], "polyA_removed", "{sample}_polyA_removed.fastq")
    output:
        os.path.join(config["output_pychopper"], "SSP_removed", "{sample}_SSP_removed.fastq")
    params:
        SSP = config["SSP_sequence"]
    threads:
        config["max_threads"]
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
