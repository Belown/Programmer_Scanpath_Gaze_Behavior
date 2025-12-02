library(here)
library(tidyverse)

folder_path = file.path(here(), "output", "processed_dataset", "EMIP_corrected", 
                        "within_group")

dimensions <- c("Shape", "Direction", "Length", "Position", "Duration")

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
cat("Rows loaded:", nrow(df), "\n")
print(table(df$expertise_a))

boxplot(Shape ~ expertise_a, data = df)  # certainly looks like something is going on here

(colour_plot <- ggplot(df, aes(x = expertise_a, y = Shape, colour = trial)) +
    geom_point(size = 2) +
    theme_classic() +
    theme(legend.position = "none"))

(split_plot <- ggplot(aes(expertise_a, Shape), data = df) + 
    geom_point() + 
    facet_wrap(~ trial) + # create a facet for each mountain range
    xlab("expertise_a") + 
    ylab("Shape"))