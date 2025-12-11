/*
 * nf-core/variantannotation
 * Module: MERGE_MAF_AND_PARSED_ANNOTATION
 * Purpose: Merge original MAF and parsed VEP annotation into a single MAF
 */


process MERGE_MAF_AND_PARSED_ANNOTATION {
    tag "merge-maf"
    cpus 1
    errorStrategy 'retry'
    maxRetries 1
    memory "2 GB"

    input:
        tuple val(meta), file(parsed_txt), file(maf)

    output:
        tuple val(meta), file("${meta.patient}.merged.maf")

    script:
        """
        paste ${maf} ${parsed_txt} > ${meta.patient}.merged.maf
        """
}