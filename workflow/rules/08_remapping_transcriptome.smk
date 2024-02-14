rule mapping_transcriptome:
    input:
        remapped_reads = os.path.join(config["output_mapping"], "remapped", "{sample}_genome.fastq"),
        transcripts = os.path.join(config["output_dir"], "transcripts", "transcripts.fa")
    output:
        mapped_transcriptome = os.path.join(config["output_mapping"], "transcriptome", "{sample}_transcriptome.sam"),
        sorted_bam = os.path.join(config["output_mapping"], "transcriptome", "{sample}_transcriptome.bam")
    conda:
        "../envs/mapping.yml"
    threads:
         config["max_threads"]
    resources:
        mem_mb = 20480, # 20GB
        runtime = "1-00:00:00" # 1 day
    log:
        os.path.join(config["log_dir"], "mapping_transcriptome", "{sample}.log")
    shell:
        """
        minimap2 \
        -ax splice \
        -p 0.99 \
        -k14 \
        --MD \
        -t {threads} \
        {input.transcripts} \
        {input.remapped_reads} \
        > {output.mapped_transcriptome}
        samtools \
        view -bS \
        {output.mapped_transcriptome} \
        | samtools \
        sort \
        | samtools \
        index {output.sorted_bam}
        """