library(lme4)
library(here)

source(file.path(here(), "src", "R", "workflow.R"))
source(file.path(here(), "src", "R", "models.R"))
# source(file.path(here(), "src", "R", "diag.R"))

base_path <- file.path(here(), "output", "processed_dataset")

# --- Parameters ---
exp_type <- "between_group"
data_set <- "EMIP_corrected"
comp_type <- "between_group"
trial_folder <- "trial_2"

model_pack <- switch(
  exp_type,
  "within_trial" = {
    folder_path <- file.path(base_path, data_set, comp_type,trial_folder)
    within_trial_pack <- within_trial(folder_path)
  },
  "within_group" = {
    folder_path <- file.path(base_path, data_set, "within_group")
    within_group_pack <- within_group(folder_path)
  },
  "between_group" = {
    folder_path <- file.path(base_path, data_set, "between_group")
    between_group_pack <- between_group(folder_path, "both")
  }
)

model_list <- model_pack$models
config <- model_pack$config

final_result <- work_flow(model_list, config)

# --- Print models ---
sink(file.path(folder_path, "model_summaries.txt"))
for (dim in dimensions) {
  print_model_with_sig(final_result[[dim]], dim)
}
sink()