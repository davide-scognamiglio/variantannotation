/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_ENFORMER
 * Purpose: Download vep plugin database
 */


process DOWNLOAD_ENFORMER {
    tag "vep_setup"
    publishDir "${params.data_dir}/vep_data", mode: 'copy', overwrite: true
    container "dsbioinfo/musa-helper:latest"
    
    output:
    path "Enformer"

    script:
    """
    mkdir -p Enformer
    wget -P Enformer https://ftp.ensembl.org/pub/current_variation/Enformer/enformer_grch38.vcf.gz
    wget -P Enformer https://ftp.ensembl.org/pub/current_variation/Enformer/enformer_grch38.vcf.gz.tbi
    """
}