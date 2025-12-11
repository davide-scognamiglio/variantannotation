/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_PLI
 * Purpose: Download vep plugin database
 */


process DOWNLOAD_PLI {
    tag "vep_setup"
    publishDir "${params.data_dir}/vep_data", mode: 'copy', overwrite: true
    container "dsbioinfo/musa-helper:latest"
    
    output:
    path "pLI"

    script:
    """
    mkdir pLI
    cd pLI
    wget https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/112/pLI_values.txt
    awk '{print \$2, \$20 }'  pLI_values.txt > plI_gene.txt 
    cd ..
    """
}