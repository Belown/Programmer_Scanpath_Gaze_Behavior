library(here)
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))

#' Get all experiment model packages for a given random effect structure
#' 
#' @param random_effect The random effect structure ("exp_a", "exp_b", or "both")
#' @return A named list of model packages for all experiments
get_all_exps <- function(random_effect, info) {
  within_trial_within_2 <- get_model_pack("within_trial", "EMIP_corrected", "within_group", "trial_2", "", random_effect, info)
  within_trial_within_5 <- get_model_pack("within_trial", "EMIP_corrected", "within_group", "trial_5", "", random_effect, info)
  within_trial_between_2 <- get_model_pack("within_trial", "EMIP_corrected", "between_group", "trial_2", "", random_effect, info)
  within_trial_between_5 <- get_model_pack("within_trial", "EMIP_corrected", "between_group", "trial_5", "", random_effect, info)
  within_group <- get_model_pack("within_group", "EMIP_corrected", "", "", "", random_effect, info)
  between_group_mean_diff <- get_model_pack("between_group", "EMIP_corrected", "", "", "mean_diff", random_effect, info)
  between_group_pairtype <- get_model_pack("between_group", "EMIP_corrected", "", "", "pairtype", random_effect, info)
  
  between_group_name <- paste0("between_group_", case)
  
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

#' Test random effects by storing AIC and BIC for all experiments in a CSV file
test_random_effects <- function(rand_effect_list) {
  output_path <- file.path(here(), "output", "R", "random_effect_analysis", "random_effect_result.csv")
  if(!dir.exists(dirname(output_path))) {
    dir.create(dirname(output_path), recursive = TRUE)
  }
  
  cat("Loading models for random effect analysis\n")
  all_random_effect_list <- list()
  for (re in names(rand_effect_list)) {
    cat("    Loading models for random effect:", re, "\n")
    all_random_effect_list[[re]] <- get_all_exps(rand_effect_list[[re]], FALSE)
    cat("    Finish loading models for random effect:", re, "\n")
  }
  
  # Create an empty data frame to store results
  results_df <- data.frame(
    random_effect = character(),
    experiment = character(),
    dimension = character(),
    AIC = numeric(),
    BIC = numeric(),
    stringsAsFactors = FALSE
  )
  
  for (random_effect_list in names(all_random_effect_list)) {
    cat("============== Results for", random_effect_list, "==============\n")
    all_exps <- all_random_effect_list[[random_effect_list]]
    for (exp_pack in names(all_exps)) {
      cat("------------ Experiment:", exp_pack, "------------\n")
      model_pack <- all_exps[[exp_pack]]
      
      # Extract AIC and BIC values for each model and add to data frame
      for (dim in names(model_pack$m_list)) {
        m <- model_pack$m_list[[dim]]
        aic_value <- AIC(m)
        bic_value <- BIC(m)
        
        # Print to console
        cat("AIC for ", dim, " is:", aic_value, "\n")
        cat("BIC for ", dim, " is:", bic_value, "\n")
        
        # Add to data frame
        results_df <- rbind(results_df, data.frame(
          random_effect = random_effect_list,
          experiment = exp_pack,
          dimension = dim,
          AIC = aic_value,
          BIC = bic_value,
          stringsAsFactors = FALSE
        ))
      }
    }
  }
  
  # Write results to CSV file
  write.csv(results_df, file = output_path, row.names = FALSE)
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