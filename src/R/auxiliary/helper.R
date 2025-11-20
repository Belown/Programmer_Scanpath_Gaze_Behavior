# =========================================================
# Helper function module
# =========================================================
# Helper functions that make the main code cleaner
# =========================================================

source(file.path(here(), "src", "R", "auxiliary", "models.R"))

base_path <- file.path(here(), "output", "processed_dataset")

#' Get the model package based on experiment type and data set
#' 
#' @param exp_type The type of experiment ("within_trial", "within_group", "between_group)
#' @param data_set The name of the data set
#' @param comp_type The comparison type ("between_group" or "within_group")
#' @param trial_folder The trial folder name ("trial_2", "trial_5")
#' @return A model package, which contain data frame, models, config, and folder_path
get_model_pack <- function(exp_type, data_set, comp_type, trial_folder, case, random_effect, info = TRUE) {
  model_pack <- switch(
    exp_type,
    "within_trial" = {
      folder_path <- file.path(base_path, data_set, comp_type,trial_folder)
      within_trial_pack <- within_trial(folder_path, random_effect, info)
    },
    "within_group" = {
      folder_path <- file.path(base_path, data_set, "within_group")
      within_group_pack <- within_group(folder_path, random_effect, info)
    },
    "between_group" = {
      folder_path <- file.path(base_path, data_set, "between_group")
      between_group_pack <- between_group(folder_path, case, random_effect, info)
    }
  )
  return (model_pack)
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

#' Print model summaries with significance annotations to a text file
#' 
#' @param folder_path The folder path where the output file will be saved
#' @param final_result A list of final fitted models for each dimension
print_model_table <- function(folder_path, final_result) {
  sink_file <- file.path(folder_path, "model_summary.txt")
  sink(sink_file, split = TRUE)
  tryCatch({
    for (dim in names(final_result)) {
      print_model_with_sig(final_result[[dim]], dim)
    }
  }, finally = {
    sink()  # Ensure sink is closed even if an error occurs
  })
}