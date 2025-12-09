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
data_set <- "EMIP_corrected"  # Dataset identifier
exp_type <- "within_group"    # Options: "within_trial", "within_group", "between_group"
comp_type <- "within_group"   # Comparison type: "within_group" or "between_group" - only used when exp_type is within_tiral

# only used for within_trial experiments
trial_folder <- "trial_2"  # Specific trial folder to analyze

# only used for between_group experiments
case <- "mean_diff"  # Analysis case: "mean_diff" or "pairtype"

# This includes fitted models, data, and config for the specified experiment type
# Modify fixed and random effects in get_exp_pack() if needed
exp_pack <- get_exp_pack(data_set, exp_type, comp_type, trial_folder, case, rand_effect=NULL, info=TRUE, reml=TRUE, data="EMIP_corrected")

# Extract components from model package
folder_path <- exp_pack$folder_path  # Output folder path
dataframe <- exp_pack$data           # Processed dataset

# Run workflow to validate model assumptions and obtain final models
# Output is saved to: output/workflow/[experiment_path]/model_summary.txt
final_result <- work_flow_with_print(exp_pack$m_list, exp_pack$config)