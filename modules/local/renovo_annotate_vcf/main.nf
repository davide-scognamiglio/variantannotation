/*
 * nf-core/variantannotation
 * Module: RENOVO_ANNOTATE_VCF
 * Purpose: Annotate variants with ReNOVo and generate corresponding MAF file
 */


process RENOVO_ANNOTATE_VCF {
    tag "renovo-annotation"
    cpus 1
    errorStrategy 'retry'
    maxRetries 1
    memory { 18.GB * task.attempt }
    container "dsbioinfo/renovo:1.1.0"

    input:
        tuple val(meta), file(vcf), file(maf)

    output:      
        tuple val(meta), file(vcf), file("${meta.patient}.renovo.maf")
    
    script:
        """
        python /software/renovo/ReNOVo.py \
            -p . -a /annovar \
            -d /data/renovo_humandb \
            -b ${params.build} -c "clinvar_20250721"

        add_renovo_to_maf.py -m ${maf} \
            -r ReNOVo_output/${meta.patient}_ReNOVo_and_ANNOVAR_implemented.txt \
            -o ${meta.patient}.renovo.maf

        mv ReNOVo_output/${meta.patient}_ReNOVo_and_ANNOVAR_implemented.txt renovoAvinput.txt
        """
}