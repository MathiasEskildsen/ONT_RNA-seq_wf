import pandas as pd
import sys

with open(snakemake.log[0], "w") as f:
    sys.stderr = sys.stdout = f
# Read files from snakemake
input_files = {
    "all": snakemake.input.sig_genes_no_filt,
    "filtered": snakemake.input.sig_genes_w_filt
}
output_files = {
    "all": snakemake.output.sig_genes_no_filt_prod,
    "filtered": snakemake.output.sig_genes_w_filt_prod
}
gff_file = snakemake.params.reference

# Create a mapping dictionary for product information
product_mapping = {}

# Read the GFF file and create a mapping of gene IDs to product information
with open(gff_file, 'r') as file:
    for line in file:
        if '\tgene\t' in line or '\trRNA\t' in line or '\ttRNA\t' in line or '\tCDS\t' in line:
            parts = line.strip().split('\t')
            attributes = parts[8].split(';')
            id_attr = [attr for attr in attributes if attr.startswith('ID=')]
            product_attr = [attr for attr in attributes if attr.startswith('product=')]
            parent_attr = [attr for attr in attributes if attr.startswith('Parent=')]

            if id_attr:
                gene_id = id_attr[0].split('=')[1].lower()
                product = product_attr[0].split('=')[1] if product_attr else None
                product_mapping[gene_id] = product
                if parent_attr:
                    parent_id = parent_attr[0].split('=')[1].lower()
                    product_mapping[parent_id] = product

# Process each TSV file and save the updated DataFrame to the corresponding output file
for key in input_files:
    input_tsv_file = input_files[key]
    output_file = output_files[key]

    # Read the TSV file into a DataFrame
    tsv_df = pd.read_csv(input_tsv_file, sep='\t')

    # Add the 'product' column to the TSV DataFrame
    tsv_df['product'] = tsv_df['row'].apply(lambda x: product_mapping.get(x.lower()))

    # Save the updated DataFrame back to a TSV file
    tsv_df.to_csv(output_file, sep='\t', index=False)
