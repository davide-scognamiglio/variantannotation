/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_DBNSFP
 * Purpose: Download vep plugin database
 */


process DOWNLOAD_DBNSFP {
    tag "vep_setup"

    publishDir "${params.data_dir}/vep_data", mode: 'copy', overwrite: true
    container "dsbioinfo/musa-helper:latest"

    output:
    path "dbNSFP"

    script:
    """
    mkdir -p dbNSFP
    cd dbNSFP
    wget https://dist.genos.us/academic/01f8c3/dbNSFP5.2a_grch38.gz
    wget https://dist.genos.us/academic/01f8c3/dbNSFP5.2a_grch38.gz.tbi
    wget https://dist.genos.us/academic/01f8c3/dbNSFP5.2a_grch38.gz.md5
    cd ..
    """
}