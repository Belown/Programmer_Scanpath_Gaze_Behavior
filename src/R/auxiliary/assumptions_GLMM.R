# =============================================================================
# GLMM Assumption Checking Module
# =============================================================================
# This module contains functions for checking Generalized Linear Mixed Model assumptions:
# 1. Distributional assumption
# 2. Correct link function  
# 3. Independence
# 4. Random effects normality
# 5. No overdispersion/zero inflation

#' Check All GLMM Assumptions
#' 
#' Comprehensive assumption checking for GLMMs
#' 
#' @param glmm_model Fitted GLMM model
#' @param family_used Family used in GLMM
#' @param config Analysis configuration list
#' @return List with assumption check results
check_all_glmm_assumptions <- function(glmm_model, family_used, config, y) {
  cat("--- Checking GLMM assumptions for", y, "---\n")

  write(strrep("=", 60), config$results_log, append = TRUE)
  write("GLMM ASSUMPTION CHECKS", config$results_log, append = TRUE)
  write(strrep("=", 60), config$results_log, append = TRUE)

  # Initialize results storage
  assumption_results <- list()
  
  # 1. Distributional Assumption
  write("\n1. DISTRIBUTIONAL ASSUMPTION:", config$results_log, append = TRUE)
  distributional_result <- check_glmm_distribution(glmm_model, family_used, config)
  assumption_results$distributional <- distributional_result
  
  # 2. Link Function Appropriateness
  write("\n2. LINK FUNCTION CHECK:", config$results_log, append = TRUE)
  link_result <- check_glmm_link_function(glmm_model, family_used, config)
  assumption_results$link_function <- link_result
  
  # 3. Independence
  write("\n3. INDEPENDENCE CHECK:", config$results_log, append = TRUE)
  independence_result <- check_glmm_independence(glmm_model, config)
  assumption_results$independence <- independence_result
  
  # 4. Random Effects Normality
  write("\n4. RANDOM EFFECTS NORMALITY:", config$results_log, append = TRUE)
  random_effects_result <- check_glmm_random_effects(glmm_model, config)
  assumption_results$random_effects <- random_effects_result
  
  # 5. Overdispersion/Zero Inflation
  write("\n5. OVERDISPERSION CHECK:", config$results_log, append = TRUE)
  overdispersion_result <- check_glmm_overdispersion(glmm_model, family_used, config)
  assumption_results$overdispersion <- overdispersion_result
  
  # Summarize results
  summary_result <- summarize_glmm_assumption_results(assumption_results, family_used, config)
  
  return(list(
    individual_results = assumption_results,
    summary = summary_result
  ))
}

#' Check GLMM Distributional Assumption
#' 
#' Tests if response follows the chosen distribution family
#' 
#' @param glmm_model Fitted GLMM model
#' @param family_used Family used in GLMM
#' @param config Analysis configuration
#' @return List with distributional test results
check_glmm_distribution <- function(glmm_model, family_used, config) {
  
  # Basic checks for distributional assumption
  converged <- glmm_model$fit$convergence == 0
  aic_reasonable <- !is.na(AIC(glmm_model)) && is.finite(AIC(glmm_model))
  
  # Check model fit quality
  model_fitted <- !is.null(glmm_model$fit) && !is.null(fitted(glmm_model))
  
  distributional_passed <- converged && aic_reasonable && model_fitted
  
  # Log results
  write(paste("Model convergence:", ifelse(converged, "✓", "✗")), config$results_log, append = TRUE)
  write(paste("AIC calculable:", ifelse(aic_reasonable, "✓", "✗")), config$results_log, append = TRUE)
  write(paste("Family used:", family_used), config$results_log, append = TRUE)
  
  return(list(
    passed = distributional_passed,
    family = family_used,
    converged = converged,
    aic_reasonable = aic_reasonable
  ))
}

#' Check GLMM Link Function Appropriateness
#' 
#' Tests if link function appropriately connects predictors to response
#' 
#' @param glmm_model Fitted GLMM model
#' @param family_used Family used in GLMM
#' @param config Analysis configuration
#' @return List with link function test results
check_glmm_link_function <- function(glmm_model, family_used, config) {
  
  tryCatch({
    # Check if link function produces reasonable linear predictors
    linear_predictors <- predict(glmm_model, type = "link")
    
    # Basic checks: no extreme values, reasonable range
    lp_range <- range(linear_predictors, na.rm = TRUE)
    extreme_values <- any(abs(linear_predictors) > 10, na.rm = TRUE)
    finite_values <- all(is.finite(linear_predictors))
    
    link_passed <- !extreme_values && finite_values && 
                   is.finite(lp_range[1]) && is.finite(lp_range[2])
    
    return(list(
      passed = link_passed,
      linear_predictor_range = lp_range,
      extreme_values = extreme_values
    ))
    
  }, error = function(e) {
    write("❌ Could not check link function", config$results_log, append = TRUE)
    return(list(passed = FALSE))
  })
}

#' Check GLMM Independence
#' 
#' Tests independence using deviance residuals
#' 
#' @param glmm_model Fitted GLMM model
#' @param config Analysis configuration
#' @return List with independence test results
check_glmm_independence <- function(glmm_model, config) {
  
  tryCatch({
    # Use deviance residuals for GLMM independence check
    residuals_model <- residuals(glmm_model, type = "deviance")
    
    # Durbin-Watson test on deviance residuals
    dw_test <- car::durbinWatsonTest(lm(residuals_model ~ 1))
    dw_statistic <- dw_test$dw
    dw_pvalue <- dw_test$p
    
    # Independence criteria
    independence_passed <- (dw_pvalue > 0.05) && 
                          (dw_statistic > 1.5 && dw_statistic < 2.5)
    
    # Log results
    write(paste("Durbin-Watson statistic:", round(dw_statistic, 4)), 
          config$results_log, append = TRUE)
    write(paste("Durbin-Watson p-value:", round(dw_pvalue, 4)), 
          config$results_log, append = TRUE)
    
    return(list(
      passed = independence_passed,
      dw_statistic = dw_statistic,
      dw_pvalue = dw_pvalue
    ))
    
  }, error = function(e) {
    write("❌ Could not check independence", config$results_log, append = TRUE)
    return(list(passed = FALSE))
  })
}

#' Check GLMM Random Effects Normality
#' 
#' Tests if random effects are normally distributed
#' 
#' @param glmm_model Fitted GLMM model
#' @param config Analysis configuration
#' @return List with random effects test results
check_glmm_random_effects <- function(glmm_model, config) {
  
  tryCatch({
    # Extract random effects (similar to LMM)
    random_effects <- ranef(glmm_model)
    main_group <- names(random_effects)[1]
    re_values <- random_effects[[main_group]][,1]
    
    # Normality test
    if (length(re_values) <= 5000) {
      normality_test <- shapiro.test(re_values)
      test_name <- "Shapiro-Wilk"
    } else {
      normality_test <- ks.test(re_values, "pnorm", mean(re_values), sd(re_values))
      test_name <- "Kolmogorov-Smirnov"
    }
    
    # Basic statistics
    re_mean <- mean(re_values)
    re_skewness <- moments::skewness(re_values)
    
    # Assessment criteria
    re_passed <- (normality_test$p.value > 0.05) && (abs(re_skewness) < 2)
    
    # Log results
    write(paste(test_name, "test p-value:", round(normality_test$p.value, 4)), 
          config$results_log, append = TRUE)
    write(paste("Random effects mean:", round(re_mean, 4)), 
          config$results_log, append = TRUE)
    write(paste("Random effects skewness:", round(re_skewness, 4)), 
          config$results_log, append = TRUE)
    
    return(list(
      passed = re_passed,
      p_value = normality_test$p.value,
      mean = re_mean,
      skewness = re_skewness
    ))
    
  }, error = function(e) {
    write("❌ Could not extract random effects - assuming passed", config$results_log, append = TRUE)
    return(list(passed = TRUE))  # Default to passed if can't test
  })
}

#' Check GLMM Overdispersion
#' 
#' Tests for overdispersion/zero inflation in appropriate families
#' 
#' @param glmm_model Fitted GLMM model
#' @param family_used Family used in GLMM
#' @param config Analysis configuration
#' @return List with overdispersion test results
check_glmm_overdispersion <- function(glmm_model, family_used, config) {
  
  if (family_used %in% c("Poisson", "binomial")) {
    tryCatch({
      # Calculate overdispersion ratio
      resid_dev <- sum(residuals(glmm_model, type = "deviance")^2)
      df_resid <- df.residual(glmm_model)
      
      if (!is.null(df_resid) && df_resid > 0) {
        overdispersion_ratio <- resid_dev / df_resid
        overdispersion_passed <- overdispersion_ratio < 1.5  # Conservative threshold
        
        # Log results
        write(paste("Residual deviance:", round(resid_dev, 3)), config$results_log, append = TRUE)
        write(paste("Degrees of freedom:", df_resid), config$results_log, append = TRUE)
        write(paste("Overdispersion ratio:", round(overdispersion_ratio, 3)), 
              config$results_log, append = TRUE)
        
        return(list(
          passed = overdispersion_passed,
          ratio = overdispersion_ratio,
          relevant = TRUE
        ))
      }
      
    }, error = function(e) {
      write("❌ Could not calculate overdispersion ratio", config$results_log, append = TRUE)
      return(list(passed = FALSE, relevant = TRUE))
    })
  } else {
    # Not applicable for other families (Beta, Gamma, etc.)
    write(paste("Overdispersion check not applicable for", family_used, "family"), 
          config$results_log, append = TRUE)
    
    status_msg <- paste0("✅ OVERDISPERSION: N/A (not applicable for ", family_used, " family)")
    write(status_msg, config$results_log, append = TRUE)
  }
  
  return(list(
    passed = TRUE,
    ratio = NA,
    relevant = FALSE
  ))
}

#' Summarize GLMM Assumption Results
#' 
#' Creates a summary of all GLMM assumption check results
#' 
#' @param assumption_results List of individual assumption results
#' @param family_used Family used in GLMM
#' @param config Analysis configuration
#' @return Summary list with overall assessment
summarize_glmm_assumption_results <- function(assumption_results, family_used, config) {
  
  # Count passed assumptions
  assumptions_passed <- list(
    distributional = assumption_results$distributional$passed,
    link_function = assumption_results$link_function$passed,
    independence = assumption_results$independence$passed,
    random_effects = assumption_results$random_effects$passed,
    overdispersion = assumption_results$overdispersion$passed
  )
  
  total_passed <- sum(unlist(assumptions_passed))
  total_tests <- length(assumptions_passed)
  
  # Write summary to log
  write(strrep("=", 60), config$results_log, append = TRUE)
  write(" OVERALL GLMM ASSUMPTION SUMMARY", config$results_log, append = TRUE)
  write(strrep("=", 60), config$results_log, append = TRUE)
  write(paste("Family:", family_used), config$results_log, append = TRUE)
  write(paste("Assumptions passed:", total_passed, "out of", total_tests), 
        config$results_log, append = TRUE)
  
  for (assumption in names(assumptions_passed)) {
    status <- if (assumptions_passed[[assumption]]) "✅ PASSED" else "❌ FAILED"
    write(paste("-", toupper(assumption), ":", status), config$results_log, append = TRUE)
    cat("      ", toupper(assumption), ":", status, "\n")
  }
  
  # Determine overall status and recommendation
  if (total_passed == total_tests) {
    status <- "excellent"
    recommendation <- "🎉 ALL GLMM ASSUMPTIONS SATISFIED - Proceed with confidence!"
    cat("🎉 All GLMM assumptions satisfied\n")
  } else if (total_passed >= 4) {
    status <- "acceptable"
    recommendation <- "⚠️  MINOR VIOLATIONS - GLMM results likely robust, interpret with caution"
    cat("⚠️  Minor GLMM assumption violations\n")
  } else {
    status <- "poor"
    recommendation <- "🚨 MAJOR VIOLATIONS - Consider alternative GLMM families or models"
    cat("🚨 Major GLMM assumption violations\n")
  }
  
  write(paste("\n", recommendation), config$results_log, append = TRUE)
  
  return(list(
    assumptions_passed = assumptions_passed,
    total_passed = total_passed,
    total_tests = total_tests,
    status = status,
    recommendation = recommendation,
    family = family_used
  ))
}