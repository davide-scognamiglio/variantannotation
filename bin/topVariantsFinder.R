library(dplyr)

# ----------------------- GENERAL FUNCTION -------------------------------------
# Optimized classifyVariants_revised with vectorization and fixed rowwise mutation
classifyVariants_revised <- function(variantsDF, HPO_panel) {
  # Identify columns matching the given patterns
  criteria_cols <- grep("^(PVS|PS|PM|PP|BA|BS|BP)", names(variantsDF), value = TRUE)
  # Compute SIDEVAR score for each row based on matching criteria columns
  variantsDF <- variantsDF %>%
    rowwise() %>%
    mutate(
      SIDEVAR_score = computeSIDEVARscore(across(all_of(criteria_cols)), `Hugo_Symbol`, HPO_panel)
    ) %>%
    ungroup()
  
  return(variantsDF)
}

# -------------------------- SUB FUNCTIONS -------------------------------------
computeSIDEVARscore <- function(criteria, Gene, HPO_panel) {
  # # If BA1 is TRUE, set the score to -30 and return immediately
  print('HPO_panel')
  print(HPO_panel)
  print('Gene')
  print(Gene)
  if (!is.null(criteria$BA1) && "BA1" %in% names(criteria) && criteria$BA1 == TRUE) {
    print("ALL OK IF 1")
    score <- -30
    return(score)
  }
  
  score <- 0
  
  # Define the scoring rules for each criterion
  scoring_rules <- list(
    PVS1 = 20,
    PS = 10,  # PS* values (e.g., PS1, PS2, ...)
    PM = 5,   # PM* values
    PP = 3,   # PP* values
    BA1 = -30,
    BS = -10,  # BS* values
    BP = -3   # BP* values
  )
  
  # Apply scores based on the criteria
  for (criterion in names(criteria)) {
    # Match the criterion key with scoring rules
    for (rule in names(scoring_rules)) {
      if (startsWith(criterion, rule)) {
        print("ALL OK IF 2")
        # Add or subtract the corresponding score
        score <- score + (criteria[[criterion]] * scoring_rules[[rule]])
      }
    }
  }
  
  # If Gene is in HPO_panel, increase the score
  if (Gene %in% HPO_panel) {
    print("ALL OK IF 3")
    score <- score + 10
  }
  
  # Ensure score stays within the range [-30, 30]
  score <- pmin(pmax(score, -30), 30)
  return(score)
}
