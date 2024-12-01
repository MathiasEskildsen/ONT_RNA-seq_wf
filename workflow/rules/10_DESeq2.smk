rule TPM:
    input:
        counts = os.path.join(config['output_dir'], "quantification", "{sample}", "{sample}.quant")
    output:
        tpms = os.path.join(config['output_dir'], "DESeq2", "{sample}", "{sample}_tpms.quant")
    log:
        os.path.join(config['log_dir'], "DESeq2", "{sample}", "{sample}.DESeq2.log")
    resources:
        mem_mb = 4096,
        runtime = 60
    threads:
        config['max_threads']
    conda:
        "../envs/DESeq2.yml"
    script:
        "../scripts/DESeq2_tpms.R"
rule DESEq2:
    input:
        sample_table = os.path.join(config['metadata']),
        quant = expand(os.path.join(config['output_dir'], "quantification", "{sample}", "{sample}.quant"),sample=get_samples())
    output:
        results = os.path.join(config['output_dir'], "DESeq2", "data", "DESeq2_results.tsv"),
        PCA = os.path.join(config['output_dir'], "DESeq2", "figs", "PCA-plot.png"),
        all_w_contrast = os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_all_w_contrast.tsv"),
        filtered_w_contrast = os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_filtered_w_contrast.tsv"),
        volcano = os.path.join(config['output_dir'], "DESeq2", "figs", "volcano_plot.png"),
        #volcano_labels = os.path.join(config['output_dir'], "DESeq2", "figs", "volcano_plot_labels.png"),
        #r_env = os.path.join(config['output_dir'], "DESeq2", "data", "R_env.RData"),
    log:
        os.path.join(config['log_dir'], "DESeq2", "DESeq2.log")
    resources:
        mem_mb = 16384,
        runtime = 120
    params:
        padj = config['padj_cutoff'],
        log2fc = config['log2fc_cutoff'],
        fig_path = "DESeq2/figs",
        data_path = "DESeq2/data"
    threads:
        config['max_threads']
    container:
        "docker://mathiaseskildsen/my_deseq2_env:latest"
    script:
        "../scripts/DESeq2_norm.R"