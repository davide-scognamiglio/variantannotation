/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_SPLICEVAULT
 * Purpose: Download vep plugin database
 */


process DOWNLOAD_SPLICEVAULT {
    tag "vep_setup"
    publishDir "${params.data_dir}/vep_data", mode: 'copy', overwrite: true
    container "dsbioinfo/musa-helper:latest"
    
    output:
    path "SpliceVault"

    script:
    """
    mkdir -p SpliceVault
    cd SpliceVault
    wget https://ftp.ensembl.org/pub/current_variation/SpliceVault/SpliceVault_data_GRCh38.tsv.gz
    wget https://ftp.ensembl.org/pub/current_variation/SpliceVault/SpliceVault_data_GRCh38.tsv.gz.tbi
    cd ..
    """
}