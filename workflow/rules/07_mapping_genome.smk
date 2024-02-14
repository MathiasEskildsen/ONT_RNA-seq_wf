rule mapping_genome:
    input:
        fastq = os.path.join(config["output_pychopper"], "SSP_removed", "{sample}_SSP_removed.fastq"),
        genome = config["genome_path"]
    output:
        mapped_genome = os.path.join(config["output_mapping"], "genome", "{sample}_genome.sam"),
        bamtofastq = os.path.join(config["output_mapping"], "remapped", "{sample}_genome.fastq")
    conda:
        "../envs/mapping.yml"
    threads:
         config["max_threads"]
    resources:
        mem_mb = 20480, # 20GB
        runtime = "1-00:00:00" # 1 day
    log:
        os.path.join(config["log_dir"], "mapping_genome", "{sample}.log")
    shell:
        """
        minimap2 \
        -ax splice \
        -p 0.99 \
        -k14 \
        --MD \
        -t {threads} \
        {input.genome} \
        {input.fastq} \
        > {output.mapped_genome}
        samtools \
        view -bS \
        {output.mapped_genome} \
        | samtools \
        sort \
        | samtools \
        index \
        | bedtools \
        bamtofastq \
        -fq {output.bamtofastq}
        """