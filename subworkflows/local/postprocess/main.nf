include {FILTER_VARIANTS} from '../../../modules/local/filter_variants'
include {BUILD_ANNOTATE_REPORT} from '../../../modules/local/build_annotate_report'

workflow POSTPROCESS {

    take: annotated_maf

    main:

    ch1 = FILTER_VARIANTS(annotated_maf)
    ch2 = BUILD_ANNOTATE_REPORT(ch1)

    emit:
        ch2
}
