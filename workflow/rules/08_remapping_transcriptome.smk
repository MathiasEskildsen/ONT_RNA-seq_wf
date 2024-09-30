rule mapping_transcriptome:
    input:
        remapped_reads = os.path.join(config['output_dir'], "mapping", "genome", "{sample}_genome.fastq"),
        transcripts = os.path.join(config["output_dir"], "transcripts", "transcripts.fa")
    output:
        mapped_transcriptome = os.path.join(config["output_dir"], "mapping", "transcriptome", "{sample}_transcriptome.sam"),
        bam = os.path.join(config['output_dir'], "mapping", "transcriptome", "{sample}_transcriptome.bam"),
        sorted_bam = os.path.join(config["output_dir"], "mapping", "transcriptome", "{sample}_transcriptome_sorted.bam")
    conda:
        "../envs/mapping.yml"
    threads:
         config["max_threads"]
    resources:
        mem_mb = 20480, # 20GB
        runtime = 1440 # 1 day
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
        # convert to sorted.bam file
        samtools \
        view -bS \
        {output.mapped_transcriptome} \
        -o {output.bam} 
        samtools \
        sort \
        {output.bam} \
        -o {output.sorted_bam}
        samtools \
        index {output.sorted_bam}
        """