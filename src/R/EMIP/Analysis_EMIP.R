# =========================================================
# Analysis Script for Mixed Effects Models
# =========================================================
# This script performs statistical analysis using linear mixed effects models
# (LMM) and generalized linear mixed effects models (GLMM) for experimental data.
# =========================================================

library(here)

# Load auxiliary functions for model building and validation workflow
source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "emip", "helper_emip.R"))

# --- Experiment Type Configuration ---
data_set <- "EMIP_corrected"  # Dataset identifier
exp_type <- "within_stimulus"    # Options: "within_trial", "within_group", "between_group"

# only used for within_trial experiments (rectangle or vehicle)
stimulus_folder <- "rectangle"

# only used for between_group experiments
case <- "pairtype"  # Analysis case: "mean_diff" or "pairtype"

# Specify algorithm we used (MultiMatch, ScaSim, NLD)
algo <- "NLD"

# This includes fitted models, data, and config for the specified experiment type
# Modify fixed and random effects in get_exp_pack_emip() if needed
exp_pack <- get_exp_pack_emip(data_set = data_set,
                         exp_type = exp_type,
                         stimulus_folder = stimulus_folder,
                         case = case,
                         rand_effect = NULL,
                         info = TRUE,
                         reml = TRUE,
                         algo = algo)

# Extract components from model package
folder_path <- exp_pack$folder_path  # Output folder path
dataframe <- exp_pack$data           # Processed dataset

# Run workflow to validate model assumptions and obtain final models
# Output is saved to: output/workflow/[experiment_path]/model_summary.txt
final_result <- work_flow_with_print(exp_pack$m_list, exp_pack$config)

