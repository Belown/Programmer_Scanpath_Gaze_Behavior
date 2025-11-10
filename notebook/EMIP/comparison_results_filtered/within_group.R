## =========================================
## Linear Mixed-Effects Model for Within-Group Data
## Includes: ExpertiseGroup + Trial (2 vs 5)
## =========================================

# install.packages(c("tidyverse", "lme4", "lmerTest", "broom.mixed"))
library(tidyverse)
library(lme4)
library(lmerTest)
library(broom.mixed)

## -------- 1. Set working directory --------
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("within_group")

## -------- 2. Helper to read one expertise file --------
read_group <- function(folder, level) {
  file_path <- file.path(folder, paste0("Java_", level, "_results.csv"))
  if (!file.exists(file_path)) stop("File not found: ", file_path)
  
  read_csv(file_path, show_col_types = FALSE) %>%
    mutate(
      ExpertiseGroup = factor(level,
                              levels = c("none", "low", "medium", "high"),
                              ordered = TRUE),
      Trial = factor(gsub("trial_", "", folder)),  # extracts 2 or 5 from folder name
      exp_a = factor(exp_a),
      exp_b = factor(exp_b)
    )
}

## -------- 3. Load all within-group data for trial_2 and trial_5 --------
df <- bind_rows(
  read_group("trial_2", "none"),
  read_group("trial_2", "low"),
  read_group("trial_2", "medium"),
  read_group("trial_2", "high"),
  read_group("trial_5", "none"),
  read_group("trial_5", "low"),
  read_group("trial_5", "medium"),
  read_group("trial_5", "high")
)

cat("Rows loaded:", nrow(df), "\n")
print(table(df$ExpertiseGroup, df$Trial))

## =========================================
## 4. LMM: ExpertiseGroup + Trial as fixed effects
## =========================================
## Model: similarity ~ ExpertiseGroup * Trial
## Random: crossed random intercepts for exp_a and exp_b

## ---- Example for Shape similarity ----
m_shape <- lmer(
  Shape ~ ExpertiseGroup * Trial + (1 | exp_a) + (1 | exp_b),
  data = df
)

summary(m_shape)
anova(m_shape)
tidy(m_shape, effects = "fixed")

## =========================================
## 5. Repeat for other MultiMatch dimensions
## =========================================
responses <- c("Length", "Direction", "Position", "Duration")

models <- lapply(responses, function(y) {
  form <- as.formula(paste0(y, " ~ ExpertiseGroup * Trial + (1 | exp_a) + (1 | exp_b)"))
  mod <- lmer(form, data = df)
  cat("\n==== ", y, " ====\n")
  print(tidy(mod, effects = "fixed"))
  invisible(mod)
})

## =========================================
## 6. Optional: visualize effects
## =========================================
# Example plot for Shape similarity
ggplot(df, aes(x = ExpertiseGroup, y = Shape, fill = Trial)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Shape similarity across expertise levels and trials",
       x = "Expertise Group", y = "Shape similarity") +
  theme_minimal(base_size = 13)
