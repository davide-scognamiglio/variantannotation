/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_ALPHAMISSENSE
 * Purpose: Download vep plugin database
 */


process DOWNLOAD_ALPHAMISSENSE {
    tag "vep_setup"
    publishDir "${params.data_dir}/vep_data", mode: 'copy', overwrite: true
    container "dsbioinfo/musa-helper:latest"

    output:
    path "AlphaMissense"

    script:
    """
    mkdir -p AlphaMissense
    cd AlphaMissense
    wget https://storage.googleapis.com/dm_alphamissense/AlphaMissense_${params.build}.tsv.gz
	tabix -s 1 -b 2 -e 2 -f -S 1 AlphaMissense_${params.build}.tsv.gz
    cd ..
    """
}