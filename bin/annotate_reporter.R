#!/usr/bin/env Rscript
# ---- libraries ---- 
suppressPackageStartupMessages({ 
  library(maftools) 
  library(readr) 
  library(dplyr) 
  library(reactable) 
  library(htmltools)
  library(htmlwidgets)
  library(base64enc)
  library(ggplot2)
  library(gridExtra)
  library(cowplot)
  })

    
args <- commandArgs(trailingOnly = TRUE)

if(length(args) < 5) stop("Usage: Rscript html_reporter.R patient_code workflow use_vep_plugins=BOOL offline=BOOL skip_genebe=BOOL")

patient_code <- args[1]
workflow <- args[2]
use_vep_plugins <- args[3]
offline <- args[4]
skip_genebe <- args[5]

# ---- MAF discovery logic ----
filtered_maf <- paste0(patient_code, ".filtered.maf")
raw_maf <- paste0(patient_code, ".raw.maf")

read_maf_safe <- function(path) {
  if (!file.exists(path)) return(NULL)
  
  df <- tryCatch(
    read.table(
      path,
      sep = '\t',
      header = TRUE,
      quote = '',
      comment.char = '',
      fill = TRUE,
      stringsAsFactors = FALSE,
      check.names = FALSE
    ),
    error = function(e) NULL
  )
  
  if (is.null(df)) return(NULL)
  
  # header-only MAF: zero rows
  if (nrow(df) == 0) return("HEADER_ONLY")
  
  df
}

maf_df <- read_maf_safe(filtered_maf)

if (identical(maf_df, "HEADER_ONLY")) {
  message("Filtered MAF contains only header, falling back to raw MAF")
  maf_df <- read_maf_safe(raw_maf)
}

if (is.null(maf_df)) {
  stop("Neither filtered nor raw MAF could be read for patient: ", patient_code)
}

if (identical(maf_df, "HEADER_ONLY")) {
  stop("Both filtered and raw MAF contain only headers for patient: ", patient_code)
}
maf_df <- maf_df[, !duplicated(colnames(maf_df))] 
var_types <- unique(maf_df$Variant_Classification)
# ----- Build maftools object -----
required_cols <- c(
  "Hugo_Symbol", "Chromosome", "Start_Position", "End_Position",
  "Reference_Allele", "Tumor_Seq_Allele2"
)

missing_cols <- setdiff(required_cols, colnames(maf_df))
if (length(missing_cols) > 0) {
  stop("Missing required MAF columns: ", paste(missing_cols, collapse = ", "))
}

# Build directly from data.frame
maf_obj <- tryCatch({
  read.maf(maf = maf_df, vc_nonSyn = var_types, verbose = TRUE)
}, error = function(e) {
  message("⚠️  read.maf() failed: ", conditionMessage(e))
  stop("Failed to create maf object. Check column names and contents.")
})

# ----- Create plot PNGs (base64 encode to embed) -----
tmpdir <- tempdir()
png_files <- list()

# 1) plotmafSummary (dashboard)
png1 <- file.path(tmpdir, paste0(patient_code, "_maf_summary.png"))
png(filename = png1, width = 1400, height = 800, res = 150)
try(plotmafSummary(maf = maf_obj, rmOutlier = TRUE, addStat = 'median', dashboard = TRUE), silent = TRUE)
dev.off()
png_files$summary <- png1

# 2) oncoplot top 20 (if enough genes)
if(workflow != "annotate"){
  png2 <- file.path(tmpdir, paste0(patient_code, "_oncoplot.png"))
  png(filename = png2, width = 1200, height = 800, res = 150)
  try(oncoplot(maf = maf_obj, top = 20), silent = TRUE)
  dev.off()
  png_files$oncoplot <- png2
  
  # 3) lollipop for top gene (if exists)
  top_genes <- getGeneSummary(maf_obj)
  png3 <- file.path(tmpdir, paste0(patient_code, "_lollipop.png"))
  if (nrow(top_genes) > 0) {
    top_gene <- top_genes$Hugo_Symbol[1]
    png(filename = png3, width = 1000, height = 600, res = 150)
    try(lollipopPlot(maf = maf_obj, gene = top_gene), silent = TRUE)
    dev.off()
    png_files$lollipop <- png3
  }
  
  # 4) tumor mutation burden barplot (if multi-sample)
  png4 <- file.path(tmpdir, paste0(patient_code, "_tmb.png"))
  png(filename = png4, width = 1000, height = 600, res = 150)
  try({
    tmb_res <- tmb(maf = maf_obj)
    barplot(tmb_res$tmb, names.arg = tmb_res$Tumor_Sample_Barcode, las = 2, cex.names = 0.6, main = "Tumor Mutation Burden")
  }, silent = TRUE)
  dev.off()
  png_files$tmb <- png4
}

# Helper: read PNG and convert to data URI
img_to_datauri <- function(path) {
  if(!file.exists(path)) return(NULL)
  b <- base64enc::base64encode(path)
  paste0("data:image/png;base64,", b)
}

imgs <- lapply(png_files, img_to_datauri)

# ----- Prepare full dataframe -----
full_df <- maf_df %>%
  mutate(across(everything(), ~ ifelse(is.na(.x), '', as.character(.x))))

# ----- Build column definitions for main table -----
if (toupper(offline) == "FALSE") {
  main_cols <- c(
    "Hugo_Symbol",
    "genome_change",
    "HGVSp_Short",
    "Variant_Classification",
    "CLIN_SIG",
    "acmg_score",
    "acmg_criteria",
    "MAX_AF",
    "MAX_AF_POPS"
  )
} else if(toupper(offline) == "TRUE" | toupper(skip_genebe) == "TRUE") {
  main_cols <- c(
    "Hugo_Symbol",
    "genome_change",
    "HGVSp_Short",
    "Variant_Classification",
    "CLIN_SIG",
    "MAX_AF",
    "MAX_AF_POPS"
  )
}

details_cols <- if (toupper(use_vep_plugins) == "TRUE") {
  c("clinvar_OMIM_id", "clinvar_review", "clinvar_trait", "PUBMED")
} else {
  c("PUBMED")
}

# Keep only those columns that actually exist in the dataframe
main_cols <- intersect(main_cols, colnames(full_df))
details_cols <- intersect(details_cols, colnames(full_df))
desired_cols <- c(main_cols, details_cols)
column_filtered_df <- full_df[, desired_cols, drop = FALSE]

# ----- Update main and details column names to match display names -----
# Build display names only for columns present in column_filtered_df
display_main_cols <- c(
  "gene",
  "genome change",
  "a.a. change",
  "type",
  "clinvar",
  if ("acmg_score" %in% main_cols) "acmg score" else NULL,
  if ("acmg_criteria" %in% main_cols) "acmg criteria" else NULL,
  "max AF",
  "max AF pop"
)

display_details_cols <- gsub("_", " ", details_cols)

# Rename columns in filtered dataframe
colnames(column_filtered_df) <- c(display_main_cols, display_details_cols)

# Debug prints
print("Column names in column_filtered_df:")
print(colnames(column_filtered_df))
print("Main columns:")
print(display_main_cols)
print("Details columns:")
print(display_details_cols)

# Only do this if PUBMED column exists
if("PUBMED" %in% colnames(column_filtered_df)) {
  column_filtered_df$PUBMED <- sapply(column_filtered_df$PUBMED, function(x) {
    if(is.na(x) || x == "") return("")
    
    # Split by comma, trim whitespace
    ids <- trimws(unlist(strsplit(as.character(x), ",")))
    
    # Build clickable links
    links <- paste0('<a href="https://pubmed.ncbi.nlm.nih.gov/', ids, '/" target="_blank">', ids, '</a>')
    
    # Combine into a single HTML string
    htmltools::HTML(paste(links, collapse = ", "))
  })
}
if ("acmg score" %in% colnames(column_filtered_df)) {
  column_filtered_df$`acmg score` <- as.numeric(column_filtered_df$`acmg score`)
}
print("colnames(column_filtered_df)")
print(colnames(column_filtered_df))
# Only select columns that exist in the filtered dataframe
main_cols_present <- intersect(display_main_cols, colnames(column_filtered_df))

maf_table <- reactable(
  column_filtered_df[, main_cols_present, drop = FALSE],
  defaultSorted = if("acmg score" %in% main_cols_present) list(`acmg score` = "desc") else list(`max AF` = "desc"),
  columns = list(
    `max AF` = colDef(cell = function(value) {
      if (is.na(value)) htmltools::HTML("Absent")
      else if (value > 0.05) htmltools::HTML(paste0("Common (", value, ")"))
      else htmltools::HTML(paste0("Rare (", value, ")"))
    })
  ),
  searchable = TRUE, filterable = TRUE,
  pagination = TRUE, defaultPageSize = 10,
  highlight = TRUE, striped = TRUE,
  bordered = TRUE, compact = TRUE,
  defaultColDef = colDef(
    headerStyle = list(background = "#209957", color = "white", fontWeight = "600"),
    style = list(padding="6px")
  ),
  details = function(index) {
    row <- column_filtered_df[index, display_details_cols, drop = FALSE]

    reactable(
      row,
      columns = list(
        PUBMED = colDef(html = TRUE, minWidth = 300)
      ),
      searchable = FALSE, filterable = FALSE,
      pagination = FALSE, highlight = FALSE,
      striped = FALSE, bordered = TRUE, compact = TRUE,
      defaultColDef = colDef(
        minWidth = 120,
        headerStyle = list(background = "#e5e7eb", fontWeight = "600"),
        style = list(padding = "4px")
      ),
      fullWidth = TRUE
    )
  }
)



# ----- Custom CSS -----
custom_css <- "
    body { background-color:#f5f8fa; font-family:'Poppins',sans-serif; padding:20px; }
    .container { max-width:1400px; margin:auto; }
    h1 { color:#209957; font-weight:700; margin-bottom:12px; }
    .card { border-radius:12px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); background:#fff; padding:18px; margin-bottom:18px; }
    .plot-title { font-weight:700; color:#333; margin-bottom:8px; font-size:16px; }
    .meta-row { color:#666; font-size:13px; margin-bottom:10px; }
    .btn { border-radius:8px; padding:6px 12px; }
    "

# ----- Build HTML page -----
imgs_tags <- list()
if(!is.null(imgs$summary)) imgs_tags$summary <- tags$img(src = imgs$summary, style="max-width:100%; height:auto; border-radius:8px;")
if(!is.null(imgs$oncoplot)) imgs_tags$oncoplot <- tags$img(src = imgs$oncoplot, style="max-width:100%; height:auto; border-radius:8px;")
if(!is.null(imgs$lollipop)) imgs_tags$lollipop <- tags$img(src = imgs$lollipop, style="max-width:100%; height:auto; border-radius:8px;")
if(!is.null(imgs$tmb)) imgs_tags$tmb <- tags$img(src = imgs$tmb, style="max-width:100%; height:auto; border-radius:8px;")

html_page <- tags$html(
  lang = "en",
  tags$head(
    tags$title(paste0('nf-core/variantannotation dashboard: ', patient_code)),
    tags$link(rel="stylesheet", href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap"),
    tags$style(HTML(custom_css)),
    tags$meta(charset="utf-8")
  ),
  tags$body(
    tags$div(class="container",
             tags$h1(paste0("Patient: ", patient_code, " - Variant Dashboard")),
             tags$div(class="meta-row", paste0("Generated: ", Sys.time())),
             tags$div(class="card",
                      tags$div(style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;",
                               tags$div(style="font-weight:600; font-size:16px;", "Interactive table")
                      ),
                      tags$div(style="overflow:auto;", maf_table)
             ),
             tags$div(class="card",
                      tags$div(class="plot-title","Variant Summary"),
                      imgs_tags$summary
             ),
             
             # Include tumor-only plots ONLY if workflow != "germline"
             if (workflow != "germline") {
               list(
                 tags$div(class="card", style="display:grid; grid-template-columns: 1fr 1fr; gap:16px;",
                          tags$div(
                            tags$div(class="plot-title", "Oncoplot (top 20)"),
                            imgs_tags$oncoplot
                          ),
                          tags$div(
                            tags$div(class="plot-title", paste0("Lollipop: ", ifelse(exists('top_gene'), top_gene, 'N/A'))),
                            imgs_tags$lollipop
                          )
                 ),
                 
                 tags$div(class="card",
                          tags$div(class="plot-title","Tumor Mutation Burden"),
                          imgs_tags$tmb
                 )
               )
             },
             tags$footer(style="margin-top:18px; color:#777; font-size:13px;",
                         HTML(paste0("nf-core/variantannotation pipeline - ", "Report for <strong>", patient_code, "</strong>")))        
             )
  )
)

# Save self-contained HTML: use save_html (htmltools) which will inline widgets; images are already data URIs
outfile <- paste0(patient_code, "_maf_dashboard.html")
htmltools::save_html(html_page, file = outfile, background = "#ffffff")
cat("Saved dashboard to: ", outfile, "\\n")