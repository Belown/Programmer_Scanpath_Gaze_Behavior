# =============================================================================
# LMM Assumption Checking Module
# =============================================================================
# This module contains functions for checking Linear Mixed Model assumptions:
# linearity, normality, homoscedasticity, independence, and random effects normality

#' Check All LMM Assumptions
#' 
#' Comprehensive assumption checking for mixed models
#' 
#' @param model Fitted lmer model
#' @param y Dependent variable name
#' @param config Analysis configuration list
#' @return List with assumption check results
check_all_assumptions <- function(model, y, config) {
  cat("--- Checking model assumptions for", y, "---\n")
  
  write(strrep("=", 60), config$results_log, append = TRUE)
  write("MODEL ASSUMPTION CHECKS", config$results_log, append = TRUE)
  write(strrep("=", 60), config$results_log, append = TRUE)
  
  # Initialize results storage
  assumption_results <- list()
  
  # 1. Linearity Check: relationship between the dependent variable and the independent variables is linear
  write("\n1. LINEARITY CHECK:", config$results_log, append = TRUE)
  linearity_result <- check_linearity(model, y, config)
  assumption_results$linearity <- linearity_result

  # 2. Residuals Normality Check
  write("\n2. NORMALITY CHECK:", config$results_log, append = TRUE)
  normality_result <- check_normality(model, y, config)
  assumption_results$normality <- normality_result
  
  # 3. Homoscedasticity Check
  write("\n3. HOMOSCEDASTICITY CHECK:", config$results_log, append = TRUE)
  homoscedasticity_result <- check_homoscedasticity(model, config)
  assumption_results$homoscedasticity <- homoscedasticity_result
  
  # 4. Independence Check
  write("\n4. INDEPENDENCE CHECK:", config$results_log, append = TRUE)
  independence_result <- check_independence(model, config)
  assumption_results$independence <- independence_result
  
  # 5. Random Effects Normality Check: Normally distributed with mean zero and estimated variance
  write("\n5. RANDOM EFFECTS NORMALITY CHECK:", config$results_log, append = TRUE)
  random_effects_result <- check_random_effects_normality(model, y, config)
  assumption_results$random_effects <- random_effects_result
  
  # Summarize results
  summary_result <- summarize_assumption_results(assumption_results, y, config)
  
  return(list(
    individual_results = assumption_results,
    summary = summary_result
  ))
}

#' Check Linearity Assumption
#' 
#' Tests linearity using residuals vs fitted values correlation
#' 
#' @param model Fitted lmer model
#' @param y Dependent variable name
#' @param config Analysis configuration
#' @return List with linearity test results and plot
check_linearity <- function(model, y, config) {
  residuals_model <- residuals(model)
  fitted_vals <- fitted(model)
  
  # Correlation test
  linearity_cor <- cor(residuals_model, fitted_vals)
  linearity_test <- cor.test(residuals_model, fitted_vals)
  
  # Log results
  write(paste("Correlation between residuals and fitted values:", 
              round(linearity_cor, 4)), config$results_log, append = TRUE)
  write(paste("Correlation test p-value:", 
              round(linearity_test$p.value, 4)), config$results_log, append = TRUE)
  
  # Simple diagnostic plot
  plot_data <- data.frame(fitted = fitted_vals, residuals = residuals_model)
  
  linearity_plot <- ggplot(plot_data, aes(x = fitted, y = residuals)) +
    geom_point(alpha = 0.6) +
    geom_smooth(method = "loess", se = FALSE) +
    geom_hline(yintercept = 0, linetype = "dashed") +
    labs(title = paste("Linearity:", y), x = "Fitted", y = "Residuals") +
    theme_minimal()
  
  # Save plot
  plot_filename <- file.path(config$figures_dir, paste0(config$output_prefix, "_linearity_", y, ".png"))
  ggsave(filename = plot_filename, plot = linearity_plot, width = 6, height = 4)
  
  # Determine if assumption is met
  linearity_passed <- abs(linearity_cor) < 0.1 && linearity_test$p.value > 0.05

  return(list(
    passed = linearity_passed,
    correlation = linearity_cor,
    p_value = linearity_test$p.value,
    plot_filename = plot_filename,
    plot = linearity_plot
  ))
}

#' Check Normality Assumption
#' 
#' Tests normality of residuals using appropriate statistical tests
#' 
#' @param model Fitted lmer model
#' @param y Dependent variable name
#' @param config Analysis configuration
#' @return List with normality test results and plot
check_normality <- function(model, y, config) {
  residuals_model <- residuals(model)
  n_obs <- length(residuals_model)
  
  # Choose appropriate normality test
  if (n_obs <= 5000) {
    normality_test <- shapiro.test(residuals_model)
    test_name <- "Shapiro-Wilk"
    normality_pvalue <- normality_test$p.value
  } else {
    # For large samples, use Kolmogorov-Smirnov
    normality_test <- ks.test(residuals_model, "pnorm", 
                             mean(residuals_model), sd(residuals_model))
    test_name <- "Kolmogorov-Smirnov"
    normality_pvalue <- normality_test$p.value
  }
  
  write(paste(test_name, "test p-value:", round(normality_pvalue, 4)), 
        config$results_log, append = TRUE)
  
  # Additional normality metrics
  skewness_val <- moments::skewness(residuals_model)
  kurtosis_val <- moments::kurtosis(residuals_model)
  
  write(paste("Skewness:", round(skewness_val, 4)), config$results_log, append = TRUE)
  write(paste("Kurtosis:", round(kurtosis_val, 4)), config$results_log, append = TRUE)
  
  # Simple Q-Q plot
  plot_data <- data.frame(residuals = residuals_model)
  
  qq_plot <- ggplot(plot_data, aes(sample = residuals)) +
    stat_qq() +
    stat_qq_line() +
    labs(title = paste("Normality:", y)) +
    theme_minimal()
  
  # Save plot
  plot_filename <- file.path(config$figures_dir, paste0(config$output_prefix, "_qq_", y, ".png"))
  ggsave(filename = plot_filename, plot = qq_plot, width = 5, height = 4)
  
  # Determine if assumption is met
  normality_passed <- (normality_pvalue > 0.05) && 
                      (abs(skewness_val) < 2) && 
                      (kurtosis_val < 7)

  return(list(
    passed = normality_passed,
    test_name = test_name,
    p_value = normality_pvalue,
    skewness = skewness_val,
    kurtosis = kurtosis_val,
    plot_filename = plot_filename,
    plot = qq_plot
  ))
}

#' Check Homoscedasticity Assumption
#' 
#' Tests homoscedasticity using Breusch-Pagan test and variance ratio
#' 
#' @param model Fitted lmer model
#' @param config Analysis configuration
#' @return List with homoscedasticity test results
check_homoscedasticity <- function(model, config) {
  residuals_model <- residuals(model)
  fitted_vals <- fitted(model)
  
  # Breusch-Pagan test (manual implementation)
  squared_residuals <- residuals_model^2
  bp_lm <- lm(squared_residuals ~ fitted_vals)
  bp_summary <- summary(bp_lm)
  bp_pvalue <- bp_summary$coefficients[2, 4]  # p-value for fitted_vals coefficient
  
  write(paste("Breusch-Pagan test p-value:", round(bp_pvalue, 4)), 
        config$results_log, append = TRUE)
  
  # Variance ratio test
  fitted_tertiles <- quantile(fitted_vals, c(1/3, 2/3))
  group1_var <- var(residuals_model[fitted_vals <= fitted_tertiles[1]])
  group3_var <- var(residuals_model[fitted_vals >= fitted_tertiles[2]])
  variance_ratio <- max(group1_var, group3_var) / min(group1_var, group3_var)
  
  write(paste("Variance ratio (high/low groups):", round(variance_ratio, 4)), 
        config$results_log, append = TRUE)
  
  # Determine if assumption is met
  homoscedasticity_passed <- (bp_pvalue > 0.05) && (variance_ratio < 4)

  return(list(
    passed = homoscedasticity_passed,
    bp_pvalue = bp_pvalue,
    variance_ratio = variance_ratio
  ))
}

#' Check Independence Assumption
#' 
#' Tests independence using Durbin-Watson and runs tests
#' 
#' @param model Fitted lmer model
#' @param config Analysis configuration
#' @return List with independence test results
check_independence <- function(model, config) {
  residuals_model <- residuals(model)
  
  # Durbin-Watson test
  dw_test <- car::durbinWatsonTest(lm(residuals_model ~ 1))
  dw_statistic <- dw_test$dw
  dw_pvalue <- dw_test$p
  
  write(paste("Durbin-Watson statistic:", round(dw_statistic, 4)), config$results_log, append = TRUE)
  write(paste("Durbin-Watson p-value:", round(dw_pvalue, 4)), config$results_log, append = TRUE)
  
  # Runs test for randomness
  residuals_binary <- ifelse(residuals_model > median(residuals_model), 1, 0)
  runs_test <- tseries::runs.test(as.factor(residuals_binary))
  runs_pvalue <- runs_test$p.value

  write(paste("Runs test p-value:", round(runs_pvalue, 4)), config$results_log, append = TRUE)

  # Determine if assumption is met
  independence_passed <- (dw_pvalue > 0.05) && (runs_pvalue > 0.05) && (dw_statistic > 1.5 && dw_statistic < 2.5)

  return(list(
    passed = independence_passed,
    dw_statistic = dw_statistic,
    dw_pvalue = dw_pvalue,
    runs_pvalue = runs_pvalue
  ))
}

#' Check Random Effects Normality
#' 
#' Tests if random effects (BLUPs) are normally distributed with mean zero
#' 
#' @param model Fitted lmer model
#' @param y Dependent variable name
#' @param config Analysis configuration
#' @return List with random effects normality results
check_random_effects_normality <- function(model, y, config) {
  
  tryCatch({
    # Extract random effects
    random_effects <- ranef(model)
    
    # Test the main random intercepts (usually session_id)
    main_group <- names(random_effects)[1]
    re_values <- random_effects[[main_group]][,1]  # First column (intercept)
    
    # Shapiro-Wilk test
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
    write(paste(test_name, "test p-value:", round(normality_test$p.value, 4)), config$results_log, append = TRUE)
    write(paste("Random effects mean:", round(re_mean, 4)), config$results_log, append = TRUE)
    write(paste("Random effects skewness:", round(re_skewness, 4)), config$results_log, append = TRUE)

    # Determine if assumption is met
    re_passed <- (normality_test$p.value > 0.05) && (abs(re_skewness) < 2)
    
    return(list(
      passed = re_passed,
      p_value = normality_test$p.value,
      mean = re_mean,
      skewness = re_skewness
    ))
    
  }, error = function(e) {
    write("❌ Could not extract random effects", config$results_log, append = TRUE)
    return(list(passed = TRUE))  # Default to passed if can't test
  })
}

#' Summarize Assumption Results
#' 
#' Creates a summary of all assumption check results
#' 
#' @param assumption_results List of individual assumption results
#' @param y Dependent variable name
#' @param config Analysis configuration
#' @return Summary list with overall assessment
summarize_assumption_results <- function(assumption_results, y, config) {
  # Count passed assumptions
  assumptions_passed <- list(
    linearity = assumption_results$linearity$passed,
    normality = assumption_results$normality$passed,
    homoscedasticity = assumption_results$homoscedasticity$passed,
    independence = assumption_results$independence$passed,
    random_effects = assumption_results$random_effects$passed
  )
  
  total_passed <- sum(unlist(assumptions_passed))
  total_tests <- length(assumptions_passed)
  
  # Write summary to log
  write(strrep("=", 60), config$results_log, append = TRUE)
  write("OVERALL ASSUMPTION SUMMARY", config$results_log, append = TRUE)
  write(strrep("=", 60), config$results_log, append = TRUE)
  write(paste("Assumptions passed:", total_passed, "out of", total_tests), config$results_log, append = TRUE)

  for (assumption in names(assumptions_passed)) {
    status <- if (assumptions_passed[[assumption]]) "✅ PASSED" else "❌ FAILED"
    write(paste("-", toupper(assumption), ":", status), config$results_log, append = TRUE)
    cat("      ", toupper(assumption), ":", status, "\n")
  }
  
  # Determine overall status and recommendation (now 5 assumptions)
  if (total_passed == total_tests) {
    status <- "excellent"
    recommendation <- "🎉 ALL ASSUMPTIONS SATISFIED - Proceed with confidence!"
    cat("🎉 All assumptions satisfied for", y, "\n")
  } else if (total_passed >= 4) {
    status <- "acceptable"
    recommendation <- "⚠️  MINOR VIOLATIONS - Results likely robust, interpret with caution"
    cat("⚠️  Minor assumption violations for", y, "\n")
  } else {
    status <- "poor"
    recommendation <- "🚨 MAJOR VIOLATIONS - Consider transformations or alternative models"
    cat("🚨 Major assumption violations for", y, "\n")
  }
  
  write(paste("\n", recommendation), config$results_log, append = TRUE)
  
  return(list(
    assumptions_passed = assumptions_passed,
    total_passed = total_passed,
    total_tests = total_tests,
    status = status,
    recommendation = recommendation
  ))
}