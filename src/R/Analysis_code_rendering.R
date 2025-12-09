# =========================================================
# Analysis Script for Mixed Effects Models
# =========================================================
# This script performs statistical analysis using linear mixed effects models
# (LMM) and generalized linear mixed effects models (GLMM) for experimental data.
# =========================================================

library(here)

# Load auxiliary functions for model building and validation workflow
source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "models_code_rendering.R"))

# --- Experiment Type Configuration ---
data_set <- "code_rendering"  # Dataset identifier
exp_type <- "within_group"    # Options: "within_trial", "within_group", "between_group"

exp_name <- "within_expertise_rendering" #Options: "within_expertise", "within_expertise_rendering", "within_rendering"

base_path <- file.path(here(), "output", "processed_dataset")
folder_path <- file.path(base_path, data_set, exp_name)


formula_set <- list(
  fix_effect = "expertise_a * expertise_b * render_a * render_b",
  rand_effect = "(1 | exp_a) + (1 | exp_b)"
)

exp_pack <- within_group(folder_path, formula_set, info = TRUE, reml = TRUE, test = FALSE, dataset = data_set)


# Extract components from model package
folder_path <- exp_pack$folder_path  # Output folder path
dataframe <- exp_pack$data           # Processed dataset

# Run workflow to validate model assumptions and obtain final models
# Output is saved to: output/workflow/[experiment_path]/model_summary.txt
final_result <- work_flow_with_print(exp_pack$m_list, exp_pack$config)