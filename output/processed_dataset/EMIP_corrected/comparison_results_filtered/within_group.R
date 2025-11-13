## =========================================
## LMM: Expertise × Trial (2 vs 5), using combined CSVs
## =========================================

library(tidyverse)
library(dplyr)
library(lme4)
library(lmerTest)
library(broom.mixed)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("within_group")

# ---- Parameters ----
combined_filename <- "combined_data.csv"        # name of the combined file inside each trial folder
trials <- c("trial_2", "trial_5")                  # which trials to include
responses <- c("Shape", "Length", "Direction", "Position", "Duration")

# ---- Helper: load one trial's combined CSV and tag Trial ----
load_trial <- function(trial_folder, file_name) {
  path <- file.path(trial_folder, file_name)
  if (!file.exists(path)) stop("File not found: ", path)
  
  read_csv(path, show_col_types = FALSE) %>%
    mutate(
      # Use the expertise column from your combined file
      expertise_a = factor(expertise_a,
                           levels = c("none", "low", "medium", "high"),
                           ordered = TRUE),
      # Trial as factor "2"/"5" from folder name
      Trial = factor(gsub("^trial_", "", trial_folder), levels = c("2","5")),
      exp_a = factor(exp_a),
      exp_b = factor(exp_b)
    )
}

# ---- Load both trials and stack ----
df <- map_dfr(trials, load_trial, file_name = combined_filename)

cat("Rows loaded:", nrow(df), "\n")
print(table(df$expertise_a, df$Trial))

# ---- Pretty printer for fixed effects with stars ----
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
      ),
      term = if_else(term == "(Intercept)", term, paste0(term, " ", stars))
    ) %>%
    select(term, estimate, std.error, statistic, df, p.value) %>%
    print(n = Inf)
}

message("Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1")

# ---- Fit: response ~ expertise_a * Trial + (1|exp_a) + (1|exp_b) ----
rand <- "(1 | exp_a) + (1 | exp_b)"
for (y in responses) {
  form <- as.formula(paste0(y, " ~ expertise_a * Trial + ", rand))
  mod <- lmer(form, data = df)
  print_model_with_sig(mod, y)
}
