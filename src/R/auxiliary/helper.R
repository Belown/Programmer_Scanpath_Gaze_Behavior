# =========================================================
# Helper function module
# =========================================================
# Helper functions that make the main code cleaner
# =========================================================

#' Get the model package based on experiment type and data set
#' 
#' @param exp_type The type of experiment ("within_trial", "within_group", "between_group)
#' @param data_set The name of the data set
#' @param comp_type The comparison type ("between_group" or "within_group")
#' @param trial_folder The trial folder name ("trial_2", "trial_5")
#' @return A model package, which contain data frame, models, config, and folder_path
get_model_pack <- function (exp_type, data_set, comp_type, trial_folder) {
  model_pack <- switch(
    exp_type,
    "within_trial" = {
      folder_path <- file.path(base_path, data_set, comp_type,trial_folder)
      within_trial_pack <- within_trial(folder_path)
    },
    "within_group" = {
      folder_path <- file.path(base_path, data_set, "within_group")
      within_group_pack <- within_group(folder_path)
    },
    "between_group" = {
      folder_path <- file.path(base_path, data_set, "between_group")
      between_group_pack <- between_group(folder_path, "both")
    }
  )
  return (model_pack)
}


#' Print model summaries with significance annotations to a text file
#' 
#' @param folder_path The folder path where the output file will be saved
#' @param final_result A list of final fitted models for each dimension
print_model_table <- function (folder_path, final_result) {
  sink_file <- file.path(folder_path, "model_summaries.txt")
  sink(sink_file, split = TRUE)
  tryCatch({
    for (dim in dimensions) {
      print_model_with_sig(final_result[[dim]], dim)
    }
  }, finally = {
    sink()  # Ensure sink is closed even if an error occurs
  })
  cat("All model summaries saved to:", sink_file, "\n")
}