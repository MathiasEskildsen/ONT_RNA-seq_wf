#Wildcards helper function - properly generate wildcards from .fastq files
import glob
import os
## Validate configuration options for "include_pychopper"
def validate_boolean_config(config_value, config_name):
    if not isinstance(config_value, bool):
        raise ValueError(f"Invalid value for {config_name}: '{config_value}'. It must be True or False (case-sensitive).")

def listFastq(wildcards):
    sample_path = os.path.join(config['input_dir'])
    fastqs = []
    
    if os.path.isdir(sample_path):
        # Check if there are subdirectories
        subdirs = [d for d in os.listdir(sample_path) if os.path.isdir(os.path.join(sample_path, d))]
        
        if subdirs:
            # If there are subdirectories, use them as wildcards.sample
            for subdir in subdirs:
                if wildcards.sample in subdir:
                    fastqs = glob.glob(os.path.join(sample_path, subdir, "*.fastq*"))
        else:
            # If there are no subdirectories, use filenames as wildcards.sample
            files = [f for f in os.listdir(sample_path) if os.path.isfile(os.path.join(sample_path, f))]
            for file in files:
                file_base = os.path.splitext(file)[0]
                if wildcards.sample in file_base:
                    fastqs.append(os.path.join(sample_path, file))
    return fastqs

# Define the function to list samples
def get_samples():
    sample_path = config['input_dir']
    samples = []
    if os.path.isdir(sample_path):
        subdirs = [d for d in os.listdir(sample_path) if os.path.isdir(os.path.join(sample_path, d))]
        if subdirs:
            samples = subdirs
        else:
            files = [f for f in os.listdir(sample_path) if os.path.isfile(os.path.join(sample_path, f))]
            for file in files:
                # Handle files with multiple extensions
                file_base = re.sub(r'\.f.*q(\.gz)?$', '', file)
                if file_base not in samples:
                    samples.append(file_base)
    return samples

## Prepare inputs for rule all
## Rule all currently only includes the output files from the workflow
## This can be changed manually if needed
## This function is called in the rule all section of the Snakefile
def prepare_inputs():
    inputs = []
    if config["include_pychopper"]:
        inputs.extend(expand(os.path.join(config['output_dir'], "pychopper", "{sample}", "{sample}_SSP_removed.fastq"), sample=get_samples()))
        inputs.extend(expand(os.path.join(config['output_dir'], "quantification", "{sample}", "{sample}.quant"), sample=get_samples()))
        #inputs.extend(expand(os.path.join(config['output_dir'], "reports", "read_count_overview.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DESeq2_results.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "figs", "PCA-plot.png")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_all_w_contrast.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_filtered_w_contrast.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "figs", "volcano_plot.png")))
        #inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "figs", "volcano_plot_labels.png")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_filtered_w_contrast_product.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_all_w_contrast_product.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "reports", "config.txt")))
        #inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "R_env.RData")))
    else:
        inputs.extend(expand(os.path.join(config['output_dir'], "quantification", "{sample}", "{sample}.quant"), sample=get_samples()))
        #inputs.extend(expand(os.path.join(config['output_dir'], "reports", "read_count_overview.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DESeq2_results.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "figs", "PCA-plot.png")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_all_w_contrast.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_filtered_w_contrast.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "figs", "volcano_plot.png")))
        #inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "figs", "volcano_plot_labels.png")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_filtered_w_contrast_product.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "DiffExp_all_w_contrast_product.tsv")))
        inputs.extend(expand(os.path.join(config['output_dir'], "reports", "config.txt")))
        #inputs.extend(expand(os.path.join(config['output_dir'], "DESeq2", "data", "R_env.RData")))
    return inputs