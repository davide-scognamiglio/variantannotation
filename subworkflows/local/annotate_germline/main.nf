include {VEP_ANNOTATE_VCF} from '../../../modules/local/vep_annotate_vcf'
include {GENEBE_ANNOTATE_VCF} from '../../../modules/local/genebe_annotate_vcf'
include {VCF_TO_MAF} from '../../../modules/local/vcf_to_maf'
include {RENOVO_ANNOTATE_VCF} from '../../../modules/local/renovo_annotate_vcf'
include {PARSE_VEP_ANNOTATION} from '../../../modules/local/parse_vep_annotation'
include {MERGE_MAF_AND_PARSED_ANNOTATION} from '../../../modules/local/merge_maf_and_parsed_annotation'
include {ADD_GENOME_CHANGE} from '../../../modules/local/add_genome_change'
include {ADD_REF_CONTEXT} from '../../../modules/local/add_ref_context'

workflow ANNOTATE_GERMLINE {

    take: vcf

    main:
        ch1 = VEP_ANNOTATE_VCF(vcf)
        ch2 = params.offline ? ch1 : GENEBE_ANNOTATE_VCF(ch1)        
        ch3 = VCF_TO_MAF(ch2)
        ch4 = RENOVO_ANNOTATE_VCF(ch3)
        ch5 = PARSE_VEP_ANNOTATION(ch4)
        ch6 = MERGE_MAF_AND_PARSED_ANNOTATION(ch5)
        ch7 = ADD_GENOME_CHANGE(ch6)
        ch8 = ADD_REF_CONTEXT(ch7)

    emit: 
        ch8
}
