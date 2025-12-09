library(here)
library(lme4)
library(glmmTMB)
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))

#' Get all experiment model packages for a given random effect structure
#' 
#' @param random_effect The random effect structure ("exp_a", "exp_b", or "both")
#' @param info Whether to print info messages
#' @return A named list of model packages for all experiments
get_all_exps <- function(random_effect, info) {
  within_trial_within_2 <- get_exp_pack("EMIP_corrected", "within_trial", "within_group", "trial_2", "", random_effect, info, reml=TRUE, dataset="EMIP_corrected")
  within_trial_within_5 <- get_exp_pack("EMIP_corrected", "within_trial", "within_group", "trial_5", "", random_effect, info, reml=TRUE, dataset="EMIP_corrected")
  within_trial_between_2 <- get_exp_pack("EMIP_corrected", "within_trial", "between_group", "trial_2", "", random_effect, info, reml=TRUE, dataset="EMIP_corrected")
  within_trial_between_5 <- get_exp_pack("EMIP_corrected", "within_trial", "between_group", "trial_5", "", random_effect, info, reml=TRUE, dataset="EMIP_corrected")
  within_group <- get_exp_pack("EMIP_corrected", "within_group", "", "", "", random_effect, info, reml=TRUE, dataset="EMIP_corrected")
  between_group_mean_diff <- get_exp_pack("EMIP_corrected", "between_group", "", "", "mean_diff", random_effect, info, reml=TRUE, dataset="EMIP_corrected")
  between_group_pairtype <- get_exp_pack("EMIP_corrected", "between_group", "", "", "pairtype", random_effect, info, reml=TRUE, dataset="EMIP_corrected")
  
  result_list <- list(
    within_trial_within_2 = within_trial_within_2,
    within_trial_within_5 = within_trial_within_5,
    within_trial_between_2 = within_trial_between_2,
    within_trial_between_5 = within_trial_between_5,
    within_group = within_group,
    between_group_mean_diff = between_group_mean_diff,
    between_group_pairtype = between_group_pairtype
  )
  
  return(result_list)
}

compare_random_effects <- function(rand_effect_list, print = FALSE) {
  cat("Loading models for random effect analysis\n")
  all_model_all_res <- list()
  for (re in names(rand_effect_list)) {
    all_model_all_res[[re]] <- get_all_exps(rand_effect_list[[re]], FALSE)
    cat("✅️ Models for random effect:", re, "\n")
  }
  
  # Do likelihood ratio tests for all experiments and random effects
  rlt_re(all_model_all_res, print)
  
  # Compute AIC and BIC for all experiments and random effects
  experiment_aicbic(all_model_all_res, print)
}

# This function is hard coded for the current experiments
# Thus it needs to be updated if new experiments are added
rlt_re <- function(all_model_all_res, print, alpha = 0.05) {
  folder_path <- assign_path(file.path(here(), "output", "R", "random_effect_analysis", "EMIP_corrected"))
  output_path <- file.path(folder_path, "lrt_result.csv")

  # Create an empty data frame to store LRT results
  lrt_df <- data.frame(
    experiment = character(),
    dimension = character(),
    comparison = character(),
    chisq = numeric(),
    df = numeric(),
    p_value = numeric(),
    significant = character(),
    stringsAsFactors = FALSE
  )

  # Loop though the experiments
  exps <- list("within_trial_within_2",
               "within_trial_within_5",
               "within_trial_between_2",
               "within_trial_between_5",
               "within_group",
               "between_group_mean_diff",
               "between_group_pairtype")
  
  for (exp in exps) {
    if (print) cat("\n============== Experiment:", exp, "==============\n")
    
    exp_a_model_pack <- all_model_all_res[["exp_a"]][[exp]]
    exp_b_model_pack <- all_model_all_res[["exp_b"]][[exp]]
    both_model_pack <- all_model_all_res[["both"]][[exp]]
    
    # Loop through each dimension
    for (dim in names(exp_a_model_pack$m_list)) {
      if (print) cat("\n------------ Dimension:", dim, "------------\n")
      
      # Get models for this dimension
      m_exp_a <- exp_a_model_pack$m_list[[dim]]
      m_exp_b <- exp_b_model_pack$m_list[[dim]]
      m_both <- both_model_pack$m_list[[dim]]
      
      # Perform LRT comparisons
      
      # 1. exp_a vs both
      tryCatch({
        lrt_result <- anova(m_exp_a, m_both)
        lrt_df_temp <- as.data.frame(lrt_result)
        chisq_val <- lrt_df_temp[2, "Chisq"]
        df_val <- lrt_df_temp[2, "Df"]
        p_val <- lrt_df_temp[2, "Pr(>Chisq)"]
        sig <- ifelse(p_val < alpha, "Yes", "No")
        
        if (print) {
          cat("exp_a vs both: Chi-sq =", chisq_val, ", df =", df_val,
              ", p =", p_val, ", significant =", sig, "\n")
        }
        
        lrt_df <- rbind(lrt_df, data.frame(
          experiment = exp,
          dimension = dim,
          comparison = "exp_a_vs_both",
          chisq = chisq_val,
          df = df_val,
          p_value = p_val,
          significant = sig,
          stringsAsFactors = FALSE
        ))
      }, error = function(e) {
        if (print) cat("Error in exp_a vs both:", e$message, "\n")
      })
      
      # 2. exp_b vs both
      tryCatch({
        lrt_result <- anova(m_exp_b, m_both)
        lrt_df_temp <- as.data.frame(lrt_result)
        chisq_val <- lrt_df_temp[2, "Chisq"]
        df_val <- lrt_df_temp[2, "Df"]
        p_val <- lrt_df_temp[2, "Pr(>Chisq)"]
        sig <- ifelse(p_val < alpha, "Yes", "No")
        
        if (print) {
          cat("exp_b vs both: Chi-sq =", chisq_val, ", df =", df_val,
              ", p =", p_val, ", significant =", sig, "\n")
        }
        
        lrt_df <- rbind(lrt_df, data.frame(
          experiment = exp,
          dimension = dim,
          comparison = "exp_b_vs_both",
          chisq = chisq_val,
          df = df_val,
          p_value = p_val,
          significant = sig,
          stringsAsFactors = FALSE
        ))
      }, error = function(e) {
        if (print) cat("Error in exp_b vs both:", e$message, "\n")
      })
    }
  }
  
  # Write results to CSV file
  write.csv(lrt_df, file = output_path, row.names = FALSE)
  cat("\nLRT results have been saved to:", output_path, "\n")
  
  return(lrt_df)
}


#' Test random effects by storing AIC and BIC for all experiments in a CSV file
#' and store the result into a .csv file
#' 
#' @param all_model_all_res A nested list of model packages for all random effects and experiments
#' @param print Whether to print AIC and BIC values to console
experiment_aicbic <- function(all_model_all_res, print) {
  folder_path <- assign_path(file.path(here(), "output", "R", "random_effect_analysis", "EMIP_corrected"))
  output_path <- file.path(folder_path, "aic_bic_result.csv")


  # Create an empty data frame to store results
  aicbic_df <- data.frame(
    random_effect = character(),
    experiment = character(),
    dimension = character(),
    AIC = numeric(),
    BIC = numeric(),
    stringsAsFactors = FALSE
  )

  # Loop though the random effects
  for (re in names(all_model_all_res)) {
    if (print) cat("============== Results for", re, "==============\n")
    all_experiments <- all_model_all_res[[re]]

    # Loop through each experiment
    for (experiment in names(all_experiments)) {
      if (print) cat("------------ Experiment:", experiment, "------------\n")
      exp_pack <- all_experiments[[experiment]]
      
      # Loop through each dimension and calculate AIC and BIC
      for (dim in names(exp_pack$m_list)) {
        m <- exp_pack$m_list[[dim]]
        aic_value <- AIC(m)
        bic_value <- BIC(m)
        
        if (print) cat("AIC for ", dim, " is:", aic_value, "\n")
        if (print) cat("BIC for ", dim, " is:", bic_value, "\n")
        
        # Add to data frame
        aicbic_df <- rbind(aicbic_df, data.frame(
          random_effect = re,
          experiment = experiment,
          dimension = dim,
          AIC = aic_value,
          BIC = bic_value,
          stringsAsFactors = FALSE
        ))
      }
    }
  }
  
  # Write results to CSV file
  write.csv(aicbic_df, file = output_path, row.names = FALSE)
  cat("\n AIC BIC results have been saved to:", output_path, "\n")
}


#' Print AIC and BIC values for a list of models
#' 
#' @param m_list A named list of fitted models
model_list_aic_bic <- function(m_list) {
  for (dim in names(m_list)) {
    m <- m_list[[dim]]
    cat("AIC for ", dim, " is:", AIC(m), "\n")
    cat("BIC for ", dim, " is:", BIC(m), "\n")
  }
}