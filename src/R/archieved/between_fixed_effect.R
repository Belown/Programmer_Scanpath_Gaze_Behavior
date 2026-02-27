library(here)
library(tidyverse)

source(file.path(here(), "src", "R", "auxiliary", "emip", "models.R"))
source(file.path(here(), "src", "R", "auxiliary", "emip", "helper_emip.R"))
source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))

dimensions <- c("Shape", "Direction", "Length", "Position", "Duration")

data_set <- "EMIP_corrected"

algo <- "NLD"

folder_path = file.path(here(), "output", "processed_dataset", algo, "EMIP_corrected", 
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
output_path <- assign_path(file.path(here(), "output", "R", "between_fixed_effect_analysis", data_set))

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
model_expertise_mean <- between_group(folder_path, formula_mean, info = FALSE, case = "both", reml = FALSE, test = TRUE, algo = algo)
model_expertise_diff <- between_group(folder_path, formula_diff, info = FALSE, case = "both", reml = FALSE, test = TRUE, algo = algo)
model_expertise_both <- between_group(folder_path, formula_both, info = FALSE, case = "both", reml = FALSE, test = TRUE, algo = algo)

exps <- list(
  Expertise_Mean = list(model = model_expertise_mean, config = config_mean),
  Expertise_Diff = list(model = model_expertise_diff, config = config_diff),
  Expertise_Both = list(model = model_expertise_both, config = config_both)
)

for (exp in names(exps)) {
  curr_exp <- exps[[exp]]
  sink_dir  <- dirname(curr_exp$config$results_log)
  assign_path(sink_dir)
  
  sink_file <- file.path(sink_dir, "console_output.txt")
  sink(sink_file, split = TRUE)
  tryCatch({
    cat("Processing model for experiment:", exp, "\n")
    work_flow_with_print(curr_exp$model, curr_exp$config)
    cat("✅️ Completed processing for experiment:", exp, "\n")
  }, finally = {
    sink()  # Ensure sink is closed even if an error occurs
  })
}