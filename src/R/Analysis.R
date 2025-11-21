library(here)

source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))

# --- Parameters ---
exp_type <- "within_trial"
data_set <- "EMIP_corrected"
comp_type <- "within_group"

# Only used for within_trial exp_type
trial_folder <- "trial_2"

# Only used for between_group exp_type
case <- "pairtype" # "mean_diff" or "pairtype"

rand_effect <- "(1 | exp_a) + (1 | exp_b)"

# --- Get models and other information ---
model_pack <- get_model_pack(exp_type, data_set, comp_type, trial_folder, case, rand_effect, TRUE)
folder_path <- model_pack$folder_path
dataframe <- model_pack$data

# --- Run workflow to check model assumptions and get final models ---
# The output from work_flow will be stored under folder output/workflow
final_result <- work_flow_with_print(model_pack$m_list, model_pack$config)