# Logs
log <- file(snakemake@log[[1]], open = "wt")
sink(log)
sink(log, type="message")
# List packages required for the analysis
packages <- c("tidyverse", "DESeq2", "tximport")
# Check if packages are not installed, if not, then install them
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages], repos = "https://cloud.r-project.org")
}
# Load the packages
library(tidyverse)
library(DESeq2)
library(tximport)

# Load the sample table into R
sample_table <- read.csv2(snakemake@input[["sample_table"]])
colnames(sample_table)[1] <- "sample.name"
sample_table$sample.name <- as.character(sample_table$sample.name)

#Set the working directory using snakemake config
output_dir <- normalizePath(snakemake@config[["output_dir"]])
setwd(output_dir)

# Pull the sample names from the sample table
files <- pull(sample_table, sample.name)

# Construct the sample file paths, using the sample table
sample_files <- paste0(output_dir, "/quantification/", files, "/", (files), ".quant")

names(sample_files) <- pull(sample_table, sample.name)
# Tximport the data
count_data <- tximport(files = sample_files,
                       type = "oarfish",
                       txIn = TRUE,
                       txOut = TRUE)
# DESeq2 normalization and dataframe creation
sample_table <- as.data.frame(sample_table)
colnames(sample_table)[1] <- "sample"
colnames(sample_table)[3] <- "condition"
deseq_df <- DESeqDataSetFromTximport(txi = count_data,
                                     colData = sample_table,
                                     design =~condition)
# Setting control as reference level
deseq_df$condition <- relevel(deseq_df$condition, ref = "Control")
# Run DESeq2 normalization
deseq_norm <- DESeq(deseq_df)
# Get results
results_table <- results(deseq_norm)
# Results in data frame
results_df <- as.data.frame(results_table)
# Debugging
# Write results to file - omit this writing later, just testing atm
data_path <- normalizePath(snakemake@params[["data_path"]], mustWork = FALSE)
if (!dir.exists(data_path)) {
    dir.create(data_path, recursive = TRUE)
}
print(data_path)
result_table_path <- paste0(data_path, "/", "DESeq2_results.tsv")
print(result_table_path)
write_tsv(results_df, result_table_path)
## Variance stabilization of data
## This is needed for PCA 
## Later add QA plots for now PCA is enough
vsd <- rlog(deseq_norm, blind=TRUE)

# Plot PCA plot looking at condition
PCA_plot <- plotPCA(vsd, intgroup = "condition") +
    theme_classic() +
    geom_point(size=4) +
    labs(color="") +
    ggtitle("PCA plot condition as interesting group") +
    theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold", color = "black"))
# Save the plot
# Create file path for PCA plot for ggsave function
fig_path <- normalizePath(snakemake@params[["fig_path"]], mustWork = FALSE)
if (!dir.exists(fig_path)) {
    dir.create(fig_path, recursive = TRUE)
}
print(fig_path)
PCA_plot_file <- paste0(fig_path, "/", "PCA-plot.png")
print(PCA_plot_file)
ggsave(PCA_plot_file, PCA_plot, width = 186, units = "mm", create.dir = TRUE)
# Set up contrasts # This currently only works for 2 conditions, called Control and Treatment
# Need to make this more general and work for any number of conditions
#TvsC <- results(deseq_norm, contrast=c("condition", "Treatment", "Control"), tidy = T)
#contrast_list <- list(TvsC)
#contrast_names <- c("Treatment vs Control")

#all_contrast <- map2(contrast_list, contrast_names, function(x, name) {
#  x %>% 
#    mutate(contrast = name) %>% as_tibble()
#})

# Extract unique conditions from the sample table
conditions <- unique(sample_table$condition)
# Debugging
print(conditions)
# Generate pair-wise contrasts for all conditions
contrast_combinations <- combn(conditions, 2, simplify = FALSE)
# Debugging
print(contrast_combinations)
# Initialize lists to store contrasts and their names
contrast_list <- list()
contrast_names <- c()

# Loop through each pair of conditions and compute contrasts
for (contrast_pair in contrast_combinations) {
  # Name for the contrast
  contrast_name <- paste(contrast_pair[2], "vs", contrast_pair[1])
  
  # Calculate the contrast results
  contrast_result <- results(deseq_norm, contrast = c("condition", contrast_pair[2], contrast_pair[1]), tidy = TRUE)
  
  # Ensure the result is a tibble
  contrast_result <- as_tibble(as.data.frame(contrast_result))
  
  # Append the contrast result and name to respective lists
  contrast_list <- append(contrast_list, list(contrast_result))
  contrast_names <- append(contrast_names, contrast_name)
}

# Debugging
print(contrast_list)
print(contrast_names)
# Combine all contrast results into a single tibble
all_contrast <- map2(contrast_list, contrast_names, function(contrast_data, name) {
  contrast_data %>%
    mutate(contrast = name) %>%
    as_tibble()
}) %>% bind_rows()

# Add significance of regulation to each gene
all_contrast_filtered <- all_contrast %>%
  mutate(significance = case_when(
    padj > snakemake@params[["padj"]] ~ "NO",
    log2FoldChange > snakemake@params[["log2fc"]] & padj < snakemake@params[["padj"]] ~ "UP",
    log2FoldChange < -snakemake@params[["log2fc"]] & padj < snakemake@params[["padj"]] ~ "DOWN",
    log2FoldChange < snakemake@params[["log2fc"]] & padj < snakemake@params[["padj"]] & log2FoldChange > -snakemake@params[["log2fc"]] ~ "NO"
  )) %>%
  filter(padj != "") %>%  # Exclude rows where padj is NA
  as_tibble()
# Filter out non-significant genes
all_contrast_filtered_list <- filter(all_contrast_filtered,significance != "NO")
# Write the data to file
# Create paths for the files
all_c_f <- paste0(data_path, "/", "DiffExp_all_w_contrast.tsv")
all_c_f_l <- paste0(data_path, "/", "DiffExp_filtered_w_contrast.tsv")
# Debugging
print(all_c_f)
print(all_c_f_l)
write_tsv(all_contrast_filtered, all_c_f)
write_tsv(all_contrast_filtered_list, all_c_f_l)
# Volcano Plot, using semi-standard template
volcano_plot <- ggplot(data=all_contrast_filtered, aes(x = log2FoldChange, y = -log10(padj), color = significance)) +
  geom_point(size=1,alpha=0.3) + 
  theme_bw() +
  scale_color_manual(values = c("red", "black", "blue")) +
  geom_hline(yintercept = -log10(snakemake@params[["padj"]]), linetype = "dashed") +
  geom_vline(xintercept = c(-snakemake@params[["log2fc"]], snakemake@params[["log2fc"]]), linetype = "dashed") +
  scale_x_continuous(limits = c(-10, 10)) +
  scale_y_continuous(limits = c(0, 20)) +
  labs(x = "log2FoldChange", y = "-log10(padj)", color = "Significance") +
  ggtitle("Volcano plot") +
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold", color = "black"))
# Save the plot
# Create file path for volcano plot for ggsave function
volcano_plot_file <- paste0(fig_path, "/", "volcano_plot.png")
print(volcano_plot_file)
ggsave(volcano_plot_file, volcano_plot, width = 186, units = "mm",create.dir = TRUE)
# Add gene-ID labels to existing volcano plot
# Add labels to top 20 genes in regards to log2FoldChange (10 highest and 10 lowest)
names(all_contrast_filtered_list)[names(all_contrast_filtered_list) == "row"] <- "gene"

# Filter out genes starting with rna- xx 
filtered_df <- all_contrast_filtered_list[!grepl("^rna-", all_contrast_filtered_list$gene), ]
# Get top 10 and bottom 10 genes
top_10 <- filtered_df %>% arrange(desc(log2FoldChange)) %>% head(10)
bottom_10 <- filtered_df %>% arrange(log2FoldChange) %>% head(10)
# Combine the two
top_genes <- bind_rows(top_10, bottom_10)
## NEED TO ADD ggrepel to docker image for this to work, I'm lazy atm. MDA ffs
#volcanoplot_labels <- volcano_plot +
#  geom_text_repel(data = top_genes, aes(label = gene), show.legend = F)

# save the plot
#volcano_plot_path <- paste0(fig_path, "/", "Volcano_plot_w_labels.png")
#ggsave(volcano_plot_path, volcanoplot_labels, width = 186, units = "mm",create.dir = TRUE)

#save.image(snakemake@output[["r_env"]])