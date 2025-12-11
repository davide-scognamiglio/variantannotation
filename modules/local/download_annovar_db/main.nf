/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_ANNOVAR_DB
 * Purpose: Download ANNOVAR databases
 */


process DOWNLOAD_ANNOVAR_DB{
    tag "renovo_setup"
    publishDir "${params.data_dir}", mode: 'copy', overwrite: true
    container "dsbioinfo/musa-helper:latest"

    output:
    path "renovo_humandb"

    script:
    """
    mkdir renovo_humandb
    cd renovo_humandb

    # refGene
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_refGene.txt.gz
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_refGeneMrna.fa.gz
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_refGeneVersion.txt.gz

    # ensGene
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_ensGene.txt.gz
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_ensGeneMrna.fa.gz

    # avsnp151
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_avsnp150.txt.gz
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_avsnp150.txt.idx.gz

    # gnomad41_exome
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_gnomad211_exome.txt.gz
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_gnomad211_exome.txt.idx.gz

    # dbnsfp42c
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_dbnsfp35c.txt.gz
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_dbnsfp35c.txt.idx.gz

    # intervar_20250721
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_intervar_20180118.txt.gz
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_intervar_20180118.txt.idx.gz

    # clinvar_20250721
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_clinvar_20250721.txt.gz
    wget --verbose http://www.openbioinformatics.org/annovar/download/${params.build}_clinvar_20250721.txt.idx.gz
    
    gunzip *.gz
    
    cd ..
    """    
}