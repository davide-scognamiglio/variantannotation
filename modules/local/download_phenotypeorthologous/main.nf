/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_PHENOTYPEORTHOLOGOUS
 * Purpose: Download vep plugin database
 */


process DOWNLOAD_PHENOTYPEORTHOLOGOUS {
    tag "vep_setup"
    publishDir "${params.data_dir}/vep_data", mode: 'copy', overwrite: true
    container "dsbioinfo/musa-helper:latest"
    
    output:
    path "PhenotypeOrthologous"

    script:
    """
    mkdir -p PhenotypeOrthologous
    cd PhenotypeOrthologous
    wget https://ftp.ensembl.org/pub/current_variation/PhenotypeOrthologous/PhenotypesOrthologous_homo_sapiens_112_GRCh38.gff3.gz
    wget https://ftp.ensembl.org/pub/current_variation/PhenotypeOrthologous/PhenotypesOrthologous_homo_sapiens_112_GRCh38.gff3.gz.tbi
    cd ..
    """
}