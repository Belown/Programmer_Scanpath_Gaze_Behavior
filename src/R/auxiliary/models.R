# =========================================================
# LMM generation module
# =========================================================
# This module contain functions to generate linear mixed models (LMMs)
# for within-trial, within-group, and between-group comparisons.
# =========================================================

## install.packages(c("tidyverse", "dplyr", "lme4", "lmerTest", "broom.mixed", "here"))
library(tidyverse)
library(dplyr)
library(lme4)
library(lmerTest)
library(broom.mixed)
library(here)

# Set up base path and constant variables
base_data_path <- file.path(here(), "output", "processed_dataset")
dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")

#' Generate LMMs for within-trial comparisons
#' 
#' @param folder_path The folder path containing the combined CSV
#' @return A list of fitted LMMs for each dimension
within_trial <- function(folder_path){
  # Construct path to combined CSV
  combined_path <- file.path(folder_path, "combined_data.csv")
  cat("Loading data from:", combined_path, "\n")
  
  # Read and preprocess data
  # Since for within_trial, all data share the same expertise
  df <- read_csv(combined_path, show_col_types = FALSE) %>%
    mutate(
      expertise_a = factor(expertise_a,
                           levels = c("none", "low", "medium", "high"),
                           ordered = TRUE),
      across(c(exp_a, exp_b), as.factor)
    )
  
  # Provide basic info about loaded data
  cat("Rows loaded:", nrow(df), "\n")
  print(table(df$expertise_a))

  config <- list(
    results_log   = file.path(folder_path, "assumptions.txt"),
    figures_dir   = file.path(folder_path, "figures"),
    output_prefix = "within_trial"
  )
  
  # Clear previous log if exists
  if (file.exists(config$results_log)) {
    write("", file = config$results_log)
  }
  
  # Generate LMMs for each dimension and add them to the list
  models_list <- list()
  for (y in dimensions) {
    form <- as.formula(paste0(y, " ~ expertise_a + (1 | exp_a) + (1 | exp_b)"))
    mod <- lmer(form, data = df)
    models_list[[y]] <- mod
  }

  return (list(
    data = df,
    models = models_list,
    config = config,
    folder_path = folder_path
  ))
}

#' Generate LMMs for within-group comparisons across trials
#' 
#' @param folder_path The base folder path containing trial subfolders
#' @return A list of fitted LMMs for each dimension
within_group <- function(folder_path){
  # Construct paths
  trial_2_path <- file.path(folder_path, "trial_2")
  trial_5_path <- file.path(folder_path, "trial_5")
  combined_filename <- "combined_data.csv"
  trials <- c(trial_2_path, trial_5_path)
  dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")
  
  # Helper function to load one trial's combined CSV and tag Trial
  load_trial <- function(trial_folder, file_name) {
    path <- file.path(trial_folder, file_name)
    if (!file.exists(path)) stop("File not found: ", path)
    
    # Get trial number from folder name
    folder_name <- basename(trial_folder)
    trial_num <- gsub("^trial_", "", folder_name)
    
    # Read and preprocess data
    # Since for within_trial, all data share the same expertise
    read_csv(path, show_col_types = FALSE) %>%
      mutate(
        # Use the expertise column from your combined file
        expertise_a = factor(expertise_a,
                             levels = c("none", "low", "medium", "high"),
                             ordered = TRUE),
        # Trial as factor "2"/"5" from folder name
        Trial = factor(trial_num, levels = c("2","5")),
        exp_a = factor(exp_a),
        exp_b = factor(exp_b)
      )
  }
  
  # Load both trials' data and stack them
  df <- map_dfr(trials, load_trial, file_name = combined_filename)
  
  # Provide basic info about loaded data
  cat("Rows loaded:", nrow(df), "\n")
  print(table(df$expertise_a, df$Trial))
  
  # Generate LMMs for each dimension and add them to the list
  models_list <- list()
  rand <- "(1 | exp_a) + (1 | exp_b)"
  for (y in dimensions) {
    form <- as.formula(paste0(y, " ~ expertise_a * Trial + ", rand))
    mod <- lmer(form, data = df)
    models_list[[y]] <- mod
  }

  config <- list(
    results_log   = file.path(folder_path, "assumptions.txt"),
    figures_dir   = file.path(folder_path, "figures"),
    output_prefix = basename(folder_path)
  )
  
  # Clear previous log if exists
  if (file.exists(config$results_log)) {
    write("", file = config$results_log)
  }
  
  return (list(
    data = df,
    models = models_list,
    config = config,
    folder_path = folder_path
  ))
}

#' Generate LMMs for between-group comparisons across trials
#' 
#' @param folder_path The base folder path containing trial subfolders
#' @param case The model type to run ("mean_diff", "pairtype", or "both")
#' @return A list of fitted LMMs for each dimension 
between_group <- function(folder_path, case){
  # Construct paths
  trial_2_path <- file.path(folder_path, "trial_2")
  trial_5_path <- file.path(folder_path, "trial_5")
  combined_filename <- "combined_data.csv"
  trials <- c(trial_2_path, trial_5_path)
  dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")

  # Helper function to load one trial's combined CSV and tag Trial
  load_trial <- function(trial_folder, file_name) {
    path <- file.path(trial_folder, file_name)
    if (!file.exists(path)) stop("File not found: ", path)
    
    # Get trial number from folder name
    folder_name <- basename(trial_folder)
    trial_num <- gsub("^trial_", "", folder_name)
    
    # Read and preprocess data
    read_csv(path, show_col_types = FALSE) %>%
      mutate(
        expertise_a = factor(expertise_a,
                             levels = c("none", "low", "medium", "high"),
                             ordered = TRUE),
        expertise_b = factor(expertise_b,
                             levels = c("none", "low", "medium", "high"),
                             ordered = TRUE),
        Trial = factor(trial_num, levels = c("2","5")),
        exp_a = factor(exp_a),
        exp_b = factor(exp_b)
      )
  }
  
  # Load both trials' data and stack them
  df <- map_dfr(trials, load_trial, file_name = combined_filename)
  
  # Convert ordered levels to numeric (from 1 to 4) for calculations
  df$expertise_a_num <- as.integer(df$expertise_a)
  df$expertise_b_num <- as.integer(df$expertise_b)
  
  # Expertise Mean
  df$expertise_mean <- (df$expertise_a_num + df$expertise_b_num) / 2
  # Expertise Difference
  df$expertise_diff <- abs(df$expertise_a_num - df$expertise_b_num)
  
  # Construct PairType
  df$PairType <- case_when(
    df$expertise_a == "high" & df$expertise_b == "low" ~ "HL",
    df$expertise_a == "high" & df$expertise_b == "medium" ~ "HM",
    df$expertise_a == "high" & df$expertise_b == "none" ~ "HN",
    df$expertise_a == "low" & df$expertise_b == "medium" ~ "LM",
    df$expertise_a == "low" & df$expertise_b == "none" ~ "LN",
    df$expertise_a == "medium"  & df$expertise_b == "none"  ~ "MN"
  )
  
  # Convert PairType to factor for modeling
  df$PairType <- factor(df$PairType, levels = c("LN", "LM", "MN", "HN", "HL", "HM"))
  
  # Provide basic info about loaded data
  cat("Rows loaded:", nrow(df), "\n")
  print(table(df$expertise_a, df$Trial))

  # Generate LMMs for each dimension and add them to the list  
  models_list <- list()
  rand <- "(1 | exp_a) + (1 | exp_b)"
  for (y in dimensions) {
    if (case %in% c("mean_diff", "both")) {
      form_md <- as.formula(paste0(y, " ~ expertise_mean * expertise_diff + ", rand))
      mod_md  <- lmer(form_md, data = df)
      models_list[[y]] <- mod_md
    }
    if (case %in% c("pairtype", "both")) {
      form_pt <- as.formula(paste0(y, " ~ PairType + ", rand))
      mod_pt  <- lmer(form_pt, data = df)
      models_list[[y]] <- mod_pt
    }
  }

  config <- list(
    results_log   = file.path(folder_path, "assumptions.txt"),
    figures_dir   = file.path(folder_path, "figures"),
    output_prefix = basename(folder_path)
  )
  
  # Clear previous log if exists
  if (file.exists(config$results_log)) {
    write("", file = config$results_log)
  }
  
  return (list(
    data = df,
    models = models_list,
    config = config,
    folder_path = folder_path
  ))
}

#' Print model summary with significance stars
#' 
#' @param mod Fitted model (lmerMod or glmmTMB)
#' @param dimension_name Name of the dimension for display
print_model_with_sig <- function(mod, dimension_name) {
  require(dplyr)
  
  cat("\n====", dimension_name, "====\n")
  cat("Formula:", deparse(formula(mod)), "\n")
  
  if (inherits(mod, "glmmTMB")) {
    cat("Type: glmmTMB | Family:", family(mod)$family, "\n\n")
    
    # Get coefficients table
    coef_df <- as.data.frame(summary(mod)$coefficients$cond)
    coef_df$term <- rownames(coef_df)
    rownames(coef_df) <- NULL
    
    # Rename columns for consistency
    names(coef_df) <- c("estimate", "std.error", "statistic", "p.value", "term")
    
    # Change column order and add starts
    coef_df <- coef_df %>%
      select(term, estimate, std.error, statistic, p.value) %>%
      mutate(
        stars = case_when(
          p.value < 0.001 ~ "***",
          p.value < 0.01  ~ "**",
          p.value < 0.05  ~ "*",
          p.value < 0.1   ~ ".",
          TRUE            ~ ""
        )
      )
    
  } else if (inherits(mod, "lmerMod")) {
    cat("Type: lmer\n\n")
    
    # Use lmerTest or compute p value
    coef_df <- as.data.frame(summary(mod)$coefficients)
    coef_df$term <- rownames(coef_df)
    rownames(coef_df) <- NULL
    
    if ("Pr(>|t|)" %in% names(coef_df)) {
      names(coef_df)[names(coef_df) == "Pr(>|t|)"] <- "p.value"
    }
    
    coef_df <- coef_df %>%
      select(term, Estimate, `Std. Error`, `t value`, 
             any_of(c("df", "p.value"))) %>%
      rename(estimate = Estimate, 
             std.error = `Std. Error`,
             statistic = `t value`) %>%
      mutate(
        stars = if("p.value" %in% names(.)) {
          case_when(
            p.value < 0.001 ~ "***",
            p.value < 0.01  ~ "**",
            p.value < 0.05  ~ "*",
            p.value < 0.1   ~ ".",
            TRUE            ~ ""
          )
        } else {
          ""
        }
      )
  }
  print(coef_df, row.names = FALSE)
  message("Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1")
  invisible(coef_df)
}
