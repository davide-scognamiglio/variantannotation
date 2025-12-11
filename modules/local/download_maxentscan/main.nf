/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_MAXENTSCAN
 * Purpose: Download vep plugin database
 */


process DOWNLOAD_MAXENTSCAN {
    tag "vep_setup"
    publishDir "${params.data_dir}/vep_data", mode: 'copy', overwrite: true
    container "dsbioinfo/musa-helper:latest"
    
    output:
    path "MaxEntScan"

    script:
    """
    mkdir -p MaxEntScan
    cd MaxEntScan
    wget http://hollywood.mit.edu/burgelab/maxent/download/fordownload.tar.gz
    tar -xvzf fordownload.tar.gz
    rm fordownload.tar.gz
    cd ..
    """
}