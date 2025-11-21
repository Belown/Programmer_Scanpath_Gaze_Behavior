library(lme4)
library(here)

source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))
source(file.path(here(), "src", "R", "auxiliary", "test_helper.R"))

rand_effect_list <- list(
  exp_a = "(1 | exp_a)",
  exp_b = "(1 | exp_b)",
  both = "(1 | exp_a) + (1 | exp_b)",
  none = ""
)
case <- "mean_diff" # "mean_diff" or "pairtype" for between_group experiment

# Use this function to test random effect in model
test_random_effects(rand_effect_list)