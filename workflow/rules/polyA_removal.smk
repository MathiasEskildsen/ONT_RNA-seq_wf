rule polyA_removal:
    input:
        os.path.join(config["output_pychopper"], "merged", "{sample}_merged_cDNA.fastq")
    output:
        os.path.join(config["output_pychopper"], "polyA_removed", "{sample}_polyA_removed.fastq")
    conda:
        "../envs/trimming.yml"
    threads:
        config["max_threads"]
    log:
        os.path.join(config["log_dir"], "polyA_removed", "{sample}.log")
    shell:
        """
        cutadapt \
        -a "A{{10}}" \
        -e 1 \
        -j {threads} \
        -o {output} \
        {input}
        """
