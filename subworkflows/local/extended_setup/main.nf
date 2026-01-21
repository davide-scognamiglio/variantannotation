include { DOWNLOAD_ALPHAMISSENSE } from '../../../modules/local/download_alphamissense'
include { DOWNLOAD_ANCESTRALALLELE } from '../../../modules/local/download_ancestralallele'
include { DOWNLOAD_CADD } from '../../../modules/local/download_cadd'
include { DOWNLOAD_CLINPRED } from '../../../modules/local/download_clinpred'
include { DOWNLOAD_DBNSFP } from '../../../modules/local/download_dbnsfp'
include { DOWNLOAD_DBSCSNV } from '../../../modules/local/download_dbscsnv'
include { DOWNLOAD_ENFORMER } from '../../../modules/local/download_enformer'
include { DOWNLOAD_EVE } from '../../../modules/local/download_eve'
include { DOWNLOAD_GWAS } from '../../../modules/local/download_gwas'
include { DOWNLOAD_MAVEDB } from '../../../modules/local/download_mavedb'
include { DOWNLOAD_MAXENTSCAN } from '../../../modules/local/download_maxentscan'
include { DOWNLOAD_MUTFUNC } from '../../../modules/local/download_mutfunc'
include { DOWNLOAD_PHENOTYPEORTHOLOGOUS } from '../../../modules/local/download_phenotypeorthologous'
include { DOWNLOAD_PHENOTYPES } from '../../../modules/local/download_phenotypes'
include { DOWNLOAD_PLI } from '../../../modules/local/download_pli'
include { DOWNLOAD_REFERENCEQUALITY } from '../../../modules/local/download_referencequality'
include { DOWNLOAD_SPLICEVAULT } from '../../../modules/local/download_splicevault'
include { DOWNLOAD_UTRANNOTATOR } from '../../../modules/local/download_utrannotator'

workflow EXTENDED_SETUP {

    // main:
        // # TESTED ✔
        DOWNLOAD_ALPHAMISSENSE()
        DOWNLOAD_ANCESTRALALLELE()
        DOWNLOAD_CADD()
        DOWNLOAD_CLINPRED() // gdown is not supported by download_and_check.sh script !
        DOWNLOAD_DBNSFP()
        DOWNLOAD_DBSCSNV() // issue, content-length missing !
        DOWNLOAD_ENFORMER()
        DOWNLOAD_EVE() // issue, content-length missing !
        DOWNLOAD_GWAS()
        DOWNLOAD_MAVEDB()
        DOWNLOAD_MAXENTSCAN() // wget github repo -> content-length missing !
        DOWNLOAD_MUTFUNC()
        DOWNLOAD_PHENOTYPEORTHOLOGOUS()
        DOWNLOAD_PHENOTYPES()
        DOWNLOAD_PLI()
        DOWNLOAD_REFERENCEQUALITY() // issue, content-length not parsed !
        DOWNLOAD_SPLICEVAULT()
        DOWNLOAD_UTRANNOTATOR()
}
