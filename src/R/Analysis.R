# =========================================================
# Analysis Script for Mixed Effects Models
# =========================================================
# This script performs statistical analysis using linear mixed effects models
# (LMM) and generalized linear mixed effects models (GLMM) for experimental data.
# =========================================================

library(here)

# Load auxiliary functions for model building and validation workflow
source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))

# --- Experiment Type Configuration ---
exp_type <- "between_group"    # Options: "within_trial", "within_group", "between_group"
data_set <- "EMIP_corrected"  # Dataset identifier
comp_type <- "within_group"   # Comparison type: "within_group" or "between_group"

# only used for within_trial experiments
trial_folder <- "trial_2"  # Specific trial folder to analyze

# only used for between_group experiments
case <- "pairtype"  # Analysis case: "mean_diff" or "pairtype"

# This includes fitted models, data, and config for the specified experiment type
model_pack <- get_model_pack(exp_type, data_set, comp_type, trial_folder, case, rand_effect = NULL, info = TRUE)

# Extract components from model package
folder_path <- model_pack$folder_path  # Output folder path
dataframe <- model_pack$data           # Processed dataset

# Run workflow to validate model assumptions and obtain final models
# Output is saved to: output/workflow/[experiment_path]/model_summary.txt
final_result <- work_flow_with_print(model_pack$m_list, model_pack$config)