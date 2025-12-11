/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_UTRANNOTATOR
 * Purpose: Download vep plugin database
 */


process DOWNLOAD_UTRANNOTATOR {
    tag "vep_setup"
    publishDir "${params.data_dir}/vep_data", mode: 'copy', overwrite: true
    container "dsbioinfo/musa-helper:latest"
    
    output:
    path "UTRannotator"

    script:
    """
    mkdir -p UTRannotator
    cd UTRannotator
    wget https://raw.githubusercontent.com/Ensembl/UTRannotator/master/uORF_5UTR_GRCh38_PUBLIC.txt
    cd ..
    """
}