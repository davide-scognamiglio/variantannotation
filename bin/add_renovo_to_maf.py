#!/usr/bin/env python3

import argparse
import pandas as pd

def parse_args():
    parser = argparse.ArgumentParser(description="Append RENOVO columns to MAF based on genomic coordinates.")
    parser.add_argument("-m", "--maf", required=True, help="Input MAF file")
    parser.add_argument("-r", "--renovo", required=True, help="Input RENOVO TXT file")
    parser.add_argument("-o", "--output", default="output.maf", help="Output MAF file (default: output.maf)")
    return parser.parse_args()

def main():
    args = parse_args()

    # Read files
    maf = pd.read_csv(args.maf, sep="\t", low_memory=False)
    renovo = pd.read_csv(args.renovo, sep="\t", low_memory=False)

    # Keep only relevant columns in RENOVO file                           # chrom       # POS          # REF        # ALT (VCF 1 BASED)
    renovo = renovo[["Chr", "Start", "End", "Ref", "Alt", "RENOVO_Class", "PL_score", "Otherinfo4", "Otherinfo5", "Otherinfo7","Otherinfo8", "PVS1","PS1","PS2","PS3","PS4","PM1","PM2","PM3","PM4","PM5","PM6","PP1","PP2","PP3","PP4","PP5","BA1","BS1","BS2","BS3","BS4","BP1","BP2","BP3","BP4","BP5","BP6","BP7"]]

    # Merge based on genomic coordinates
    merged = pd.merge(
        maf,
        renovo,
        how="left",
        left_on=["Chromosome", "Start_Position", "Reference_Allele", "Tumor_Seq_Allele2"],
        right_on=["Chr", "Start", "Ref", "Alt"]
    )

    # Drop duplicate key columns from RENOVO
   # merged = merged.drop(columns=["Chr", "Start", "End"])

    # Write output
    merged.to_csv(args.output, sep="\t", index=False)

if __name__ == "__main__":
    main()
