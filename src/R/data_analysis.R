
library(here)

r_path <- file.path(here(), "src", "R")

source(file.path(r_path, "models.R"))
source(file.path(r_path, "workflow.R"))

# Example usage for within-trial analysis
data_set <- "EMIP_corrected"
result <- "comparison_results_filtered"
comp_type <- "within_group"
trial_folder <- "trial_5"

# models <- within_group(data_set, result)

#shape_model <- models[["Shape"]]
#print_model_with_sig(shape_model, "Shape")

models <- between_group(data_set, result, "mean_diff")

shape_model <- models[["Shape"]]

check_if <- check_interaction(shape_model)

is(shape_model, "lmerMod")


# print_model_with_sig(shape_model, "Mean_diff")