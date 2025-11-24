library(here)
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))

#' Get all experiment model packages for a given random effect structure
#' 
#' @param random_effect The random effect structure ("exp_a", "exp_b", or "both")
#' @param info Whether to print info messages
#' @return A named list of model packages for all experiments
get_all_exps <- function(random_effect, info) {
  within_trial_within_2 <- get_exp_pack("within_trial", "EMIP_corrected", "within_group", "trial_2", "", random_effect, info, reml = TRUE)
  within_trial_within_5 <- get_exp_pack("within_trial", "EMIP_corrected", "within_group", "trial_5", "", random_effect, info, reml = TRUE)
  within_trial_between_2 <- get_exp_pack("within_trial", "EMIP_corrected", "between_group", "trial_2", "", random_effect, info, reml = TRUE)
  within_trial_between_5 <- get_exp_pack("within_trial", "EMIP_corrected", "between_group", "trial_5", "", random_effect, info, reml = TRUE)
  within_group <- get_exp_pack("within_group", "EMIP_corrected", "", "", "", random_effect, info, reml = TRUE)
  between_group_mean_diff <- get_exp_pack("between_group", "EMIP_corrected", "", "", "mean_diff", random_effect, info, reml = TRUE)
  between_group_pairtype <- get_exp_pack("between_group", "EMIP_corrected", "", "", "pairtype", random_effect, info, reml = TRUE)
  
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

compare_random_effects <- function(rand_effect_list) {
  cat("Loading models for random effect analysis\n")
  all_model_all_res <- list()
  for (re in names(rand_effect_list)) {
    all_model_all_res[[re]] <- get_all_exps(rand_effect_list[[re]], FALSE)
    cat("✅️ Models for random effect:", re, "\n")
  }
  
  # Compute AIC and BIC for all experiments and random effects
  experiment_aicbic(all_model_all_res)
  
  
  
}

#' Test random effects by storing AIC and BIC for all experiments in a CSV file
#' and store the result into a .csv file
#' 
#' @param rand_effect_list A named list of random effect structures to test
experiment_aicbic <- function(all_model_all_res) {
  output_path <- file.path(here(), "output", "R", "random_effect_analysis", "aic_bic_result.csv")
  if(!dir.exists(dirname(output_path))) {
    dir.create(dirname(output_path), recursive = TRUE)
  }

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
    cat("============== Results for", re, "==============\n")
    all_experiments <- all_model_all_res[[re]]

    # Loop through each experiment
    for (experiment in names(all_experiments)) {
      cat("------------ Experiment:", experiment, "------------\n")
      exp_pack <- all_experiments[[experiment]]
      
      # Loop through each dimension and calculate AIC and BIC
      for (dim in names(exp_pack$m_list)) {
        m <- exp_pack$m_list[[dim]]
        aic_value <- AIC(m)
        bic_value <- BIC(m)
        
        cat("AIC for ", dim, " is:", aic_value, "\n")
        cat("BIC for ", dim, " is:", bic_value, "\n")
        
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
  cat("\nResults have been saved to:", output_path, "\n")
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