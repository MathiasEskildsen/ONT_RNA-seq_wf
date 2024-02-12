rule pychopper_second_round:
    input:
        os.path.join(config["output_pychopper"], "unclassified", "{sample}_unclassified.fastq")
    output:
        report = os.path.join(config["output_pychopper"], "reports", "{sample}_pychopper2_report.txt"),
        unclassified = temp(os.path.join(config["tmp_dir"], "unclassified", "{sample}_unclassified.fastq")),
        rescued = os.path.join(config["output_pychopper"], "rescued", "{sample}_rescued2.fastq"),
        stats = os.path.join(config["output_pychopper"], "reports", "{sample}_pychopper2_stats.txt"),
        full_length = os.path.join(config["output_pychopper"], "full_length", "{sample}_full_length2_cDNA.fastq")
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
        pychopper \
        -r {output.report} \
        -t {threads} \
        -k {params.kit} \
        -x rescue \
        -u {output.unclassified} \
        -w {output.rescued} \
        -S {output.stats} \
        {input} \
        output.full_length={output.full_length}
        """
