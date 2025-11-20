library(here)

source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))

# --- Parameters ---
exp_type <- "between_group"
data_set <- "EMIP_corrected"
comp_type <- "between_group"
trial_folder <- "trial_2"
# Only used for between_group exp_type
case <- "mean_diff" # "mean_diff" or "pairtype"

# --- Get models and other information ---
model_pack <- get_model_pack(exp_type, data_set, comp_type, trial_folder, case, "both")
folder_path <- model_pack$folder_path
dataframe <- model_pack$data

# --- Run workflow to check model assumptions and get final models ---
final_result <- work_flow(model_pack$m_list, model_pack$config)

# --- Print model summaries with significance annotations ---
print_model_table(folder_path, final_result)