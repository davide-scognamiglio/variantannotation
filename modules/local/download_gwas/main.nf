/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_GWAS
 * Purpose: Download vep plugin database
 */


process DOWNLOAD_GWAS {
    tag "vep_setup"
    publishDir "${params.data_dir}/vep_data", mode: 'copy', overwrite: true
    container "dsbioinfo/musa-helper:latest"
    
    output:
    path "GWAS"

    script:
    """
    mkdir -p GWAS
    cd GWAS
    wget -O gwas.zip "https://www.ebi.ac.uk/gwas/api/search/downloads/associations/v1.0?split=false"
    unzip gwas.zip
    rm gwas.zip 
    cd ..
    """
}