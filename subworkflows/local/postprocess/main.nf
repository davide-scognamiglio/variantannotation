include {CLEAN_COLUMNS} from '../../../modules/local/clean_columns'
include {FILTER_VARIANTS} from '../../../modules/local/filter_variants'
include {BUILD_ANNOTATE_REPORT} from '../../../modules/local/build_annotate_report'

workflow POSTPROCESS {

    take: annotated_maf

    main:
    ch1 = CLEAN_COLUMNS(annotated_maf)
    ch2 = FILTER_VARIANTS(ch1)
    ch3 = BUILD_ANNOTATE_REPORT(ch2)

    emit:
        ch3
}
