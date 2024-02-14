rule salmon_quant:
    input:
        reads = os.path.join(config["output_mapping"], "transcriptome", "{sample}_transcriptome.bam"),
        transcripts = os.path.join(config["output_dir"], "transcripts", "transcripts.fa")
    output:
        quant = os.path.join(config["output_salmon"], "{sample}", "{sample}_quant.sf"),
        lib = os.path.join(config["output_salmon"], "{sample}", "{sample}_lib_format_counts.json")
    params:
        lib_type = config["lib_type"] # Type of sequencing library. Standard is "A", where Salmon checks itself. See https://salmon.readthedocs.io/en/latest/salmon.html # What's this LIBTYPE
    conda:
        "../envs/gene_abundance_estimation.yml"
    threads:
        config["max_threads"]
    resources:
        mem_mb = 20480, # 20GB
        runtime = "1-00:00:00" # 1 day
    log:
        os.path.join(config["log_dir"], "salmon", "{sample}.log")
    shell:
        """
        salmon quant \
        -t {input.transcripts} \
        -l {params.lib_type} \
        -a {input.reads} \
        -o {output.quant} \
        --noErrorModel \
        --threads {threads}
        """
