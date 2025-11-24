library(lme4)
library(here)

source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "models.R"))
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))

exp_type <- "within_trial"    # Options: "within_trial", "within_group", "between_group"
data_set <- "EMIP_corrected"  # Dataset identifier
comp_type <- "within_group"   # Comparison type: "within_group" or "between_group"

trial_folder <- "trial_2"  # Specific trial folder to analyze

case <- "pairtype"  # Analysis case: "mean_diff" or "pairtype"

model_pack <- get_exp_pack(exp_type, data_set, comp_type, trial_folder, case, rand_effect = NULL, info = FALSE, reml = TRUE)

temp <- model_pack$m_list$Shape

random_effects <- findbars(formula(temp))
print(random_effects)


# # --- Print models ---
# for (dim in dimensions) {
#   print_model_with_sig(model_list[[dim]], dim)
# }

# family_list <- setNames(
#   replicate(length(dimensions), gaussian(), simplify = FALSE),
#   dimensions
# )
# glmms <- lmm_to_glmm(model_list, family_list)
# 
# print_model_with_sig(glmms$Shape, "Shape")