rule NanoPlot:
    input:
        fastqs_raw = os.path.join(config['output_dir'], "samples", "{sample}_concat.fastq"),
        fastqs_pychopper = os.path.join(config['output_dir'], "pychopper", "merged_full_length_cDNA", "{sample}_merged_cDNA.fastq")
    output:
        raw = os.path.join(config['output_dir'], "statistics_raw", "{sample}", "{sample}_NanoStats.txt"),
        pychopper = os.path.join(config['output_dir'], "statistics_pychopper", "{sample}", "{sample}_NanoStats.txt")
    threads:
        config['max_threads']
    resources:
        runtime = 120,
        mem_mb = 12288
    conda:
        "../envs/statistics.yml"
    log:
        os.path.join(config['log_dir'], "statistics", "{sample}.log")
    shell:
        """
        # Run nanoplot on raw reads and pychopper merged reads
        NanoPlot --fastq {input.fastqs_raw} --plots dot --prefix {wildcards.sample}_ --threads {threads} --outdir {output.raw}

        NanoPlot --fastq {input.fastqs_pychopper} --plots dot --prefix {wildcards.sample}_ --threads {threads} --outdir {output.pychopper}
        """