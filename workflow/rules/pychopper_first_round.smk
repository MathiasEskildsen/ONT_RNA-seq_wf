rule pychopper_first_round:
    input:
        os.path.join(config['tmp_dir'], "samples", "{sample}_concat.fastq.gz")
    output:
        report = os.path.join(config['output_pychopper'], "reports", "{sample}_pychopper1_report.pdf"),
        unclassified = os.path.join(config['output_pychopper'], "unclassified", "{sample}_unclassified.fastq"),
        rescued = os.path.join(config['output_pychopper'], "rescued", "{sample}_rescued1.fastq"),
        stats = os.path.join(config['output_pychopper'], "reports", "{sample}_pychopper_stats.txt"),
        full_length = os.path.join(config['output_pychopper'], "full_length", "{sample}_full_length1_cDNA.fastq")
    threads:
        config['max_threads']
    params:
        kit = config['pychopper_kit']
    conda:
        "../envs/trimming.yml"
    log:
        os.path.join(config['log_dir'], "pychopper", "{sample}.log")
    shell:
        """
        gunzip -c {input} | pychopper \
        -r {output.report} \
        -k {params.kit} \
        -t {threads} \
        -u {output.unclassified} \
        -w {output.rescued} \
        -S {output.stats} \
        {output.full_length}
        """