library(lme4)
library(here)

source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "models.R"))
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))
# source(file.path(here(), "src", "R", "diag.R"))

base_path <- file.path(here(), "output", "processed_dataset")

# --- Parameters ---
exp_type <- "within_trial"
data_set <- "EMIP_corrected"
comp_type <- "between_group"
trial_folder <- "trial_2"

# --- Get models and other information ---
model_pack <- get_model_pack(exp_type, data_set, comp_type, trial_folder)
folder_path <- model_pack$folder_path

# --- Run workflow to check model assumptions and get final models ---
final_result <- work_flow(model_pack$models, model_pack$config)

# --- Print model summaries with significance annotations ---
print_model_table(folder_path, final_result)