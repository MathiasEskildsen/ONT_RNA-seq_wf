import glob
import os

# helper function to list all fastq files per wildcard (subfolder/sample) 
def listFastq(wildcards):
  fastqs = glob.glob(os.path.join(config['input_dir'], wildcards.sample, "*.fastq.gz"))
  return fastqs

rule concatenate_fastq:
  input:
    listFastq
  output:
    temp(os.path.join(config['tmp_dir'], "samples", "{sample}_concat.fastq.gz"))
  resources:
    mem_mb = 600
  threads: 1
  shell:
    "cat {input} > {output}"
