onstart:
    shell("mail -s 'Workflow started' email_address < {log}")

onsuccess:
    shell("mail -s 'Workflow finished, no error' email_address < {log}")

onerror:
    shell("mail -s 'an error occurred' email_address < {log}")


rule all:
    input:
        # Tophat+Cufflinks workflow
        'assembly/comparison/all.stats',
        'diffexp/isoform_exp.diff',
        # Kallisto+Sleuth workflow
        "kallisto/DEGS/gene_table.txt",
        # Star+htseq workflow
        expand("star/{sample}/count/{sample}_htseq.cnt", sample=config.get('samples')),



include_prefix="rules"

include:
    include_prefix + "/functions.py"
include:
    include_prefix + "/kallisto.rules"
include:
    include_prefix + "/tophat.rules"
include:
    include_prefix + "/cufflinks.rules"
include:
    include_prefix + "/star2.rules"
