/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_MAVEDB
 * Purpose: Download vep plugin database
 */


process DOWNLOAD_MAVEDB {
    tag "vep_setup"
    publishDir "${params.data_dir}/vep_data", mode: 'copy', overwrite: true
    container "dsbioinfo/musa-helper:latest"
    
    output:
    path "MaveDB"

    script:
    """
    mkdir -p MaveDB
    cd MaveDB
    wget https://ftp.ensembl.org/pub/current_variation/MaveDB/MaveDB_variants.tsv.gz
    wget https://ftp.ensembl.org/pub/current_variation/MaveDB/MaveDB_variants.tsv.gz.tbi
    cd ..
    """
}