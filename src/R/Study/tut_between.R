library(here)
library(tidyverse)

folder_path = file.path(here(), "output", "processed_dataset", "EMIP_corrected", 
                      "between_group")

dimensions <- c("Shape", "Direction", "Length", "Position", "Duration")

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
cat("Rows loaded:", nrow(df), "\n")
print(table(df$expertise_a))

boxplot(Shape ~ expertise_mean, data = df)  # certainly looks like something is going on here

(colour_plot <- ggplot(df, aes(x = expertise_mean, y = Shape, colour = expertise_diff)) +
    geom_point(size = 2) +
    theme_classic() +
    theme(legend.position = "none"))

(split_plot <- ggplot(aes(expertise_mean, Shape), data = df) + 
    geom_point() + 
    facet_wrap(~ expertise_diff) + # create a facet for each mountain range
    xlab("expertise_a") + 
    ylab("Shape"))
