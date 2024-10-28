rule merge_read_count:
    input:
        pre = expand(os.path.join(config['tmp_dir'], "read_counts", "{sample}", "{sample}_total_reads_prefilt.tsv"), sample=sample_dirs),
        pychopper = expand(os.path.join(config["tmp_dir"], "read_counts", "{sample}", "{sample}_total_reads_cDNA.tsv"), sample=sample_dirs),
        polyA = expand(os.path.join(config['tmp_dir'], "read_counts", "{sample}", "{sample}_total_reads_polyA.tsv"), sample=sample_dirs),
        SSP = expand(os.path.join(config['tmp_dir'], "read_counts", "{sample}", "{sample}_total_reads_SSP_removed.tsv"), sample=sample_dirs)
    output:
        os.path.join(config['output_dir'], "reports", "read_count_overview.tsv")
    threads:
        2
    resources:
        mem_mb = 1024,
        runtime = "01:00:00"
    log: 
        os.path.join(config['log_dir'], "merge_read_count", "merge_read_count.log")
    conda:
        "../envs/generic.yml"
    shell:
        """
        echo -e "Sample\tReads_Pre_Filtering\tReads_Post_Pychopper\tReads_PolyA_removed\tReads_SSP_removed" > {output}
        for pre_file in {input.pre}; do
            sample=$(basename $pre_file | cut -d'_' -f1)
            reads_pre=$(sed -n '2p' $pre_file | cut -f2)
            post_file=$(echo $pre_file | sed 's/prefilt/cDNA/')
            reads_post=$(sed -n '2p' $post_file | cut -f2)
            polyA_file=$(echo $pre_file | sed 's/prefilt/polyA/')
            reads_polyA=$(sed -n '2p' $polyA_file | cut -f2)
            SSP_file=$(echo $pre_file | sed 's/prefilt/SSP_removed/')
            reads_SSP=$(sed -n '2p' $SSP_file | cut -f2)
            echo -e "$sample\t$reads_pre\t$reads_post\t$reads_polyA\t$reads_SSP" >> {output}
        done
        """