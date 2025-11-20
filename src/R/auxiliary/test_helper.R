library(here)
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))

#' Get all experiment model packages for a given random effect structure
#' 
#' @param random_effect The random effect structure ("a", "b", or "both")
#' @return A named list of model packages for all experiments
get_all_exps <- function(random_effect) {
  within_trial_within_2 <- get_model_pack("within_trial", "EMIP_corrected", "within_group", "trial_2", "mean_diff", random_effect)
  within_trial_within_5 <- get_model_pack("within_trial", "EMIP_corrected", "within_group", "trial_5", "mean_diff", random_effect)
  within_trial_between_2 <- get_model_pack("within_trial", "EMIP_corrected", "between_group", "trial_2", "mean_diff", random_effect)
  within_trial_between_5 <- get_model_pack("within_trial", "EMIP_corrected", "between_group", "trial_5", "mean_diff", random_effect)
  within_group <- get_model_pack("within_group", "EMIP_corrected", "", "", "", random_effect)
  between_group <- get_model_pack("between_group", "EMIP_corrected", "", "", "mean_diff", random_effect)
  
  result_list <- list(
    within_trial_within_2 = within_trial_within_2,
    within_trial_within_5 = within_trial_within_5,
    within_trial_between_2 = within_trial_between_2,
    within_trial_between_5 = within_trial_between_5,
    within_group = within_group,
    between_group = between_group
  )
  return(result_list)
}

#' Test random effects by printing AIC and BIC for all experiments
test_random_effects <- function() {
  rand_a <- get_all_exps("a")
  rand_b <- get_all_exps("b")
  rand_both <- get_all_exps("both")
  
  all_random_effect_list = list(rand_a = rand_a, rand_b = rand_b, rand_both = rand_both)
  
  for (random_effect_list in names(all_random_effect_list)) {
    cat("============== Results for", random_effect_list, "==============\n")
    all_exps <- all_random_effect_list[[random_effect_list]]
    for (exp_pack in names(all_exps)) {
      cat("------------ Experiment:", exp_pack, "------------\n")
      model_pack <- all_exps[[exp_pack]]
      model_list_aic_bic(model_pack$m_list)
    }
  }
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