library(here)

# Load auxiliary functions for model building and validation workflow
source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))

# --- Experiment Type Configuration ---
dataset <- "code_rendering"  # Dataset identifier

exp_type <- "fix_expertise"

case <- NULL

base_path <- file.path(here(), "output", "processed_dataset")
folder_path <- file.path(base_path, dataset, exp_type)

formula_set <- list(
  fix_effect = "expertise_a * rendering_pair",
  rand_effect = "(1 | exp_a) + (1 | exp_b)"
)

dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")

fix_effect <- formula_set$fix_effect
rand_effect <- formula_set$rand_effect
  
# Construct paths
filename <- "combined_data.csv"
file <- file.path(folder_path, filename)
  
if (!file.exists(file)) stop("File not found: ", file)
  
# Read and preprocess data
df <- read_csv(file, show_col_types = FALSE) %>%
  mutate(
    # Use the expertise column from your combined file
    exp_a = factor(exp_a),
    exp_b = factor(exp_b),
    expertise_a = factor(expertise_a,
                         levels = c("Beginner", "Intermediate"),
                         # ordered = TRUE),
                        ),
    expertise_b = factor(expertise_b,
                         levels = c("Beginner", "Intermediate"),
                         # ordered = TRUE),
                        ),
    render_a = factor(render_a),
    render_b = factor(render_b),
    rendering_pair = factor(paste0(
      pmin(as.character(render_a), as.character(render_b)), 
      "_", 
      pmax(as.character(render_a), as.character(render_b))
    ))
  )

# Provide basic info about loaded data
cat("Rows loaded:", nrow(df), "\n")
print(table(df$expertise_a))
print(table(df$expertise_b))

  
# Generate LMMs for each dimension and add them to the list
models_list <- list()
  
reml=TRUE

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


output_path <- assign_path(file.path(here(), "output", "R", "workflow",dataset, "fix_expertise_study_render"))


# Construct config for output
config <- list(
  results_log   = file.path(output_path, "assumptions.txt"),
  figures_dir   = file.path(output_path, "figures"),
  output_prefix = basename(folder_path)
)
  
# If not in test mode, return full package, otherwise only return models_list
exp_pack <- (list(
    data = df,
    m_list = models_list,
    config = config,
    folder_path = folder_path
  ))


# Extract components from model package
folder_path <- exp_pack$folder_path  # Output folder path
dataframe <- exp_pack$data           # Processed dataset

temp <- exp_pack$m_list$Shape
print(summary(temp))

# Run workflow to validate model assumptions and obtain final models
# Output is saved to: output/workflow/[experiment_path]/model_summary.txt
final_result <- work_flow_with_print(exp_pack$m_list, exp_pack$config)