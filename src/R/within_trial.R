## =========================================
## Linear mixed model for one combined trial file
## =========================================

library(tidyverse)
library(dplyr)
library(lme4)
library(lmerTest)
library(broom.mixed)
library(here)

base_path <- file.path(here(), "output", "processed_dataset")

# --- Parameters ---
data_set <- "EMIP_corrected"
result <- "comparison_results_filtered"
trial_folder <- "trial_5"

# path to your combined CSV
combined_path <- file.path(base_path, data_set, result, "within_group", trial_folder, "combined_data.csv")

responses <- c("Shape", "Length", "Direction", "Position", "Duration")

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

# --- Fit and print models for each response ---
message("Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1")

for (y in responses) {
  form <- as.formula(paste0(y, " ~ expertise_a + (1 | exp_a) + (1 | exp_b)"))
  mod <- lmer(form, data = df)
  print_model_with_sig(mod, y)
}