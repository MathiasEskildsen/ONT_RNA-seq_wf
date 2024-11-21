rule quantification:
    input:
        reads = os.path.join(config['output_dir'], "mapping", "transcriptome", "{sample}_transcriptome.bam")
    output:
        quant = os.path.join(config["output_dir"], "quantification", "{sample}", "{sample}.quant"),
        infreps=os.path.join(config["output_dir"], "quantification", "{sample}", "{sample}.infreps.pq")
    conda:
        "../envs/gene_abundance_estimation.yml"
    threads:
        config["max_threads"]
    resources:
        mem_mb = 20480, # 20GB
        runtime = 1440 # 1 day
    log:
        os.path.join(config["log_dir"], "quantification", "{sample}.log")
    shell:
        """
        oarfish \
        -a {input} \
        -o {output.quant} \
        --threads {threads} \
        --num-bootstraps 1000
        #Rename the output file to match expected output
        mv {output.quant}.quant {output.quant}
        mv {output.quant}.infreps.pq {output.infreps}
        """
