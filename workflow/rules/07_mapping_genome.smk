rule mapping_genome:
    input:
        fastq = os.path.join(config['output_dir'], "pychopper", "{sample}", "{sample}_SSP_removed.fastq"),
        genome = config["genome_path"]
    output:
        mapped_genome = os.path.join(config['output_dir'], "mapping", "genome", "{sample}_genome.sam"),
        bamtofastq = os.path.join(config['output_dir'], "mapping", "genome", "{sample}_genome.fastq"),
        bam = temp(os.path.join(config['tmp_dir'], "samtools", "{sample}.bam")),
        sorted_bam = temp(os.path.join(config['tmp_dir'], "samtools", "{sample}_sorted.bam"))
    conda:
        "../envs/mapping.yml"
    threads:
         config["max_threads"]
    resources:
        mem_mb = 32768, # 32GB
        runtime = 1440  # 1 day
    log:
        os.path.join(config["log_dir"], "mapping_genome", "{sample}.log")
    shell:
        """
        #Mapping reads to genome
        minimap2 \
        -ax splice \
        -p 0.99 \
        -k14 \
        --MD \
        -t {threads} \
        {input.genome} \
        {input.fastq} \
        > {output.mapped_genome}
        # Convert to sorted.bam file
        samtools \
        view -bS \
        {output.mapped_genome} \
        -o {output.bam}
        samtools \
        sort \
        {output.bam} \
        -o {output.sorted_bam}
        samtools \
        index \
        {output.sorted_bam}
        # bam to fastq for remapping of mapped reads in the next rule
        bedtools \
        bamtofastq \
        -i {output.sorted_bam} \
        -fq {output.bamtofastq}
        """