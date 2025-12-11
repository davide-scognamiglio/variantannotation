/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_VEP_CACHE
 * Purpose: Download VEP cache
 */


process DOWNLOAD_VEP_CACHE {
    tag "vep_setup"
    publishDir "${params.data_dir}", mode: 'copy', overwrite: true
    container "dsbioinfo/ensembl-vep:latest"

    output:
    path "vep_data/vep_cache/homo_sapiens"

    script:
    """
    mkdir -p vep_data/vep_cache
    cd vep_data/vep_cache
    echo "Downloading VEP cache for homo_sapiens GRCh38..."
    curl -O https://ftp.ensembl.org/pub/release-115/variation/indexed_vep_cache/homo_sapiens_vep_115_GRCh38.tar.gz
    tar xzf homo_sapiens_vep_115_GRCh38.tar.gz    
    ls
    cd ../..
    """
}