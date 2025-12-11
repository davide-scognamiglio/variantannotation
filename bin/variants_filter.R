#!/usr/bin/env Rscript
library(httr)
library(jsonlite)

get_genes_from_hpo_codes <- function(hpo_codes) {
  genesByHPO <- list()
  genes <- list()
  
  for(hpo_code in strsplit(hpo_codes, split = ',')[[1]]) {
    encoded_hpo_code <- gsub(":", "%3A", hpo_code)
    url <- paste0("https://ontology.jax.org/api/network/annotation/", encoded_hpo_code)
    response <- GET(url)
    data <- fromJSON(content(response, "text"))
    
    if(length(data$genes$name) < 1000) {
      genesByHPO[[hpo_code]] <- data$genes$name
    }
  }
  
  allGenes <- unique(unlist(genesByHPO))
  genesIntersect <- if(length(genesByHPO) > 1) Reduce(intersect, genesByHPO) else allGenes
  genes[['HPOgenes_all']] <- allGenes
  genes[['HPOgenes_intersect']] <- genesIntersect
  return(genes)
}

args <- commandArgs(trailingOnly = TRUE)

maf_file <- args[1]
patient_code <- args[2]
hpo_codes <- if(length(args) > 2) args[3] else NULL
offline <- if(length(args) > 3) as.logical(args[4]) else FALSE

# 1. LOAD MAF FILE
raw_maf <- tryCatch({
  read.table(
    maf_file,
    sep = "\t",
    header = TRUE,
    quote = "",
    comment.char = "",
    fill = TRUE,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}, error = function(e) {
  message("⚠️ Warning: malformed lines detected — retrying with relaxed parsing...")
  read.table(
    maf_file,
    sep = "\t",
    header = TRUE,
    quote = "",
    comment.char = "",
    fill = TRUE,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
})

write.table(raw_maf, paste0(patient_code, ".raw.maf"), 
            sep = "\t", quote = FALSE, row.names = FALSE)

# 2. OPTIONAL: Filter by HPO panel
if(!offline && !is.null(hpo_codes)) {
  hpo_genes <- get_genes_from_hpo_codes(hpo_codes)
  genes_to_keep <- intersect(raw_maf$Hugo_Symbol, hpo_genes$HPOgenes_all)
  
  if(length(genes_to_keep) > 0) {
    filtered_maf <- subset(raw_maf, Hugo_Symbol %in% genes_to_keep)
  } else {
    # Write empty dataframe with only headers
    filtered_maf <- raw_maf[0, , drop = FALSE]
  }
  
  # Write panel filtered MAF
  write.table(filtered_maf, paste0(patient_code, ".filtered.maf"), 
              sep = "\t", quote = FALSE, row.names = FALSE)
} else if(offline) {
  message("⚠️ Offline mode enabled: skipping HPO filtering.")
  filtered_maf <- raw_maf[0, , drop = FALSE]
  # Write panel filtered MAF
  write.table(filtered_maf, paste0(patient_code, ".filtered.maf"), 
              sep = "\t", quote = FALSE, row.names = FALSE)
}
