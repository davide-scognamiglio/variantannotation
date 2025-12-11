include { DOWNLOAD_ANNOVAR_DB } from '../../../modules/local/download_annovar_db'
include { DOWNLOAD_VEP_CACHE } from '../../../modules/local/download_vep_cache'
include { DOWNLOAD_REFGENOME } from '../../../modules/local/download_refgenome'

workflow BASIC_SETUP {

    main:
        DOWNLOAD_ANNOVAR_DB()
        DOWNLOAD_VEP_CACHE()
        DOWNLOAD_REFGENOME()
}
