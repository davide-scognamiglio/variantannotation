/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

params.date = new java.util.Date().format('yyMMdd')

include { BASIC_SETUP } from '../../subworkflows/local/basic_setup'
include { EXTENDED_SETUP } from '../../subworkflows/local/extended_setup'
// include { BUILD_SETUP_REPORT } from '../../modules/local/build_setup_report'
// find a way to build an html report

workflow SETUP {

    main:
        // Always run basic setup
        BASIC_SETUP()

        // Optionally run extended setup
        if (params.download_vep_plugins==true) {
            EXTENDED_SETUP()
        }
}