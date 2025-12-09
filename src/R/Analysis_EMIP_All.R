library(here)

source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))

within_trial_within_2 <- get_exp_pack("EMIP_corrected", "within_trial", "within_group", "trial_2", NULL, NULL, info=FALSE, reml=TRUE, dataset="EMIP_corrected")
within_trial_within_5 <- get_exp_pack("EMIP_corrected", "within_trial", "within_group", "trial_5", NULL, NULL, info=FALSE, reml=TRUE, dataset="EMIP_corrected")
within_trial_between_2 <- get_exp_pack("EMIP_corrected", "within_trial", "between_group", "trial_2", NULL, NULL, info=FALSE, reml=TRUE, dataset="EMIP_corrected")
within_trial_between_5 <- get_exp_pack("EMIP_corrected", "within_trial", "between_group", "trial_5", NULL, NULL, info=FALSE, reml=TRUE, dataset="EMIP_corrected")
within_group <- get_exp_pack("EMIP_corrected", "within_group", NULL, NULL, NULL, NULL, info=FALSE, reml=TRUE, dataset="EMIP_corrected")
between_group_mean_diff <- get_exp_pack("EMIP_corrected", "between_group", NULL, NULL, "mean_diff", NULL, info=FALSE, reml=TRUE, dataset="EMIP_corrected")
between_group_pairtype <- get_exp_pack("EMIP_corrected", "between_group", NULL, NULL, "pairtype", NULL, info=FALSE, reml=TRUE, dataset="EMIP_corrected")

exps_list <- list(
  within_trial_within_2 = within_trial_within_2,
  within_trial_within_5 = within_trial_within_5,
  within_trial_between_2 = within_trial_between_2,
  within_trial_between_5 = within_trial_between_5,
  within_group = within_group,
  between_group_mean_diff = between_group_mean_diff,
  between_group_pairtype = between_group_pairtype
)

for (exp in names(exps_list)) {
  curr_exp <- exps_list[[exp]]
  sink_dir  <- dirname(curr_exp$config$results_log)
  assign_path(sink_dir)
  
  sink_file <- file.path(sink_dir, "console_output.txt")
  sink(sink_file, split = TRUE)
  tryCatch({
    cat("Processing model for experiment:", exp, "\n")
    work_flow_with_print(curr_exp$m_list, curr_exp$config)
    cat("✅️ Completed processing for experiment:", exp, "\n")
  }, finally = {
    sink()  # Ensure sink is closed even if an error occurs
  })
}