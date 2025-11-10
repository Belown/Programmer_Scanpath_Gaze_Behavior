## =========================================
## Linear mixed model for ONE trial (within-group)
## Uses: Java_none/low/medium/high_results.csv
## =========================================

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(lme4)
library(lmerTest)
library(broom.mixed)

## -------- 1. Choose which trial folder to use --------
## Set this to "trial_2"  OR  "trial_5"
trial_folder <- "trial_2"

## -------- 2. Helper function to read one expertise file --------
read_group <- function(folder, level) {
  file_path <- file.path(folder, paste0("Java_", level, "_results.csv"))
  if (!file.exists(file_path)) {
    stop("File not found: ", file_path)
  }
  
  read_csv(file_path, show_col_types = FALSE) %>%
    mutate(
      ExpertiseGroup = factor(
        level,
        levels = c("none", "low", "medium", "high"),
        ordered = TRUE
      ),
      exp_a = factor(exp_a),
      exp_b = factor(exp_b)
    )
}

## -------- 3. Load all within-group data for this trial --------
df <- bind_rows(
  read_group(trial_folder, "none"),
  read_group(trial_folder, "low"),
  read_group(trial_folder, "medium"),
  read_group(trial_folder, "high")
)

cat("Rows loaded:", nrow(df), "\n")
print(table(df$ExpertiseGroup))

## =========================================
## 4. LMM: Effect of expertise on similarity
## =========================================
## Model: similarity ~ ExpertiseGroup
## Random: crossed random intercepts for exp_a and exp_b

## ---- For Shape similarity ----
m_shape <- lmer(
  Shape ~ ExpertiseGroup + 
    (1 | exp_a) + (1 | exp_b),
  data = df
)

summary(m_shape)
anova(m_shape)
tidy(m_shape, effects = "fixed")

## ---- Run the same for other dimensions ----
responses <- c("Length", "Direction", "Position", "Duration")

models <- lapply(responses, function(y) {
  form <- as.formula(paste0(y, " ~ ExpertiseGroup + (1 | exp_a) + (1 | exp_b)"))
  mod <- lmer(form, data = df)
  cat("\n==== ", y, " ====\n")
  print(tidy(mod, effects = "fixed"))
  invisible(mod)
})

## =========================================
## 5. Visualizations
## =========================================

## ---- 5.1 Boxplot for Shape by ExpertiseGroup ----
ggplot(df, aes(x = ExpertiseGroup, y = Shape)) +
  geom_boxplot(outlier.alpha = 0.2) +
  labs(
    title = paste0("Shape similarity by expertise (", trial_folder, ")"),
    x = "Expertise group",
    y = "Shape similarity"
  ) +
  theme_minimal(base_size = 13)

## ---- 5.2 Boxplots for all dimensions (facetted) ----
df_long <- df %>%
  pivot_longer(
    cols = c(Shape, Length, Direction, Position, Duration),
    names_to = "Dimension",
    values_to = "Similarity"
  )

ggplot(df_long, aes(x = ExpertiseGroup, y = Similarity)) +
  geom_boxplot(outlier.alpha = 0.15) +
  facet_wrap(~ Dimension, scales = "free_y") +
  labs(
    title = paste0("MultiMatch similarity by expertise (", trial_folder, ")"),
    x = "Expertise group",
    y = "Similarity"
  ) +
  theme_minimal(base_size = 13)

## ---- 5.3 Mean + 95% CI for each dimension ----
summary_means <- df_long %>%
  group_by(ExpertiseGroup, Dimension) %>%
  summarise(
    mean = mean(Similarity, na.rm = TRUE),
    se   = sd(Similarity, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(
    lower = mean - 1.96 * se,
    upper = mean + 1.96 * se
  )

ggplot(summary_means, aes(x = ExpertiseGroup, y = mean, group = Dimension, color = Dimension)) +
  geom_point(position = position_dodge(width = 0.3)) +
  geom_errorbar(aes(ymin = lower, ymax = upper),
                width = 0.1,
                position = position_dodge(width = 0.3)) +
  facet_wrap(~ Dimension, scales = "free_y") +
  labs(
    title = paste0("Mean similarity ± 95% CI by expertise (", trial_folder, ")"),
    x = "Expertise group",
    y = "Mean similarity"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")
