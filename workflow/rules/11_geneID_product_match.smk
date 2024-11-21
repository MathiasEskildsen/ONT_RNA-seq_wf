rule geneID_product_match:
    input:
        sig_genes_no_filt = os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_all_w_contrast.tsv"),
        sig_genes_w_filt = os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_filtered_w_contrast.tsv")
    output:
        sig_genes_no_filt_prod = os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_all_w_contrast_product.tsv"),
        sig_genes_w_filt_prod = os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_filtered_w_contrast_product.tsv")
    log:
        os.path.join(config['log_dir'], "DESeq2", "logs", "DiffExp_filtered_w_contrast_w_product.log")
    resources:
        mem_mb = 1024,
        runtime = 60
    threads:
        2
    params:
        reference = config['annotation_path']
    conda:
        "../envs/generic.yml"
    script:
        "../scripts/geneID_product_match.py"
