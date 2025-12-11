
include {BCFTOOLS_NORM_SPLIT_MULTIALLELIC} from '../../../modules/local/bcftools_norm_split_multiallelic'
include {BCFTOOLS_FILTER_SYMBOLIC_ALLELES} from '../../../modules/local/bcftools_filter_symbolic_alleles'
include {GATK_VARIANTFILTRATION_HARDFILTER} from '../../../modules/local/gatk_variantfiltration_hardfilter'
include {BCFTOOLS_NORM_REFALIGN_VCF} from '../../../modules/local/bcftools_norm_refalign_vcf'
include {BCFTOOLS_FILTER_NONVARIANT_GT} from '../../../modules/local/bcftools_filter_nonvariant_gt'
include {RENAME_VCF_BY_PATIENT} from '../../../modules/local/rename_vcf_by_patient'


workflow PREPROCESS {

    take: vcf 

    main:
        // If skipping BCFTOOLS, pass input directly
        if (params.skip_bcftools) {
            ch_for_next = vcf
        } else {
            // Mandatory normalization and splitting
            ch1 = BCFTOOLS_NORM_SPLIT_MULTIALLELIC(vcf)
            ch2 = BCFTOOLS_FILTER_SYMBOLIC_ALLELES(ch1)

            // Optional hardfiltering for sarek VCFs
            if (params.vcf_format == "sarek") {
                ch3 = GATK_VARIANTFILTRATION_HARDFILTER(ch2)
                ch_for_next = ch3
            } else {
                ch_for_next = ch2
            }

            // Mandatory normalization, filtering, and renaming
            ch4 = BCFTOOLS_NORM_REFALIGN_VCF(ch_for_next)
            ch5 = BCFTOOLS_FILTER_NONVARIANT_GT(ch4)
            ch_for_next = ch5
        }

        // Renaming is always applied
        ch6 = RENAME_VCF_BY_PATIENT(ch_for_next)

    emit:
        ch6
}
