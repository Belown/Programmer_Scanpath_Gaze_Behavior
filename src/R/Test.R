# =========================================================
# Random Effects Testing Script
# =========================================================

library(lme4)
library(here)

source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))
source(file.path(here(), "src", "R", "auxiliary", "test_helper.R"))

# Define random effects component for comparison
rand_effect_list <- list(
  exp_a = "(1 | exp_a)",                    # Random intercept for experiment A only
  exp_b = "(1 | exp_b)",                    # Random intercept for experiment B only
  both = "(1 | exp_a) + (1 | exp_b)",       # Random intercepts for both experiments
  none = ""                                 # No random effects (fixed effects model)
)

# Results will be stored in: output/R/random_effect_analysis/random_effect_result.csv
# Use the Python notebook Visualization.ipynb to explore the results
compare_random_effects_aicbic(rand_effect_list)