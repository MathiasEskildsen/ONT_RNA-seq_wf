#!/bin/bash -l 
#SBATCH --job-name=rRNA_depletion_SILVA
#SBATCH --output=/home/bio.aau.dk/mk20aj/joblog/job_%j_%x.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=default-op
#SBATCH --cpus-per-task=20
#SBATCH --mem=40G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=mhes@bio.aau.dk
#SBATCH --time=7-00:00:00



set -eu
## MAKE THIS INTO A OPTIONAL RULE
conda activate map2db
output_base="/home/bio.aau.dk/mk20aj/Projects/snakemake_ONT_cDNA/data/samples_rRNA_depleted"
database="/databases/SILVA/138.1/SILVA_138.1_SSURef_NR99_tax_silva_trunc.sintax.fasta"

for barcode in {01..08};do 
    #paths 
    output_dir="${output_base}/${barcode}"
    input="/home/bio.aau.dk/mk20aj/Projects/snakemake_ONT_cDNA/data/samples/BC${barcode}.fastq"
    filename="BC${barcode}"
    #make directories if they do not exist
    mkdir -p ${output_dir}

    # Run minimap2 and save output to a temporary file
    minimap2 -ax splice -p 0.99 -uf -k14 --MD -t 20 ${database} ${input} > ${output_dir}/${filename}_temp.sam

    # Use samtools to convert the temporary SAM file to fastq
    samtools fastq -n -f 4 ${output_dir}/${filename}_temp.sam > ${output_dir}/${filename}.rRNA_depleted.fastq

    # Clean up the temporary SAM file
    rm ${output_dir}/${filename}_temp.sam
done