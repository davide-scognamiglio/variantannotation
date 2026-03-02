/*
 * nf-core/variantannotation
 * Module: CLEAN_COLUMNS
 * Purpose: Drop duplicate columns and clean the file a little bit
 */

process CLEAN_COLUMNS {
    tag "clean-maf"
    cpus 1
    memory { 18.GB * task.attempt }
    errorStrategy 'retry'
    maxRetries 2
    container "dsbioinfo/musa-helper:latest"

    input:
        tuple val(meta), file(maf)

    output:
        tuple val(meta), file("${maf.baseName}.cleaned.maf")

     script:
    """
        ls -lah

        # Columns to drop
        cols_to_drop=('CHROM', 'REF', 'ALT', 'FILTER', 'Ensembl_geneid', 'POS' 'ID' 'Allele' 'HGVSp' 'MANE' 'TSL' 'APPRIS')

        # Read header line
        header="\$(head -n1 ${maf})"

        # Find positions of columns to keep
        cols_to_keep=()
        i=1
        for col in \$(echo "\$header" | tr '\\t' '\\n'); do
            skip=false
            for drop in "\${cols_to_drop[@]}"; do
                if [[ "\$col" == "\$drop" ]]; then
                    skip=true
                    break
                fi
            done
            if ! \$skip; then
                cols_to_keep+=("\$i")
            fi
            ((i++))
        done

        # Join positions into comma-separated string
        cols_to_keep_str=\$(IFS=, ; echo "\${cols_to_keep[*]}")

        # Extract only the columns to keep
        cut -f\$cols_to_keep_str ${maf} > ${maf.baseName}.cleaned.maf
        """
}