/*
 * nf-core/variantannotation
 * Module: VCF_TO_MAF
 * Purpose: Convert a VCF to a MAF file using vcf2maf
 */


process VCF_TO_MAF {
    tag "vcf2maf"
    cpus 1
    memory "1 GB"
    container "dsbioinfo/vcf2maf:latest"

    input:
        tuple val(meta), file(vcf)

    output:
        tuple val(meta), file(vcf), file("${meta.patient}.maf")

    script:
        """
        awk 'BEGIN{OFS="\t"}
            /^#/ {print; next}  # print header lines as-is
            {
                # Normalize mitochondrial chromosome
                if (\$1 == "chrMT" || \$1 == "MT") \$1 = "chrM"

                # Add "chr" prefix to numeric or X/Y chromosomes if missing
                if (\$1 !~ /^chr/) \$1 = "chr"\$1

                print
            }' ${vcf} > ${vcf.simpleName}.with_chr.vcf

            mv ${vcf.simpleName}.with_chr.vcf ${vcf}

        export REF_FASTA=/data/vep_data/reference_genome/${params.build}.fa

        perl /opt/vcf2maf.pl \
            --input-vcf ${vcf} \
            --output-maf ${meta.patient}.tmp.maf \
            --ref-fasta \$REF_FASTA \
            --inhibit-vep

        tail -n +2 ${meta.patient}.tmp.maf > ${meta.patient}.maf
        """
}