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

# Specify algorithm we used (MultiMatch, ScaSim, NLD)
algo <- "MultiMatch"

base_path <- file.path(here(), "output", "processed_dataset", algo)

case <- "pairtype"


folder_path <- file.path(base_path, "code_rendering", "fix_expertise")

formula_additive <- list(
  fix_effect = "render_a + render_b",
  rand_effect = "(1 | exp_a) + (1 | exp_b)"
)

formula_interaction <- list(
  fix_effect = "render_a * render_b",
  rand_effect = "(1 | exp_a) + (1 | exp_b)"
)

additive_exp_pack <- get_model_pack(folder_path = folder_path,
                           formula_set = formula_additive,
                           info = TRUE,
                           reml = TRUE,
                           test = FALSE,
                           data_set = "code_rendering",
                           case = NULL,
                           algo = algo)

interaction_exp_pack <- get_model_pack(folder_path = folder_path,
                                    formula_set = formula_interaction,
                                    info = TRUE,
                                    reml = TRUE,
                                    test = FALSE,
                                    data_set = "code_rendering",
                                    case = NULL,
                                    algo = algo)
m_list <- additive_exp_pack$m_list

for (name in names(m_list)) {
  cat("\n============================", name, "============================\n")
  
  model_additive <- additive_exp_pack$m_list[[name]]
  model_interaction <- interaction_exp_pack$m_list[[name]]
  cat("\n")
  
  lrt_result <- anova(model_additive, model_interaction)
  print(lrt_result)
  
  AIC(model_interaction, model_additive)
  BIC(model_interaction, model_additive)

  summary(model_additive)
  
}

