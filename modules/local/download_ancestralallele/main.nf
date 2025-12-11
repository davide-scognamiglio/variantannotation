/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_ANCESTRALALLELE
 * Purpose: Download vep plugin database
 */


process DOWNLOAD_ANCESTRALALLELE {
    tag "vep_setup"    
    publishDir "${params.data_dir}/vep_data", mode: 'copy', overwrite: true
    container "dsbioinfo/musa-helper:latest"

    output:
    path "AncestralAllele"

    script:
    """
    mkdir -p AncestralAllele
    wget -P AncestralAllele https://ftp.ensembl.org/pub/current_fasta/ancestral_alleles/homo_sapiens_ancestor_GRCh38.tar.gz
    tar xfz AncestralAllele/homo_sapiens_ancestor_GRCh38.tar.gz -C AncestralAllele
    bgzip -c AncestralAllele/homo_sapiens_ancestor_GRCh38/*.fa > AncestralAllele/homo_sapiens_ancestor_GRCh38.fa.gz
    rm -rf AncestralAllele/homo_sapiens_ancestor_GRCh38/ AncestralAllele/homo_sapiens_ancestor_GRCh38.tar.gz
    """
}