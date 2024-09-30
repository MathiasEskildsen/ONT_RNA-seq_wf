# This file includes small helper functions, not necesarily used in multiple rules
# But they are included here to keep the main Snakefile clean and readable
# And in order to "pass" linting tests performed by GitHub Actions

## Validate configuration options for "include_pychopper"
def validate_boolean_config(config_value, config_name):
    if not isinstance(config_value, bool):
        raise ValueError(f"Invalid value for {config_name}: '{config_value}'. It must be True or False (case-sensitive).")

## Prepare inputs for rule all
## Rule all currently only includes the output files from the workflow
## This can be changed manually if needed
## This function is called in the rule all section of the Snakefile
def prepare_inputs():
    inputs = []
    if config["include_pychopper"]:
        inputs.extend(expand(os.path.join(config['output_dir'], "pychopper", "{sample}", "{sample}_SSP_removed.fastq"), sample=get_samples()))
        inputs.extend(expand(os.path.join(config['output_dir'], "quantification", "{sample}", "{sample}.quant"), sample=get_samples()))
        inputs.extend(expand(os.path.join(config['output_dir'], "reports", "read_count_overview.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "{sample}", "{sample}_tpms.quant"), sample=get_samples()))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DESeq2_results.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "figs", "PCA-plot.png")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_all_w_contrast.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_filtered_w_contrast.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "figs", "volcano_plot.png")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "figs", "volcano_plot_labels.png")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_filtered_w_contrast_product.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_all_w_contrast_product.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "reports", "config.txt")))
        inputs.extend(expand(os.path.join(config['output_dir'], "statistics_raw", "{sample}", "{sample}_NanoStats.txt"), sample=get_samples()))
        inputs.extend(expand(os.path.join(config['output_dir'], "statistics_pychopper", "{sample}", "{sample}_NanoStats.txt"), sample=get_samples()))
else
        inputs.extend(expand(os.path.join(config['output_dir'], "quantification", "{sample}", "{sample}.quant"), sample=get_samples()))
        inputs.extend(expand(os.path.join(config['output_dir'], "reports", "read_count_overview.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "{sample}", "{sample}_tpms.quant"), sample=get_samples()))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DESeq2_results.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "figs", "PCA-plot.png")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_all_w_contrast.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_filtered_w_contrast.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "figs", "volcano_plot.png")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "figs", "volcano_plot_labels.png")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_filtered_w_contrast_product.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_all_w_contrast_product.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "reports", "config.txt")))
        inputs.extend(expand(os.path.join(config['output_dir'], "statistics_raw", "{sample}", "{sample}_NanoStats.txt"), sample=get_samples()))
    return inputs