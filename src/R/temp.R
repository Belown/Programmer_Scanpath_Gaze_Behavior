library(here)
# source(file.path(here(), "src", "R", "auxiliary", "helper.R"))
source(file.path(here(), "src", "R", "auxiliary", "models.R"))
source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))

base_path <- file.path(here(), "output", "processed_dataset")
folder_path <- file.path(base_path, "EMIP_corrected", "between_group")

formula_set <- list(
  fix_effect = "expertise_mean * expertise_diff",
  rand_effect = "(1 | exp_a) + (1 | exp_b)"
)

model_pack <- between_group(folder_path, formula_set, info = TRUE, "mean_diff", reml = TRUE)

m_list <- model_pack$m_list

check_interaction(m_list)

# for (dim in names(m_list)) {
#   cat("Model for dimension:", dim, "\n")
#   model <- m_list[[dim]]
#   print(check_interaction(model))
#   cat("============================\n")
# }
