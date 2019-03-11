rule bowtie2_build_index:
    input:
        resolve_single_filepath(*references_abs_path(), config.get("genome_fasta"))
    output:
        touch("bowtie2_index_ready"),
        genome="{label}.fa".format(label=get_references_label())
    conda:
        "../envs/bowtie2.yaml"
    params:
        label=get_references_label()
    threads: pipeline_cpu_count()
    shell:
        "rsync -av {input} {output.genome} "
        "&& bowtie2-build "
#        "--threads {threads} "
        "--large-index "
        "{output.genome} {params.label} "

rule tophat_paired:
    input:
        "reads/trimmed/{sample}-R1-trimmed.fq.gz",
        index_ready="bowtie2_index_ready",
        gtf=resolve_single_filepath(*references_abs_path(ref='genes_reference'),
                                    config.get("genes_gtf"))
    output:
        "mapped/{sample}/accepted_hits.bam"
    conda:
        "../envs/tophat2.yaml"
    params:
        outdir="mapped/{sample}/",
        label=get_references_label()
    shadow: "shallow"
    threads: pipeline_cpu_count(reserve_cpu=10)
    shell:
        "tophat2 "
        "--output-dir {params.outdir} "
        " --b2-very-sensitive "
        " --GTF {input.gtf} "
        "--num-threads {threads} "
        "{params.label} "
        "{input[0]} {input[1]}"
