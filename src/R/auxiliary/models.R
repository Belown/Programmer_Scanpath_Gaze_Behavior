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
library(here)

# Set up constant variables
dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")

#' Generate LMMs for within-trial comparisons
#' 
#' @param folder_path The folder path containing the combined CSV
#' @return A list of fitted LMMs for each dimension and other info
within_trial <- function(folder_path, rand_effect, info){
  # Construct path to combined CSV
  combined_path <- file.path(folder_path, "combined_data.csv")
  # cat("Loading data from:", combined_path, "\n")
  
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
  if (info) {
    cat("Rows loaded:", nrow(df), "\n")
    print(table(df$expertise_a))
  }

  trial_folder <- basename(folder_path)
  comp_type <- basename(dirname(folder_path))
  combined_path <- paste(comp_type, trial_folder, sep = "_")

  output_path <- file.path(here(), "output", "R", "workflow", "within_trial", combined_path)

  if (!dir.exists(output_path)) {
    dir.create(output_path, recursive = TRUE)
  }

  config <- list(
    results_log   = file.path(output_path, "assumptions.txt"),
    figures_dir   = file.path(output_path, "figures"),
    output_prefix = "within_trial"
  )
  
  # Clear previous log if exists
  if (file.exists(config$results_log)) {
    write("", file = config$results_log)
  }
  
  # Generate LMMs for each dimension and add them to the list
  models_list <- list()
  
  # For investigating random effect
  for (y in dimensions) {
    if (str_length(rand_effect) == 0) {
      form <- as.formula(paste0(y, " ~ expertise_a"))
      mod <- lm(form, data = df)
    } else {
      form <- as.formula(paste0(y, " ~ expertise_a + ", rand_effect))
      mod <- lmer(form, data = df)
    }
    models_list[[y]] <- mod
  }

  return (list(
    data = df,
    m_list = models_list,
    config = config,
    folder_path = folder_path
  ))
}

#' Generate LMMs for within-group comparisons across trials
#' 
#' @param folder_path The base folder path containing trial subfolders
#' @return A list of fitted LMMs for each dimension and other info
within_group <- function(folder_path, rand_effect, info){
  # Construct paths
  trial_2_path <- file.path(folder_path, "trial_2")
  trial_5_path <- file.path(folder_path, "trial_5")
  combined_filename <- "combined_data.csv"
  trials <- c(trial_2_path, trial_5_path)
  
  # Helper function to load one trial's combined CSV and tag trial
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
        # trial as factor "2"/"5" from folder name
        trial = factor(trial_num, levels = c("2","5")),
        exp_a = factor(exp_a),
        exp_b = factor(exp_b)
      )
  }
  
  # Load both trials' data and stack them
  df <- map_dfr(trials, load_trial, file_name = combined_filename)
  
  # Provide basic info about loaded data
  if (info) {
    cat("Rows loaded:", nrow(df), "\n")
    print(table(df$expertise_a))
  }
  
  # Generate LMMs for each dimension and add them to the list
  models_list <- list()
  
  # For investigating random effect

  for (y in dimensions) {
    if (str_length(rand_effect) == 0) {
      form <- as.formula(paste0(y, " ~ expertise_a * trial"))
      mod <- lm(form, data = df)
    } else {
      form <- as.formula(paste0(y, " ~ expertise_a * trial + ", rand_effect))
      mod <- lmer(form, data = df)
    }
    models_list[[y]] <- mod
  }

  output_path <- file.path(here(), "output", "R", "workflow","within_group")
  if (!dir.exists(output_path)) {
    dir.create(output_path, recursive = TRUE)
  }

  config <- list(
    results_log   = file.path(output_path, "assumptions.txt"),
    figures_dir   = file.path(output_path, "figures"),
    output_prefix = basename(folder_path)
  )
  
  # Clear previous log if exists
  if (file.exists(config$results_log)) {
    write("", file = config$results_log)
  }
  
  return (list(
    data = df,
    m_list = models_list,
    config = config,
    folder_path = folder_path
  ))
}


#' Generate LMMs for between-group comparisons across trials
#' 
#' @param folder_path The base folder path containing trial subfolders
#' @param case The model type to run ("mean_diff", "pairtype", or "both")
#' @return A list of fitted LMMs for each dimension and other info
between_group <- function(folder_path, case, rand_effect, info){
  # Construct paths
  trial_2_path <- file.path(folder_path, "trial_2")
  trial_5_path <- file.path(folder_path, "trial_5")
  combined_filename <- "combined_data.csv"
  trials <- c(trial_2_path, trial_5_path)

  # Helper function to load one trial's combined CSV and tag trial
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
        trial = factor(trial_num, levels = c("2","5")),
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
  if (info) {
    cat("Rows loaded:", nrow(df), "\n")
    print(table(df$expertise_a))
  }

  # Generate LMMs for each dimension and add them to the list  
  models_list <- list()
  
  # For investigating random effect

  for (y in dimensions) {
    if (case %in% c("mean_diff")) {
      if (str_length(rand_effect) == 0) {
        form_md <- as.formula(paste0(y, " ~ expertise_mean * expertise_diff"))
        mod_md  <- lm(form_md, data = df)
      } else {
        form_md <- as.formula(paste0(y, " ~ expertise_mean * expertise_diff + ", rand_effect))
        mod_md  <- lmer(form_md, data = df)
      }
      models_list[[y]] <- mod_md
    }
    if (case %in% c("pairtype")) {
      if (str_length(rand_effect) == 0) {
        form_pt <- as.formula(paste0(y, " ~ PairType"))
        mod_pt  <- lm(form_pt, data = df)
      } else {
        form_pt <- as.formula(paste0(y, " ~ PairType + ", rand_effect))
        mod_pt  <- lmer(form_pt, data = df)
      }
      models_list[[y]] <- mod_pt
    }
  }

  output_path <- file.path(here(), "output", "R", "workflow", "between_group", case)
  if (!dir.exists(output_path)) {
    dir.create(output_path, recursive = TRUE)
  }

  config <- list(
    results_log   = file.path(output_path, "assumptions.txt"),
    figures_dir   = file.path(output_path, "figures"),
    output_prefix = basename(folder_path)
  )
  
  # Clear previous log if exists
  if (file.exists(config$results_log)) {
    write("", file = config$results_log)
  }
  
  return (list(
    data = df,
    m_list = models_list,
    config = config,
    folder_path = folder_path
  ))
}