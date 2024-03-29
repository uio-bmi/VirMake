rule all:
    input:
        config["path"]["database"]["vcontact2"] + "/vcontact2_setup_done.txt",
        config["path"]["database"]["DRAM"],
        config["path"]["database"]["vibrant"],
        config["path"]["database"]["checkv"],
        config["path"]["database"]["INPHARED"] + "/vConTACT2_proteins.faa",
        config["path"]["database"]["INPHARED"] + "/data_excluding_refseq.tsv",
        config["path"]["database"]["INPHARED"] + "/vConTACT2_gene_to_genome.csv",
        config["path"]["database"]["RefSeq"] + "/viral.1.1.genomic.fna",
        config["path"]["database"]["virsorter2"],


rule Vcontact2:
    conda:
        config["path"]["envs"] + "/vcontact2.yaml"
    output:
        config["path"]["database"]["vcontact2"] + "/vcontact2_setup_done.txt",
    shell:
        "touch {output}"


rule metaQUAST:
    output:
        reference=config["path"]["database"]["RefSeq"] + "/viral.1.1.genomic.fna",
    shell:
        """
        wget https://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.1.1.genomic.fna.gz
        gunzip viral.1.1.genomic.fna.gz
        mv viral.1.1.genomic.fna {output.reference}
        """


rule DRAMv:
    """
    Downloads DRAMv.
    If Users want to skip this simply add a # symbol in front of:
    directory(config["path"]["database"]["DRAM"]+"/DRAM_data"),
    Keep in mind that the pipeline needs this to run.
    If downloaded independantly, simply add it to the config with same folder structure
    include the DRAM.config from DRAMv here also.
    """
    conda:
        config["path"]["envs"] + "/DRAMv.yaml"
    output:
        directory(config["path"]["database"]["DRAM"]),
    threads: 24
    shell:
        "DRAM-setup.py prepare_databases --output_dir {output} --verbose --skip_uniref --threads {threads}"
        ";"
        "DRAM-setup.py export_config --output_file {output}/DRAM.config"


rule vibrant:
    conda:
        config["path"]["envs"] + "/vibrant.yaml"
    output:
        directory(config["path"]["database"]["vibrant"]),
    shell:
        """
        download-db.sh {output}
        """


rule checkv:
    conda:
        config["path"]["envs"] + "/checkv.yaml"
    output:
        directory(config["path"]["database"]["checkv"]),
    shell:
        "checkv download_database {output}"


rule inphared:
    output:
        g2g=config["path"]["database"]["INPHARED"] + "/vConTACT2_gene_to_genome.csv",
        prot=config["path"]["database"]["INPHARED"] + "/vConTACT2_proteins.faa",
        exclref=config["path"]["database"]["INPHARED"] + "/data_excluding_refseq.tsv",
        version=config["path"]["database"]["INPHARED"] + "/version.txt",
    params:
        version="1May2023",
    shell:
        """
        wget 'https://millardlab-inphared.s3.climb.ac.uk/{params.version}_vConTACT2_gene_to_genome.csv.gz' -nH
        wget 'https://millardlab-inphared.s3.climb.ac.uk/{params.version}_vConTACT2_proteins.faa.gz' -nH
        wget 'https://millardlab-inphared.s3.climb.ac.uk/{params.version}_data_excluding_refseq.tsv.gz' -nH
        gunzip *.gz
        mv {params.version}_vConTACT2_gene_to_genome.csv {output.g2g}
        mv {params.version}_vConTACT2_proteins.faa {output.prot}
        mv {params.version}_data_excluding_refseq.tsv {output.exclref}
        echo "INPHARED VERSION: {params.version}" > {output.version}
        """


rule virsorter2:
    output:
        directory(config["path"]["database"]["virsorter2"]),
    conda:
        config["path"]["envs"] + "/virsorter2.yaml"
    threads: 24
    shell:
        """
        virsorter setup -d {output}
        """
