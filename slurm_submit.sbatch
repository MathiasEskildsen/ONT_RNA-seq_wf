#!/usr/bin/bash -l
#SBATCH --job-name=RNA-Seq_wf_madhuni_01
#SBATCH --output=job_%j_%x.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=default-op
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=abc@bio.aau.dk
#SBATCH --time 4-00:00:00

# Exit on first error and if any variables are unset
set -eu

# Activate conda environment with only snakemake
conda activate snakemake

# Start workflow using ressources defined in the profile. Snakemake itself 
# requires nothing, 1CPU + 1G mem is enough

# Render a DAG to visualize the workflow (optional)
snakemake --dag | dot -Tpdf > dag.pdf

# Main workflow
snakemake --profile profiles/biocloud

# Generate a report once finished (optional)
snakemake --report results/report.html
