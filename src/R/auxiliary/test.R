## =========================================
## Linear mixed model for one combined trial file
## =========================================

## install.packages(c("tidyverse", "dplyr", "lme4", "lmerTest", "broom.mixed", "here"))

library(tidyverse)
library(dplyr)
library(lme4)
library(lmerTest)
library(broom.mixed)
library(here)

source(file.path(here(), "src", "R", "auxiliary", "assumptions_LMM.R"))

base_path <- file.path(here(), "output", "processed_dataset")

# --- Parameters ---
data_set <- "EMIP_corrected"
result <- "comparison_results_filtered"
comp_type <- "within_group"
trial_folder <- "trial_5"

trial_path <- file.path(base_path, data_set, result, comp_type, trial_folder)

# path to your combined CSV
combined_path <- file.path(trial_path, "combined_data.csv")

responses <- c("Shape", "Length", "Direction", "Position", "Duration")

# --- Diagnostics config ---
# diag_base_dir <- file.path(base_path, data_set, "diagnostics")
diag_base_dir <- trial_path

config <- list(
  results_log   = file.path(diag_base_dir, paste0("assumptions_", trial_folder, ".txt")),
  figures_dir   = file.path(diag_base_dir, "figures", trial_folder),
  output_prefix = paste(data_set, trial_folder, sep = "_")
)

# Create directories if needed
dir.create(diag_base_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(config$figures_dir, recursive = TRUE, showWarnings = FALSE)

# --- Load data ---
df <- read_csv(combined_path, show_col_types = FALSE) %>%
  mutate(
    # since this is for within-group comparison, they have same expertise
    expertise_a = factor(expertise_a,
                         levels = c("none", "low", "medium", "high"),
                         ordered = TRUE),
    across(c(exp_a, exp_b), as.factor)
  )

cat("Rows loaded:", nrow(df), "\n")
print(table(df$expertise_a))

# --- Helper: print fixed effects neatly ---
print_model_with_sig <- function(mod, response_name) {
  cat("\n====", response_name, "====\n")
  tidy(mod, effects = "fixed") %>%
    mutate(
      stars = case_when(
        p.value < 0.001 ~ "***",
        p.value < 0.01  ~ "**",
        p.value < 0.05  ~ "*",
        p.value < 0.1   ~ ".",
        TRUE            ~ ""
      )
    ) %>%
    select(term, estimate, std.error, statistic, df, p.value, stars) %>%
    print(n = Inf)
}

# --- Fit models and run diagnostics ---
models_list <- list()
assumption_summaries <- list()

cat("\n\n========================================\n")
cat("Fitting model for Shape ...\n")
cat("========================================\n")

form <- as.formula(paste0("Shape ~ expertise_a + (1 | exp_a) + (1 | exp_b)"))
mod  <- lmer(form, data = df)

print_model_with_sig(mod, "Shape")

# Diagnostics for this outcome
diag_res <- check_all_assumptions(mod, "Shape", config)

models_list[["Shape"]] <- mod
assumption_summaries[[y]] <- diag_res$summary


# for (y in responses) {
#   cat("\n\n========================================\n")
#   cat("Fitting model for", y, "...\n")
#   cat("========================================\n")
#   
#   form <- as.formula(paste0(y, " ~ expertise_a + (1 | exp_a) + (1 | exp_b)"))
#   mod  <- lmer(form, data = df)
#   
#   print_model_with_sig(mod, y)
#   
#   # Diagnostics for this outcome
#   diag_res <- check_all_assumptions(mod, y, config)
#   
#   models_list[[y]] <- mod
#   assumption_summaries[[y]] <- diag_res$summary
# }
