# =========================================================
# Analysis Script for Mixed Effects Models
# =========================================================
# This script performs statistical analysis using linear mixed effects models
# (LMM) and generalized linear mixed effects models (GLMM) for experimental data.
# =========================================================

library(here)

# Load auxiliary functions for model building and validation workflow
source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "emip", "helper.R"))
source(file.path(here(), "src", "R", "auxiliary", "model_analysis.R"))

# Set up constant
dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")

curr_folder <- dirname(rstudioapi::getActiveDocumentContext()$path)

# --- Experiment Type Configuration ---
data_set <- "EMIP_corrected"
exp_type <- "between_group"
case <- "pairtype"

# Experiment pack includes fitted models, data, and config
exp_pack <- get_exp_pack(data_set = data_set,
                         exp_type = exp_type,
                         comp_type = NULL,
                         trial_folder = NULL,
                         case = case,
                         rand_effect = NULL,
                         info = TRUE,
                         reml = TRUE,
                         dataset = "EMIP_corrected")

# Run workflow to validate model assumptions and obtain final models
final_result <- work_flow_with_print(exp_pack$m_list, exp_pack$config)

print(curr_folder)

sink_file <- file.path(curr_folder, "model_analysis.txt")
sink(sink_file, split = TRUE)
tryCatch({
  cat("\n========================================\n")
  cat("Model Analysis\n")
  cat("========================================\n")
  for (dim in dimensions) {
    
    cat("\n=========", dim, "=========\n")
    model <- final_result[[dim]]
    model_analysis(model = model, dimension = dim, path = curr_folder)
  }
  cat("✅️ Completed! \n")
}, finally = {
  sink()  # Ensure sink is closed even if an error occurs
})
