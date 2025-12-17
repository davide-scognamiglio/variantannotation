process MERGE_MAF_AND_PARSED_ANNOTATION {

    tag "merge-maf:${meta.patient}"
    cpus 1
    memory "2 GB"
    errorStrategy 'retry'
    maxRetries 1

    input:
        tuple val(meta), file(parsed_txt), file(maf)

    output:
        tuple val(meta), file("${meta.patient}.merged.maf")

    script:
    """
    set -euo pipefail

    TXT_IN="${parsed_txt}"
    MAF_IN="${maf}"
    OUT="${meta.patient}.merged.maf"

    TXT_NORM="txt.norm.tsv"
    MAF_NORM="maf.norm.tsv"

    TXT_KEY_COLS=("CHROM" "POS" "REF" "ALT")
    MAF_KEY_COLS=("Otherinfo4" "vcf_pos" "Otherinfo7" "Otherinfo8")

    MAF_KEEP_COLS=("Hugo_Symbol" "Center" "HGVSp_Short" "Chromosome" "Start_Position" "vcf_pos" "End_Position" "Variant_Classification" "Tumor_Sample_Barcode" "Variant_Type" "Reference_Allele" "Tumor_Seq_Allele1" "Tumor_Seq_Allele2" "RENOVO_Class" "PL_score")

    # 1. Normalize TXT file
    awk -F'\\t' -v OFS='\\t' -v key_cols="\${TXT_KEY_COLS[*]}" '
    BEGIN { split(key_cols, kc, " ") }
    NR==1 {
        for (i=1; i<=NF; i++) hdr[\$i]=i
        for (k in kc) if (!(kc[k] in hdr)) { print "ERROR: Missing TXT column", kc[k] > "/dev/stderr"; exit 1 }
        print "KEY", \$0
        next
    }
    {
        gsub(/\\r/, "")
        key=""
        for (i=1; i<=length(kc); i++) {
            val = \$(hdr[kc[i]]) ""  # force string
            key = key (i>1 ? "|" : "") val
        }
        print key, \$0
    }
    ' "\${TXT_IN}" | sort -t\$'\\t' -k1,1 > "\${TXT_NORM}"

    # 2. Normalize MAF file
    awk -F'\\t' -v OFS='\\t' -v key_cols="\${MAF_KEY_COLS[*]}" -v keep_cols="\${MAF_KEEP_COLS[*]}" '
    BEGIN {
        split(key_cols, kc, " ")
        split(keep_cols, kc_keep, " ")
    }
    NR==1 {
        for (i=1; i<=NF; i++) hdr[\$i]=i
        for (k in kc) if (!(kc[k] in hdr)) { print "ERROR: Missing MAF key column", kc[k] > "/dev/stderr"; exit 1 }
        for (k in kc_keep) if (!(kc_keep[k] in hdr)) { print "ERROR: Missing MAF keep column", kc_keep[k] > "/dev/stderr"; exit 1 }
        printf "KEY"
        for (i=1; i<=length(kc_keep); i++) printf OFS "%s", kc_keep[i]
        printf "\\n"
        next
    }
    {
        gsub(/\\r/, "")
        key=""
        for (i=1; i<=length(kc); i++) {
            val = \$(hdr[kc[i]]) ""  # force string
            key = key (i>1 ? "|" : "") val
        }
        printf "%s", key
        for (i=1; i<=length(kc_keep); i++) printf OFS "%s", \$(hdr[kc_keep[i]])
        printf "\\n"
    }
    ' "\${MAF_IN}" | sort -t\$'\\t' -k1,1 > "\${MAF_NORM}"

    # 3. Join on composite key and drop KEY column
    join -t \$'\\t' -1 1 -2 1 -a 1 -e "NA" -o auto "\${TXT_NORM}" "\${MAF_NORM}" \
        | cut -f2- > "\${OUT}"
    """
}
