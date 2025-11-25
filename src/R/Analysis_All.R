library(here)

source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))

within_trial_within_2 <- get_exp_pack("within_trial", "EMIP_corrected", "within_group", "trial_2", "", , info=FALSE, reml = TRUE)
within_trial_within_5 <- get_exp_pack("within_trial", "EMIP_corrected", "within_group", "trial_5", "", , info=FALSE, reml = TRUE)
within_trial_between_2 <- get_exp_pack("within_trial", "EMIP_corrected", "between_group", "trial_2", "", , info=FALSE, reml = TRUE)
within_trial_between_5 <- get_exp_pack("within_trial", "EMIP_corrected", "between_group", "trial_5", "", , info=FALSE, reml = TRUE)
within_group <- get_exp_pack("within_group", "EMIP_corrected", "", "", "", , info=FALSE, reml = TRUE)
between_group_mean_diff <- get_exp_pack("between_group", "EMIP_corrected", "", "", "mean_diff", , info=FALSE, reml = TRUE)
between_group_pairtype <- get_exp_pack("between_group", "EMIP_corrected", "", "", "pairtype", , info=FALSE, reml = TRUE)

model_list <- list(
  within_trial_within_2 = within_trial_within_2,
  within_trial_within_5 = within_trial_within_5,
  within_trial_between_2 = within_trial_between_2,
  within_trial_between_5 = within_trial_between_5,
  within_group = within_group,
  between_group_mean_diff = between_group_mean_diff,
  between_group_pairtype = between_group_pairtype
)

for (model in names(model_list)) {
  curr_model <- model_list[[model]]
  cat("Processing model for experiment:", model, "\n")
  work_flow_with_print(curr_model$m_list, curr_model$config)
  cat("✅️ Completed processing for experiment:", model, "\n")
}