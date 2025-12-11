/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_CADD
 * Purpose: Download vep plugin database
 */


process DOWNLOAD_CADD {
    tag "vep_setup"
    publishDir "${params.data_dir}/vep_data", mode: 'copy', overwrite: true
    container "dsbioinfo/musa-helper:latest"

    output:
    path "CADD"

    script:
    """
    mkdir -p CADD
    wget -P CADD https://kircherlab.bihealth.org/download/CADD/v1.7/GRCh38/whole_genome_SNVs.tsv.gz
    wget -P CADD https://kircherlab.bihealth.org/download/CADD/v1.7/GRCh38/whole_genome_SNVs.tsv.gz.tbi
    """
}