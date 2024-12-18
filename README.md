# Snakemake workflow: `ONT_RNA-seq_wf`

[![Snakemake](https://img.shields.io/badge/snakemake-≥7.18.2-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/MathiasEskildsen/ONT_RNA-seq_wf/workflows/Tests/badge.svg?branch=main)](https://github.com/MathiasEskildsen/ONT_RNA-seq_wf/actions?query=branch%3Amain+workflow%3ATests)
## Description
ONT_RNA-seq_wf is a Snakemake workflow designed to process RNA-seq data generated by either PCR-cDNA or direct cDNA sequencing kits from ONT. It can also be used for direct RNA-seq, however pychopper should be disabled via the configuration file if that is the case. The pipe line was developed using the following [snakemake template](https://github.com/cmc-aau/snakemake_project_template).

This workflow is still a work in progress and is actively developed with new features being continously implemented.

## Table of Contents
- [Requirements](#requirements)
- [Usage](#usage)

## Requirements
All required tools are automatically installed by Snakemake using conda environments or singularity/apptainer containers, however Snakemake itself needs to be installed first. Load a software module with Snakemake, use a native install, or use the `environment.yml` file to create a conda environment for this particular project using fx `mamba env create -n snakemake -f environment.yml`.

## Usage
Adjust the `config.yaml` files under both `config/` and `profiles/` accordingly, then simply run `snakemake --profile profiles/<subfolder>` or submit a SLURM job using the `slurm_submit.sbatch` example script.
The usage of this workflow is also described in the [Snakemake Workflow Catalog](https://snakemake.github.io/snakemake-workflow-catalog/?usage=<owner>%2F<repo>).

