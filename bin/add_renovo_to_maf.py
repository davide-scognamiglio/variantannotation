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

    # Keep only relevant columns in RENOVO file
    renovo = renovo[["Chr", "Start", "End", "RENOVO_Class", "PL_score"]]

    # Merge based on genomic coordinates
    merged = pd.merge(
        maf,
        renovo,
        how="left",
        left_on=["Chromosome", "Start_Position", "End_Position"],
        right_on=["Chr", "Start", "End"]
    )

    # Drop duplicate key columns from RENOVO
    merged = merged.drop(columns=["Chr", "Start", "End"])

    # Write output
    merged.to_csv(args.output, sep="\t", index=False)

if __name__ == "__main__":
    main()
