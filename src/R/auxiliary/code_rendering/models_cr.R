
get_model_pack <- function(folder_path, formula_set, info, reml = TRUE, test = FALSE, data_set, case = NULL, algo) {
  
  if (algo == "MultiMatch") {
    dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")
  } else {
    dimensions <- c("score")
  }
  
  fix_effect <- formula_set$fix_effect
  rand_effect <- formula_set$rand_effect
  
  # Construct paths
  filename <- "combined_data.csv"
  file <- file.path(folder_path, filename)

  exp_name <- basename(folder_path)
  
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
      render_b = factor(render_b)
    )
  
  df$expertise_a_num <- as.integer(df$expertise_a)
  df$expertise_b_num <- as.integer(df$expertise_b)

  # Expertise Mean
  df$expertise_mean <- (df$expertise_a_num + df$expertise_b_num) / 2
  # Expertise Difference
  df$expertise_diff <- abs(df$expertise_a_num - df$expertise_b_num)

  df$dyad <- factor(paste0(
    pmin(as.numeric(as.character(df$exp_a)), 
         as.numeric(as.character(df$exp_b))), 
    "_", 
    pmax(as.numeric(as.character(df$exp_a)), 
         as.numeric(as.character(df$exp_b)))
  ))

  # Construct PairType
  df$PairType <- case_when(
    df$expertise_a == "Beginner" & df$expertise_b == "Beginner" ~ "BB",
    df$expertise_a == "Beginner" & df$expertise_b == "Intermediate" ~ "BI",
    df$expertise_a == "Intermediate" & df$expertise_b == "Beginner" ~ "BI",
    df$expertise_a == "Intermediate" & df$expertise_b == "Intermediate" ~ "II"
  )
  
  df$Rendering_Pair <- case_when(
    df$render_a == "r1" & df$render_b == "r1" ~ "r1_r1",
    df$render_a == "r1" & df$render_b == "r2" ~ "r1_r2",
    df$render_a == "r1" & df$render_b == "r3" ~ "r1_r3",
    df$render_a == "r2" & df$render_b == "r2" ~ "r2_r2",
    df$render_a == "r2" & df$render_b == "r3" ~ "r2_r3",
    df$render_a == "r3" & df$render_b == "r3" ~ "r3_r3"
  )
  
  # Convert PairType to factor for modeling
  df$PairType <- factor(df$PairType, levels = c("BB", "BI", "II"))
  
  df$Rendering_Pair <- factor(df$Rendering_Pair, levels = c("r1_r1", "r1_r2", 
                                                            "r1_r3", "r2_r2", 
                                                            "r2_r3", "r3_r3"))

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
  
  if (!is.null(case) && exp_name=="fix_rendering") {
    output_path <- assign_path(file.path(here(), "output", "R", "workflow", algo, data_set, exp_name, case))
  } else {
    output_path <- assign_path(file.path(here(), "output", "R", "workflow", algo, data_set, exp_name))
  }
  
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