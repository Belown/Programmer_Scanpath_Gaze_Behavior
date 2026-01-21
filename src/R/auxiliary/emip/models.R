# =========================================================
# LMM generation module
# =========================================================
# This module contain functions to generate linear mixed models (LMMs)
# for within-trial, within-group, and between-group comparisons.
# =========================================================

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
#' @param formula_set A list containing fixed and random effect formula strings
#' @param info Whether to print basic info about loaded data
#' @param reml Whether to use REML for LMM fitting
#' @param test Whether to run in test mode (default not used)
#' @return A list of fitted LMMs for each dimension and other info
within_trial <- function(folder_path, formula_set, info, reml = TRUE, test = FALSE, algo) {
  
  if (algo == "MultiMatch") {
    dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")
  } else {
    dimensions <- c("score")
  }
  
  # Construct path to combined CSV
  combined_path <- file.path(folder_path, "combined_data.csv")
  
  fix_effect <- formula_set$fix_effect
  rand_effect <- formula_set$rand_effect
  
  # Read and preprocess data
  # Since for within_trial, all data share the same expertise
  df <- read_csv(combined_path, show_col_types = FALSE) %>%
    mutate(
      expertise_a = factor(expertise_a,
                           levels = c("none", "low", "medium", "high"),
                           # ordered = TRUE),
                          ),
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
  output_path <- assign_path(file.path(here(), "output", "R", "workflow", algo, "EMIP_corrected", "within_trial", combined_path))

  # Construct config for output
  config <- list(
    results_log   = file.path(output_path, "assumptions.txt"),
    figures_dir   = file.path(output_path, "figures"),
    output_prefix = "within_trial"
  )
  
  # Generate LMMs for each dimension and add them to the list
  models_list <- list()
  
  # Construct models based on rand_effect
  for (y in dimensions) {
    if (str_length(rand_effect) == 0) {
      form <- as.formula(paste0(y, " ~ ", fix_effect))
      mod <- lm(form, data = df)
    } else {
      form <- as.formula(paste0(y, " ~ ", fix_effect, " + ", rand_effect))
      mod <- lmer(form, data = df, REML = reml)
    }
    models_list[[y]] <- mod
  }

  # If not in test mode, return full package, otherwise only return models_list
  if (!test) {
    return (list(
      data = df,
      m_list = models_list,
      config = config,
      folder_path = folder_path
    ))
  } else {
    return (models_list)
  }
}

#' Generate LMMs for within-group comparisons across trials
#' 
#' @param folder_path The base folder path containing trial subfolders
#' @param formula_set A list containing fixed and random effect formula strings
#' @param info Whether to print basic info about loaded data
#' @param reml Whether to use REML for LMM fitting
#' @param test Whether to run in test mode (default not used)
#' @return A list of fitted LMMs for each dimension and other info
within_group <- function(folder_path, formula_set, info, reml = TRUE, test = FALSE, algo) {
  
  if (algo == "MultiMatch") {
    dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")
  } else {
    dimensions <- c("score")
  }
  
  fix_effect <- formula_set$fix_effect
  rand_effect <- formula_set$rand_effect
  
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
                             # ordered = TRUE),
                            ),
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
  
  # Construct models based on rand_effect
  for (y in dimensions) {
    if (str_length(rand_effect) == 0) {
      form <- as.formula(paste0(y, " ~ ", fix_effect))
      mod <- lm(form, data = df)
    } else {
      form <- as.formula(paste0(y, " ~ ", fix_effect, " + ", rand_effect))
      mod <- lmer(form, data = df, REML = reml)
    }
    models_list[[y]] <- mod
  }

  output_path <- assign_path(file.path(here(), "output", "R", "workflow", algo, "EMIP_corrected", "within_group"))

  # Construct config for output
  config <- list(
    results_log   = file.path(output_path, "assumptions.txt"),
    figures_dir   = file.path(output_path, "figures"),
    output_prefix = basename(folder_path)
  )
  
  # If not in test mode, return full package, otherwise only return models_list
  if (!test) {
    return (list(
      data = df,
      m_list = models_list,
      config = config,
      folder_path = folder_path
    ))
  } else {
    return (models_list)
  }
}

#' Generate LMMs for between-group comparisons across trials
#' 
#' @param folder_path The base folder path containing trial subfolders
#' @param formula_set A list containing fixed and random effect formula strings
#' @param info Whether to print basic info about loaded data
#' @param case The case for between-group comparison ("mean_diff", "pairtype")
#' @param reml Whether to use REML for LMM fitting
#' @param test Whether to run in test mode (default not used)
#' @return A list of fitted LMMs for each dimension and other info
between_group <- function(folder_path, formula_set, info, case, reml = TRUE, test = FALSE, algo) {
  
  if (algo == "MultiMatch") {
    dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")
  } else {
    dimensions <- c("score")
  }
  
  fix_effect <- formula_set$fix_effect
  rand_effect <- formula_set$rand_effect
  
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
                             # ordered = TRUE),
                            ),
        expertise_b = factor(expertise_b,
                             levels = c("none", "low", "medium", "high"),
                             # ordered = TRUE),
                            ),
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
  
  # Construct models based on the rand_effect and specified case
  for (y in dimensions) {
    if (str_length(rand_effect) == 0) {
      form <- as.formula(paste0(y, " ~ ", fix_effect))
      mod_md  <- lm(form, data = df)
    } else {
      form <- as.formula(paste0(y, " ~ ", fix_effect, " + ", rand_effect))
      mod_md  <- lmer(form, data = df, REML = reml)
    }
    models_list[[y]] <- mod_md
  }

  output_path <- assign_path(file.path(here(), "output", "R", "workflow", algo, "EMIP_corrected", "between_group", case))

  # Construct config for output
  config <- list(
    results_log   = file.path(output_path, "assumptions.txt"),
    figures_dir   = file.path(output_path, "figures"),
    output_prefix = basename(folder_path)
  )
  
  # If not in test mode, return full package, otherwise only return models_list
  if (!test) {
    return (list(
      data = df,
      m_list = models_list,
      config = config,
      folder_path = folder_path
    ))
  } else {
    return (models_list)
  }
}

#' Ensure the specified path exists, creating it if necessary
#' 
#' @param path The directory path to check or create
#' @return The original path
assign_path <- function(path){
  if(!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }
  return (path)
}