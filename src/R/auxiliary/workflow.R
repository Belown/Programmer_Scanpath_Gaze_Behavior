# =========================================================
# Workflow module
# =========================================================
# This module implements a multi-stage model validation workflow for linear and 
# generalized linear mixed models (LMMs/GLMMs). It provides functions to:
#   1. Check and validate model assumptions
#   2. Test significance of interaction terms
#   3. Apply transformations when models fail assumption checks
#   4. Convert between model types (LMM to GLMM) when necessary
# The workflow follows a systematic approach to ensure statistical validity,
# with three progressive stages of model refinement.
# =========================================================

library(here)
library(glmmTMB)

source(file.path(here(), "src", "R", "auxiliary", "assumptions_LMM.R"))
source(file.path(here(), "src", "R", "auxiliary", "assumptions_GLMM.R"))
source(file.path(here(), "src", "R", "auxiliary", "emip", "helper.R"))

#' Helper function that combine function workflow and print_model_table
#' 
#' @param m_list A list of fitted models (either LMM or GLMM)
#' @param config Configuration for assumption checks
#' @return A list containing the final models after workflow
work_flow_with_print <- function(m_list, config) {
  # --- Run workflow to check model assumptions and get final models ---
  final_result <- work_flow(m_list, config)
  
  # --- Print model summaries with significance annotations ---
  print_model_table(dirname(config$results_log), final_result)
  
  return(final_result)
}

#' Main workflow to check model assumptions with transformations
#' 
#' This function attempts to validate a list of fitted models through a series of transformations:
#' 1. Check the original model.
#' 2. If it fails, apply a log transformation to the response variable and re-check.
#' 3. If it still fails, convert the LMM to a GLMM and re-check.
#' @param m_list A list of fitted models (either LMM or GLMM)
#' @param config Configuration for assumption checks
#' @return A list containing the final models and pass/fail status from sub workflow
work_flow <- function(m_list, config) {
  # Clear previous log if exists
  if (file.exists(config$results_log)) {
    write("", file = config$results_log)
  }
  
  cat("============ Workflow stage 1 ============\n")
  line <- paste0("\n", strrep("=", 40), " Workflow Stage 1 ", strrep("=", 40))
  write(line, config$results_log, append = TRUE)
  
  result_1 <- sub_workflow(m_list, config)
  if (result_1$pass) {
    return (result_1$m_list)
  } else {
    cat("============ Workflow stage 2 ============\n")
    line <- paste0("\n", strrep("=", 40), " Workflow Stage 2 ", strrep("=", 40))
    write(line, config$results_log, append = TRUE)
    
    ms <- m_list
    ms_logit <- list()
    for (dim in names(ms)) {
      m <- ms[[dim]]
      
      # Just refit with transformed response, keeping RHS the same
      ms_logit[[dim]] <- update(m, formula = update(formula(m), logit01(.) ~ .)
      )
      message("Using logit-style transformation ([-1,1] -> [0,1] -> logit) for ", dim)
    }
    result_2 <- sub_workflow(ms_logit, config)
    if (result_2$pass) {
      return (result_2$m_list)
    } else {
      cat("============ Workflow stage 3 ============\n")
      line <- paste0("\n", strrep("=", 40), " Workflow Stage 3 ", strrep("=", 40))
      write(line, config$results_log, append = TRUE)
      
      family_list <- setNames(
        replicate(length(names(m_list)), gaussian(), simplify = FALSE),
        names(m_list)
      )
      glmms <- lmm_to_glmm(ms, family_list)
      result_3 <- sub_workflow(glmms, config)
      if (result_3$pass) {
        return (result_3$m_list)
      } else {
        cat("⚠️⚠️⚠️All model transformations failed to meet assumptions.\n")
      }
    }
  }
}

#' Sub-workflow to check interaction and model assumptions based on model type
#' 
#' This function takes a list of fitted model and configuration, checks for 
#' interaction significance, and then applies the appropriate assumption checks 
#' based on whether the model is an LMM or GLMM.
#' @param m_list A list of fitted models (either LMMs or GLMMs)
#' @param config Configuration for assumption checks
#' @return A list containing checked models and pass/fail status
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
    m_list = final_models,
    pass = assumption_results$overall_pass
  ))
}

#' Check Significance of Interaction Terms in LMM/GLMM with hierarchical model
#' 
#' This function takes a list of fitted LMM/GLMM models and performs a
#' hierarchical, backward elimination of interaction terms based on
#' likelihood ratio tests (LRTs).
#' 
#' @param m_list A list of fitted LMM/GLMM objects.
#' @param alpha Significance level for LRTs (default is 0.05)
#' @return A list of fitted LMM/GLMM objects with non-significant interactions removed.
check_interaction <- function(m_list, alpha = 0.05) {
  final_result <- list()
  
  for (dim in names(m_list)) {
    m_full <- m_list[[dim]]
    
    # Extract fixed-effect terms labels from the full model
    tt <- terms(m_full)
    term_lbl <- attr(tt, "term.labels")
    
    # Get all interaction terms
    int_terms <- term_lbl[grepl(":", term_lbl)]
    
    if (length(int_terms) == 0) {
      cat("No interaction terms in model for", dim, ".\n")
      final_result[[dim]] <- m_full
      next
    }
    
    # Determine interaction order for the hierarchical model
    int_order <- vapply(strsplit(int_terms, ":", fixed = TRUE),
                        length, integer(1))
    max_order <- max(int_order)
    
    # Start with current model and remove interaction terms stepwise
    m_current <- m_full
    
    for (k in seq(from = max_order, to = 2, by = -1)) {
      term_k <- int_terms[int_order == k]
      if (length(term_k) == 0) {
        next
      }
      cat("  Testing all", k, "-way interactions for", dim, "...\n")
      
      for (term_j in term_k) {
        #  This term might already be dropped from previous step
        current_terms <- attr(terms(m_current), "term.labels")
        if (!(term_j %in% current_terms)) {
          next
        }
        drop_formula <- as.formula(paste(". ~ . -", term_j))
        
        # Fit reduced model depending on class
        if (inherits(m_current, "glmmTMB")) {
          updated_formula <- update(formula(m_current), drop_formula)
          dat             <- m_current$frame
          family_used     <- family(m_current)
          
          m_reduced <- glmmTMB(
            formula = updated_formula,
            data    = dat,
            family  = family_used,
            control = glmmTMBControl(
              optimizer = nlminb,
              optCtrl  = list(eval.max = 1000, iter.max = 500),
              parallel = 1
            )
          )
        } else {
          # lmer / glmer / lmerMod / glmerMod etc.
          m_reduced <- update(m_current, drop_formula)
        }
        
        # Likelihood ratio test: reduced vs current
        lrt <- anova(m_reduced, m_current)
        p_j <- lrt$`Pr(>Chisq)`[2]
        
        if (!is.na(p_j) && p_j < alpha) {
          # Interaction is significant -> keep it
          cat("✅️ Interaction", term_j, "for", dim,
              "is significant (p =", signif(p_j, 3), "). Keeping it.\n")
          # m_current unchanged
        } else {
          # Interaction is not significant -> drop it
          cat("❌️ Interaction", term_j, "for", dim,
              "is NOT significant (p =", signif(p_j, 3), "). Dropping it.\n")
          m_current <- m_reduced
        }
      }
    }
    
    final_result[[dim]] <- m_current
  }
  
  return (final_result)
}

#' Check assumptions for all dimensions with automatic model type detection
#' 
#' Based on type of model (LMM or GLMM) do different assumption testing
#' For LMM: Linearity of the relationship between predictors and response, 
#'          Homoscedasticity of residual variance, Independence of observations, 
#'          Normality of residuals, Normality of random effects
#' For GLMM: Distributional assumption, Correct link function, Independence, 
#'           Random effects normality, No overdispersion/zero inflation
#' 
#' @param m_list A list of fitted models (LMM or GLMM)
#' @param config Configuration for assumption checks
#' @return List with overall status and detailed results for each dimension/model
check_assumptions_all_dimensions <- function(m_list, config) {
  results <- list()
  pass_count <- 0
  total_dimensions <- length(names(m_list))
  
  for (dim in names(m_list)) {
    model <- m_list[[dim]]
    # Determine model type and call appropriate assumption check
    if (inherits(model, "lmerMod")) {
      # Linear Mixed Model
      result <- check_all_assumptions(model, dim, config)
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
    
    results[[dim]] <- result
    
    # Count passed assumptions
    if (!is.null(result$summary) && 
        result$summary$status %in% c("excellent", "acceptable")) {
      pass_count <- pass_count + 1
    }
  }
  
  overall_pass <- pass_count >= total_dimensions
  
  return(list(
    overall_pass = overall_pass,
    pass_count = pass_count,
    total_dimensions = total_dimensions,
    detailed_results = results
  ))
}

#' Convert list of LMMs to list of GLMMs with specified family
#' 
#' Convert LMM to GLMM by reading the formula and data from each LMM and use manual control
#' 
#' @param m_list A list of fitted LMM models (lmerMod)
#' @param family_list A list of family objects for GLMM (e.g., binomial, poisson)
#' @return A list of fitted GLMM models (glmerMod)
lmm_to_glmm <- function(m_list, family_list) {
  update_list <- list()
  for (dim in names(m_list)) {
    model <- m_list[[dim]]
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
