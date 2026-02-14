# =========================================================
# Analysis Script for Mixed Effects Models
# =========================================================
# This script performs statistical analysis using linear mixed effects models
# (LMM) and generalized linear mixed effects models (GLMM) for experimental data.
# =========================================================

library(here)
library(performance)

# Load auxiliary functions for model building and validation workflow
source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "code_rendering", "models_cr.R"))

dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")

# --- Experiment Type Configuration ---
data_set <- "code_rendering"  # Dataset identifier

exp_type <- "fix_expertise" #Options: "fix_expertise", "fix_expertise_rendering", "fix_rendering"

# Specify algorithm we used (MultiMatch, ScaSim, NLD)
algo <- "MultiMatch"

base_path <- file.path(here(), "output", "processed_dataset", algo)

case <- "pairtype"


folder_path <- file.path(base_path, data_set, exp_type)

formula_set <- list(
  fix_effect = "render_a + render_b",
  rand_effect = "(1 | exp_a) + (1 | exp_b)"
)

exp_pack <- get_model_pack(folder_path = folder_path,
                           formula_set = formula_set,
                           info = TRUE,
                           reml = TRUE,
                           test = FALSE,
                           data_set = data_set,
                           case = case,
                           algo = algo)


# Extract components from model package
folder_path <- exp_pack$folder_path  # Output folder path
dataframe <- exp_pack$data           # Processed dataset

# Run workflow to validate model assumptions and obtain final models
# Output is saved to: output/workflow/[experiment_path]/model_summary.txt
final_result <- work_flow_with_print(exp_pack$m_list, exp_pack$config)

# Extract final model for Direction
for(dim in dimensions){
  cat("\n======", dim, "======\n")
  model <- final_result[[dim]]
  print(summary(model))
  
  sing <- if (inherits(model, "glmmTMB")) {
    # glmmTMB 没有直接的 isSingular 函数
    # 检查随机效应方差是否接近0
    vc <- glmmTMB::VarCorr(model)
    any(sapply(vc$cond, function(x) any(diag(x) < 1e-4)))
  } else {
    lme4::isSingular(model)
  }
  print(sing)
  
  # summary(rePCA(model))
  
  check_collinearity(model)
}
