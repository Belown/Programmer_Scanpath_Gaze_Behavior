library(here)
library(glmmTMB)
source(file.path(here(), "src", "R", "auxiliary", "assumptions_LMM.R"))
source(file.path(here(), "src", "R", "auxiliary", "assumptions_GLMM.R"))
dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")

#' Main workflow to check model assumptions with transformations
#' 
#' This function attempts to validate a list of fitted models through a series of transformations:
#' 1. Check the original model.
#' 2. If it fails, apply a log transformation to the response variable and re-check.
#' 3. If it still fails, convert the LMM to a GLMM and re-check.
#' @param m_list A list of fitted models (either LMM or GLMM)
#' @param config Configuration for assumption checks
#' @return A list containing the final models and pass/fail status
work_flow <- function(m_list, config){
  cat("============ Workflow stage 1 ============\n")
  result_1 <- sub_workflow(m_list, config)
  if (result_1$pass) {
    return (result_1$models)
  } else {
    cat("============ Workflow stage 2 ============\n")
    ms <- m_list
    ms_logit <- list()
    for (dim in dimensions) {
      m <- ms[[dim]]
      
      # Just refit with transformed response, keeping RHS the same
      ms_logit[[dim]] <- update(m, formula = update(formula(m), logit01(.) ~ .)
      )
      message("Using logit-style transformation ([-1,1] -> [0,1] -> logit) for ", dim)
    }
    result_2 <- sub_workflow(ms_logit, config)
    if (result_2$pass) {
      return (result_2$models)
    } else {
      cat("============ Workflow stage 3 ============\n")
      family_list <- setNames(
        replicate(length(dimensions), gaussian(), simplify = FALSE),
        dimensions
      )
      glmms <- lmm_to_glmm(ms, family_list)
      result_3 <- sub_workflow(glmms, config)
      if (result_3$pass) {
        return (result_3$models)
      } else {
        stop("All model transformations failed to meet assumptions.")
      }
    }
  }
}

#' Sub-workflow to check interaction and model assumptions based on model type
#' 
#' This function takes a list of fitted model and configuration, checks for interaction significance,
#' and then applies the appropriate assumption checks based on whether the model is an LMM or GLMM.
#' @param m_list A list of fitted models (either LMMs or GLMMs)
#' @param config Configuration for assumption checks
#' @return A list containing the final models and pass/fail status
sub_workflow <- function(m_list, config){
  final_models <- check_interaction(m_list)
  
  # Check assumptions (function handles model type internally)
  message("Checking model assumptions...")
  assumption_results <- check_assumptions_all_dimensions(final_models, config)
  
  # Print results
  if (assumption_results$overall_pass) {
    message("Overall assumption check: PASS (", 
            assumption_results$pass_count, "/", 
            assumption_results$total_dimensions, " dimensions passed)")
  } else {
    message("Overall assumption check: FAIL (", 
            assumption_results$pass_count, "/", 
            assumption_results$total_dimensions, " dimensions passed)")
  }
  
  return(list(
    models = final_models,
    pass = assumption_results$overall_pass
  ))
}

#' Check Significance of Interaction Terms in a LMM
#' 
#' This function checks whether interaction terms in a given list of LMMs are statistically significant.
#' If the interaction terms are not significant, it returns an additive model without interactions.
#' If they are significant, it returns the original model.
#' 
#' @param m_list A list of fitted linear mixed model (LMM) objects.
#' @return A list of fitted LMM objects, either the original model or the additive model.
check_interaction <- function(m_list) {
  final_result <- list()
  for (dim in dimensions) {
    m <- m_list[[dim]]

    # Extract all interaction terms
    tt <- terms(m)
    term_lbl  <- attr(tt, "term.labels")
    
    # Detect all terms containing ":" (i.e., interactions of any order)
    interaction_terms <- term_lbl[grepl(":", term_lbl)]
    
    if(length(interaction_terms) == 0) {
      # No interaction terms present
      final_result[[dim]] <- m
      next
    }

    drop_formula <- as.formula(
      paste(". ~ . -", paste(interaction_terms, collapse = " - "))
    )

    if (inherits(m, "glmmTMB")) {
      updated_formula <- update(formula(m), drop_formula)
      dat <- m$frame
      family_used <- family(m)
      control_params <- m$modelInfo$control
      m_add <- glmmTMB(
        formula = updated_formula,
        data = dat,
        family = family_used,
        control = glmmTMBControl(
          optimizer = nlminb,
          optCtrl = list(eval.max = 1000, iter.max = 500),
          parallel = 1)
      )
    } else {
      # For lmerMod models
      m_add <- update(m, drop_formula)
    }
    
    # Use likelihood ratio test to check if the interaction is significant
    lrt <- anova(m_add, m)
    p_int <- lrt$`Pr(>Chisq)`[2]
    alpha <- 0.05
    
    # Choose final model
    if (!is.na(p_int) && p_int < alpha) {
      final_model <- m
      cat("✅️ Interaction for ", dim, "is significant (p = ", signif(p_int, 3), "). Using the interaction model.\n")
    } else {
      final_model <- m_add
      cat("❌️ Interaction for ", dim, "is NOT significant (p = ", signif(p_int, 3), "). Using additive model.\n")
    }
    final_result[[dim]] <- final_model
  }
  return (final_result)
}

#' Check assumptions for all dimensions with automatic model type detection
#' 
#' @param model_list A list oof fitted models (LMM or GLMM)
#' @param config Configuration for assumption checks
#' @return List with overall status and detailed results for each dimension/model
check_assumptions_all_dimensions <- function(model_list, config) {
  results <- list()
  pass_count <- 0
  
  for (dim in dimensions) {
    model <- model_list[[dim]]
    # Determine model type and call appropriate assumption check
    if (inherits(model, "lmerMod")) {
      # Linear Mixed Model
      result <- check_all_assumptions(model, dim, config)
    # } else if (inherits(model, "glmerMod")) {
    } else{
      # Generalized Linear Mixed Model
      # Need to determine family - extract from model
      family_obj <- family(model)
      if (is.null(family_obj)) {
        stop("Can not determine family for GLMM model.")
      }
      family_used <- family_obj$family
      result <- check_all_glmm_assumptions(model, family_used, config, dim)
    }
    # } else {
    #   stop("Unsupported model type: ", class(model))
    # }
    
    results[[dim]] <- result
    
    # Count passed assumptions
    if (!is.null(result$summary) && 
        result$summary$status %in% c("excellent", "acceptable")) {
      pass_count <- pass_count + 1
    }
  }
  
  # Majority rule: more than half of dimensions must pass
  majority_threshold <- ceiling(length(dimensions) / 2)
  overall_pass <- pass_count >= majority_threshold
  
  return(list(
    overall_pass = overall_pass,
    pass_count = pass_count,
    total_dimensions = length(dimensions),
    detailed_results = results
  ))
}

#' Convert list of LMMs to list of GLMMs with specified family
#' 
#' @param model_list A list of fitted LMM models (lmerMod)
#' @param family_list A list of family objects for GLMM (e.g., binomial, poisson
#' @return A list of fitted GLMM models (glmerMod)
lmm_to_glmm <- function(model_list, family_list) {
  update_list <- list()
  for (dim in dimensions) {
    model <- model_list[[dim]]
    family <- family_list[[dim]]
    
    # Extract formula and data
    f <- formula(model)
    dat <- model@frame

    # Fit GLMM using glmmTMB
    update_list[[dim]] <- glmmTMB(
      formula = f, 
      data = dat, 
      family = family,
      control = glmmTMBControl(
        optimizer = nlminb,
        optCtrl = list(eval.max = 1000, iter.max = 500),
        parallel = 1)
    )
    # Check convergence
    if (update_list[[dim]]$fit$convergence != 0) {
      warning("Model for ", dim, " did not converge properly")
    }
    
  }
  return (update_list)
}

#' Apply logit transformation
#' 
#' @param x Numeric vector with values in [-1, 1]
#' @param eps Small value to avoid log(0)
#' @return Numeric vector with logit-transformed values
logit01 <- function(x, eps = 1e-5) {
  # rescale [-1,1] -> [0,1]
  p <- (x + 1) / 2
  # clamp to avoid exact 0 or 1
  p <- pmin(pmax(p, eps), 1 - eps)
  
  return (log(p / (1 - p)))
}
