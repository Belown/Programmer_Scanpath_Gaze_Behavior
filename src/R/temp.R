library(lme4)
library(here)

source(file.path(here(), "src", "R", "workflow.R"))
source(file.path(here(), "src", "R", "models.R"))

base_path <- file.path(here(), "output", "processed_dataset")

# --- Parameters ---
data_set <- "EMIP_corrected"
result <- "comparison_results_filtered"
comp_type <- "between_group"
trial_folder <- "trial_5"

trial_path <- file.path(base_path, data_set, result, comp_type, trial_folder)
trial_path_nobaseline <- file.path(base_path, data_set, "data_without_baseline", result, comp_type)

# --- Diagnostics config ---
# diag_base_dir <- file.path(base_path, data_set, "diagnostics")
# diag_base_dir <- trial_path
diag_base_dir <- trial_path_nobaseline

config <- list(
  results_log   = file.path(diag_base_dir, paste0("assumptions_", trial_folder, ".txt")),
  figures_dir   = file.path(diag_base_dir, "figures", trial_folder),
  output_prefix = paste(data_set, trial_folder, sep = "_")
)

model_list <- between_group(trial_path_nobaseline)

result <- work_flow(model_list, config)


