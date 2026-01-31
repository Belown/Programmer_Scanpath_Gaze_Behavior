# =========================================================
# Helper function module
# =========================================================

source(file.path(here(), "src", "R", "auxiliary", "emip", "models.R"))

#' Get the model package based on experiment type and data set
#' 
#' @param exp_type The type of experiment ("within_stimulus", "within_group", "between_group")
#' @param data_set The name of the data set
#' @param comp_type The comparison type ("between_group" or "within_group")
#' @param stimulus_folder The stimulus folder name ("rectangle", "vehicle")
#' @param case The case for between-group comparison ("mean_diff", "pairtype")
#' @param formula_set A list containing fixed and random effect formula strings
#' @param info Whether to print info messages
#' @return A model package, which contain data frame, models, config, and folder_path
get_exp_pack <- function(data_set, exp_type, comp_type, stimulus_folder, case, rand_effect = NULL, info = TRUE, reml, algo) {
  base_path <- file.path(here(), "output", "processed_dataset", algo)
  model_pack <- switch(
    exp_type,
    "within_stimulus" = {
      default_rand_effect <- "(1 | exp_a) + (1 | exp_b)"
        # If rand_effect exists, use it, otherwise, use default
      formula_set <- list(
        fix_effect = "expertise_a",
        rand_effect = if (!is.null(rand_effect)) rand_effect else default_rand_effect)
      folder_path <- file.path(base_path, data_set, comp_type, stimulus_folder)
      within_stimulus(folder_path, formula_set, info, reml, algo = algo)
    },
    "within_group" = {
      default_rand_effect <- "(1 | exp_a) + (1 | exp_b)"
      # If rand_effect exists, use it, otherwise, use default
      formula_set <- list(
        fix_effect = "expertise_a * stimulus",
        rand_effect = if (!is.null(rand_effect)) rand_effect else default_rand_effect)
      folder_path <- file.path(base_path, data_set, "within_group")
      within_group(folder_path, formula_set, info, reml, algo = algo)
    },
    "between_group" = {
      default_rand_effect <- "(1 | exp_a) + (1 | exp_b)"
      # If rand_effect exists, use it, otherwise, use default
      formula_set <- switch(
        case,
        "mean_diff" = list(
          fix_effect = "expertise_mean * expertise_diff",
          rand_effect = if (!is.null(rand_effect)) rand_effect else default_rand_effect
        ),
        "pairtype" = list(
          fix_effect = "PairType",
          rand_effect = if (!is.null(rand_effect)) rand_effect else default_rand_effect
        )
      )
      folder_path <- file.path(base_path, data_set, "between_group")
      between_group(folder_path, formula_set, info, case, reml, algo = algo)
    }
  )
  return (model_pack)
}


#' Print model summary with significance stars
#' 
#' @param mod Fitted model (lmerMod or glmmTMB)
#' @param dimension_name Name of the dimension for display
print_model_with_sig <- function(mod, dimension_name) {
  cat("\n====", dimension_name, "====\n")
  cat("Formula:", deparse(formula(mod)), "\n")
  
  # Case distinction 
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
        stars = if ("p.value" %in% names(.)) {
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
  txt_path <- assign_path(file.path(folder_path))

  sink_file <- file.path(txt_path, "model_summary.txt")
  sink(sink_file, split = TRUE)
  tryCatch({
    for (dim in names(final_result)) {
      print_model_with_sig(final_result[[dim]], dim)
    }
  }, finally = {
    sink()  # Ensure sink is closed even if an error occurs
  })
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