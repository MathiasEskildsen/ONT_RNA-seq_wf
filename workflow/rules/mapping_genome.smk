rule mapping_genome:
    input:
        os.path.join(config["output_pychopper"], "SSP_removed", "{sample}_SSP_removed.fastq")
    output:
        mapped_genome = os.path.join(config["output_mapping"], "genome", "{sample}_genome.sam"),
        bamtofastq = os.path.join(config["output_mapping"], "genome", "{sample}_genome.fastq")
    params:
        genome_path = config["genome_path"]
    conda:
        "../envs/mapping.yml"
    threads:
         config["max_threads"]
    resources:
        mem_mb = 10240
    log:
        os.path.join(config["log_dir"], "mapping_genome", "{sample}.log")
    shell:
        """
        minimap2 \
        -ax splice \
        -p 0.9 \
        -k14 \
        --MD \
        -t {threads} \
        {params.genome_path} \
        {input} \
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