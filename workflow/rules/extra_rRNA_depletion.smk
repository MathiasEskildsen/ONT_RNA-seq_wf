rule rRNA_depletion:
    input:
        os.path.join(config['tmp_dir'], "samples", "{sample}_concat.fastq")
    output:
        os.path.join(config['output_dir'], "rRNA_depleted_fastqs", "{sample}","{sample}_rRNA_depleted.fastq")
    resources:
        mem_mb = 40960, #40GB
        runtime = "2-00:00:00" # 2 days
    params:
        rRNA_database = config['rRNA_db']
    conda:
        "../envs/map2db.yml"
    threads:
        config['max_threads']
    log:
        os.path.join(config['log_dir'], "rRNA_depletion", "{sample}.log")
    shell:
        """
        minimap2 \
        -ax splice \
        -p 0.99 \
        -uf \
        -k14 \
        --MD \
        -t {threads} \
        {params.rRNA_database} \
        {input} \
        | samtools fastq -n -f 4 > {output}
        """
