/*
 * nf-core/variantannotation
 * Module: DOWNLOAD_DBNSFP
 * Purpose: Download vep plugin database
 */


process DOWNLOAD_DBNSFP {
    tag "vep_setup"
    publishDir "${params.data_dir}/vep_data", mode: 'copy', overwrite: true
    container "dsbioinfo/musa-helper:latest"

    output:
    path "dbNSFP"

    script:
    """
    set -euo pipefail

    mkdir -p dbNSFP
    cd dbNSFP

    BASE_URL="https://dist.genos.us/academic/01f8c3"
    TOLERANCE=0.1
    METHOD="wget"

    FILES=(
        "dbNSFP5.2a_grch38.gz"
        "dbNSFP5.2a_grch38.gz.tbi"
        "dbNSFP5.2a_grch38.gz.md5"
    )

    for f in "\${FILES[@]}"; do
        FULL_URL="\$BASE_URL/\$f"
        OUT=\$(basename "\$FULL_URL")
        bash download_and_check.sh "\$FULL_URL" \$TOLERANCE \$METHOD \$OUT
    done

    cd ..
    """
}
