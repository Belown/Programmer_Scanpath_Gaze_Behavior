# Set up constant variables
dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")


within_group <- function(folder_path, formula_set, info, reml = TRUE, test = FALSE, dataset) {
  
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
                           ordered = TRUE),
      expertise_b = factor(expertise_b,
                           levels = c("Beginner", "Intermediate"),
                           ordered = TRUE),
      render_a = factor(render_a),
      render_b = factor(render_b)
    )
  
  # Provide basic info about loaded data
  if (info) {
    cat("Rows loaded:", nrow(df), "\n")
    print(table(df$expertise_a))
    print(table(df$expertise_b))
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
  
  output_path <- assign_path(file.path(here(), "output", "R", "workflow",dataset, "within_group"))
  
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