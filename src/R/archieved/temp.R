# =========================================================
# Analysis Script for Mixed Effects Models
# =========================================================
# This script performs statistical analysis using linear mixed effects models
# (LMM) and generalized linear mixed effects models (GLMM) for experimental data.
# =========================================================

library(here)
library(emmeans)
library(performance)
library(partR2)

# Load auxiliary functions for model building and validation workflow
source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "code_rendering", "models_cr.R"))
source(file.path(here(), "src", "R", "auxiliary", "model_analysis.R"))

dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")

# --- Experiment Type Configuration ---
data_set <- "code_rendering"  # Dataset identifier

exp_type <- "fix_rendering" #Options: "fix_expertise", "fix_expertise_rendering", "fix_rendering"

base_path <- file.path(here(), "output", "processed_dataset")

case <- "mean_diff"

folder_path <- file.path(base_path, data_set, exp_type)

formula_set <- list(
  fix_effect = "expertise_mean * expertise_diff",
  rand_effect = "(1 | dyad)"
)

exp_pack <- get_model_pack(folder_path=folder_path, formula_set=formula_set, info = TRUE, reml = TRUE, test = FALSE, dataset = data_set, case=case)

for (dim in dimensions) {
  cat(sprintf("Checking if %s dimension is singular\n", dim))
  print(isSingular(exp_pack$m_list[[dim]]))
}


temp <- exp_pack$m_list$Position
mf <- model_analysis(temp)