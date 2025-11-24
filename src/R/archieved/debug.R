library(lme4)
library(here)

source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "models.R"))
# source(file.path(here(), "src", "R", "diag.R"))

base_path <- file.path(here(), "output", "processed_dataset")

# --- Parameters ---
exp_type <- "within_trial"
data_set <- "EMIP_corrected"
comp_type <- "between_group"
trial_folder <- "trial_5"

model_pack <- switch(
  exp_type,
  "within_trial" = {
    trial_level_path <- file.path(base_path, data_set, comp_type,trial_folder)
    within_trial_pack <- within_trial(trial_level_path)
  },
  "within_group" = {
    within_group_path <- file.path(base_path, data_set, "within_group")
    within_group_pack <- within_group(within_group_path)
  },
  "between_group" = {
    between_group_path <- file.path(base_path, data_set, "between_group")
    between_group_pack <- between_group(between_group_path, "both")
  }
)

model_list <- model_pack$m_list
config <- model_pack$config

# # --- Print models ---
# for (dim in dimensions) {
#   print_model_with_sig(model_list[[dim]], dim)
# }

family_list <- setNames(
  replicate(length(dimensions), gaussian(), simplify = FALSE),
  dimensions
)
glmms <- lmm_to_glmm(model_list, family_list)

print_model_with_sig(glmms$Shape, "Shape")