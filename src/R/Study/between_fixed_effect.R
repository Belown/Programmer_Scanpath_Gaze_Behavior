library(here)
library(tidyverse)

source(file.path(here(), "src", "R", "auxiliary", "models.R"))
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))
source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))

dimensions <- c("Shape", "Direction", "Length", "Position", "Duration")

folder_path = file.path(here(), "output", "processed_dataset", "EMIP_corrected", 
                        "between_group")

# === Define formula set for 3 different models ===
formula_mean <- list(
  fix_effect = "expertise_mean",
  rand_effect = "(1 | exp_a) + (1 | exp_b)"
)
formula_diff <- list(
  fix_effect = "expertise_diff",
  rand_effect = "(1 | exp_a) + (1 | exp_b)"
)
formula_both <- list(
  fix_effect = "expertise_mean * expertise_diff",
  rand_effect = "(1 | exp_a) + (1 | exp_b)"
)

# === Define configs for workflow ===
output_path <- assign_path(file.path(here(), "output", "R", "between_fixed_effect_analysis"))

assign_path(file.path(output_path, "mean", "figures"))
assign_path(file.path(output_path, "diff", "figures"))
assign_path(file.path(output_path, "both", "figures"))

config_mean <- list(
  results_log   = file.path(output_path, "mean", "assumptions.txt"),
  figures_dir   = file.path(output_path, "mean", "figures"),
  output_prefix = "Expertise_Mean"
)
config_diff <- list(
  results_log   = file.path(output_path, "diff", "assumptions.txt"),
  figures_dir   = file.path(output_path, "diff", "figures"),
  output_prefix = "Expertise_Diff"
)
config_both <- list(
  results_log   = file.path(output_path, "both", "assumptions.txt"),
  figures_dir   = file.path(output_path, "both", "figures"),
  output_prefix = "Expertise_Both"
)

# === Fit initial models for all three formula sets ===
model_expertise_mean <- between_group(folder_path, formula_mean, info = FALSE, case = "both", reml = FALSE, test = TRUE)
model_expertise_diff <- between_group(folder_path, formula_diff, info = FALSE, case = "both", reml = FALSE, test = TRUE)
model_expertise_both <- between_group(folder_path, formula_both, info = FALSE, case = "both", reml = FALSE, test = TRUE)

# == Run workflows for all three models ===
work_flow_with_print(model_expertise_mean, config_mean)
work_flow_with_print(model_expertise_diff, config_diff)
work_flow_with_print(model_expertise_both, config_both)
