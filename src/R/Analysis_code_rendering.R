# =========================================================
# Analysis Script for Mixed Effects Models
# =========================================================
# This script performs statistical analysis using linear mixed effects models
# (LMM) and generalized linear mixed effects models (GLMM) for experimental data.
# =========================================================

library(here)

# Load auxiliary functions for model building and validation workflow
source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "code_rendering", "models_cr.R"))

# --- Experiment Type Configuration ---
data_set <- "code_rendering"  # Dataset identifier

exp_type <- "fix_expertise_rendering" #Options: "fix_expertise", "fix_expertise_rendering", "fix_rendering"

base_path <- file.path(here(), "output", "processed_dataset")
folder_path <- file.path(base_path, data_set, exp_type)

formula_set <- list(
  fix_effect = "expertise_a * render_a",
  rand_effect = "(1 | exp_a) + (1 | exp_b)"
)

exp_pack <- get_model_pack(folder_path, formula_set, info = TRUE, reml = TRUE, test = FALSE, dataset = data_set)


# Extract components from model package
folder_path <- exp_pack$folder_path  # Output folder path
dataframe <- exp_pack$data           # Processed dataset

# Run workflow to validate model assumptions and obtain final models
# Output is saved to: output/workflow/[experiment_path]/model_summary.txt
final_result <- work_flow_with_print(exp_pack$m_list, exp_pack$config)