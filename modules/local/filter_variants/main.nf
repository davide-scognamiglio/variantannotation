/*
 * nf-core/variantannotation
 * Module: FILTER_VARIANTS
 * Purpose: Apply HPO or panel-based filtering to MAF
 */


process FILTER_VARIANTS {
    tag "filter-maf"
    cpus 1
    memory { 18.GB * task.attempt }
    errorStrategy 'retry'
    maxRetries 2
    container "dsbioinfo/musa-helper:latest"

    input:
        tuple val(meta), file(maf)

    output:
        val(meta)
        file("${meta.patient}.filtered.maf")
        file("${meta.patient}.raw.maf")


    script:
        """
        variants_filter.R "${maf}" "${meta.patient}" "${meta.hpo}" "${params.offline}"
        """
}