library(here)
source(file.path(here(), "src", "R", "auxiliary", "assumptions_LMM.R"))
source(file.path(here(), "src", "R", "auxiliary", "assumptions_GLMM.R"))
dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")

#' Sub-workflow to check interaction and model assumptions based on model type
#' 
#' This function takes a fitted model and configuration, checks for interaction significance,
#' and then applies the appropriate assumption checks based on whether the model is an LMM or GLMM.
#' @param m_full A fitted model (either LMM or GLMM)
#' @param config Configuration for assumption checks
#' @return A list containing the final model and pass/fail status
sub_workflow <- function(m_full, config){
  final_model <- check_interaction(m_full)
  
  if (inherits(final_model, "lmerMod")) {
    message("Final model is a linear mixed model (LMM).")
    message("Apply the assumption check for lmer")
    
    # Check assumptions for all dimensions
    assumption_results <- check_assumptions_all_dimensions(final_model, config)
    
    if (assumption_results$overall_pass) {
      message("Overall assumption check: PASS (", 
              assumption_results$pass_count, "/", 
              assumption_results$total_dimensions, " dimensions passed)")
    } else {
      message("Overall assumption check: FAIL (", 
              assumption_results$pass_count, "/", 
              assumption_results$total_dimensions, " dimensions passed)")
    }
    return (list(
      model = final_model,
      pass = assumption_results$overall_pass
    ))
    
  } else if (inherits(final_model, "glmerMod")) {
    message("Final model is a generalized linear mixed model (GLMM).")
    message("Apply the assumption check for glmer")
    # TODO: Implement GLMM assumption checks
    
  } else {
    stop("Final model is of unknown type.")
  }
}



#' Check Significance of Interaction Terms in a LMM
#' 
#' This function checks whether interaction terms in a given LMM are statistically significant.
#' If the interaction terms are not significant, it returns an additive model without interactions.
#' If they are significant, it returns the original model.
#' 
#' @param m_full A fitted linear mixed model (LMM) object.
#' @return A fitted LMM object, either the original model or the additive model.
check_interaction <- function(m_full) {
  # Extract ALL interaction terms
  tt <- terms(m_full)
  term_lbl  <- attr(tt, "term.labels")
  
  # Detect all terms containing ":" (i.e., interactions of any order)
  interaction_terms <- term_lbl[grepl(":", term_lbl)]
  
  # Build the additive model by removing ALL interaction terms
  if (length(interaction_terms) > 0) {
    # construct the drop formula
    drop_formula <- as.formula(
      paste(". ~ . -", paste(interaction_terms, collapse = " - "))
    )
    # Change the full model to additive model
    m_add <- update(m_full, drop_formula)
  } else {
    # No interactions detected
    return(m_full)
  }
  
  # Use likelihood ratio test to check if the interaction significant?
  lrt <- anova(m_add, m_full)
  p_int <- lrt$`Pr(>Chisq)`[2]
  alpha <- 0.05
  
  # Choose final model
  if (!is.na(p_int) && p_int < alpha) {
    final_model <- m_full
    message("Interaction is significant (p = ", signif(p_int, 3), "). Using the interaction model.")
  } else {
    final_model <- m_add
    message("Interaction is NOT significant (p = ", signif(p_int, 3), "). Using additive model.")
  }
  return (final_model)
}

#' Check assumptions for all dimensions and determine overall pass/fail
#' 
#' @param model A fitted LMM model
#' @param config Configuration for assumption checks
#' @return List with overall status and detailed results for each dimension
check_assumptions_all_dimensions <- function(model, config) {
  results <- list()
  pass_count <- 0
  
  for (dim in dimensions) {
    cat("\n--- Checking assumptions for", dim, "---\n")
    result <- check_all_assumptions(model, dim, config)
    results[[dim]] <- result
    
    # Count passed assumptions (assuming result$summary$status exists)
    if (!is.null(result$summary) && 
        result$summary$status %in% c("excellent", "acceptable")) {
      pass_count <- pass_count + 1
    }
  }
  
  # More than half of dimensions must pass
  majority_threshold <- ceiling(length(dimensions) / 2)
  overall_pass <- pass_count >= majority_threshold
  
  return(list(
    overall_pass = overall_pass,
    pass_count = pass_count,
    total_dimensions = length(dimensions),
    detailed_results = results
  ))
}

