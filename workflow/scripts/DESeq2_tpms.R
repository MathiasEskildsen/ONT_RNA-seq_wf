# List packages required for the analysis
packages <- c("ggplot2", "readr", "dplyr", "tidyr", "reshape2", "tximport", "tximportData", "DESeq2", "tidyverse", "scales", "here")

# Check if packages are not installed, if not, then install them
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages], repos = "https://cloud.r-project.org")
}

# Load the required libraries
invisible(lapply(packages, library, character.only = TRUE))

# Load the data into R
input_files <- snakemake@input[["counts"]]

# Initialize a list to store the data
data_list <- list()

# Function to calculate TPM
calcTPM <- function(counts, lengths) {
  rate <- counts / lengths
  rate / sum(rate) * 1e6
}

# Loop through each file and read the data into a list
for (file in input_files) {
  # Extract the filenames without file extension
  id <- sub("\\.quant$", "", basename(file))
  # Read the file into a data frame
  data <- read_tsv(file, show_col_types = FALSE)
  data_list[[id]] <- data
}

# Select one file to create genes_length object
# Assuming that all files are quantified from the same reference transcriptome
selected_file <- names(data_list)[1]
genes_length_col <- c("tname", "len")
genes_length <- data_list[[selected_file]][, genes_length_col]

# Create table of quantification files dynamically
quant_table <- sapply(data_list, function(df) df[, 3])
# Combine into a dataframe
quant_files <- data.frame(quant_table)
# Rename headers
colnames(quant_files) <- names(data_list)

# Ensure genes_length data frame has the column "len" - SANITY
if (!"len" %in% colnames(genes_length)) {
  stop("The genes_length data frame does not have a column named 'len'")
}

# Calculate TPMs for each sample to each gene
tpms <- apply(quant_files, 2, function(x) calcTPM(x, genes_length$len))

# Append TPMs to original data and write to output files
for (sample in names(data_list)) {
  data <- data_list[[sample]]
  tpm_values <- tpms[, sample]
  data$TPM <- tpm_values
  output_file <- snakemake@output[["tpms"]]
  write_tsv(data, output_file)
}