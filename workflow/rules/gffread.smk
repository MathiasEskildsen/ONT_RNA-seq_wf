rule gffread:
    input:
        fasta=config["genome_path"],
        annotation=config["annotation_path"]
    output:
        os.path.join(config["output_dir"], "transcripts", "transcripts.fa")
    threads:
        1
    resources:
        mem_mb = 1024, # 1GB
        runtime = 60
    conda:
        "../envs/gffread.yml"
    log:
        os.path.join(config["log_dir"], "gffread", "transcripts_fasta.log")
    shell:
        """
        gffread {input.annotation} -g {input.fasta} -w {output}
    """
