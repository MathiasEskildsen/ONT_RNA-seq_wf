rule pychopper_second_round:
    input:
        files = os.path.join(config['output_dir'], "pychopper", "unclassified", "{sample}_unclassified.fastq")
    output:
        report = os.path.join(config['output_dir'], "pychopper", "reports", "{sample}_pychopper2_report.pdf"),
        unclassified = temp(os.path.join(config["tmp_dir"], "pychopper", "{sample}_unclassified.fastq")),
        rescued = os.path.join(config['output_dir'], "pychopper", "rescued", "{sample}_rescued2.fastq"),
        stats = os.path.join(config['output_dir'], "pychopper", "reports", "{sample}_pychopper2_stats.txt"),
        full_length = os.path.join(config['output_dir'], "pychopper", "full_length", "{sample}_full_length2_cDNA.fastq")
    threads: 
        config['max_threads']
    resources:
        mem_mb = 32768, # 32GB
        runtime = 120
    params:
        kit = config['pychopper_kit'] # Library preparation kit used, change in config file
    conda:
        "../envs/trimming.yml"
    log:
        os.path.join(config['log_dir'], "pychopper2", "{sample}.log")
    shell:
        """
        pychopper \
        -r {output.report} \
        -t {threads} \
        -k {params.kit} \
        -x {params.kit} \
        -u {output.unclassified} \
        -w {output.rescued} \
        -S {output.stats} \
        {input.files} \
        {output.full_length}
        """
