## =========================================
## Linear mixed model for ONE trial (within-group)
## Uses: Java_none/low/medium/high_results.csv
## =========================================

## ---- 0. Setup ----
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(lme4)
library(lmerTest)
library(broom.mixed)

## =========================================
## 1. Choose trial folder
## =========================================

## ---- 1.1 Select trial ----
## Set this to "trial_2" OR "trial_5"
trial_folder <- "trial_5"

## =========================================
## 2. Load data
## =========================================

## ---- 2.1 Helper to read one expertise level ----
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

## ---- 2.2 Load all groups for selected trial ----
df <- bind_rows(
  read_group(trial_folder, "none"),
  read_group(trial_folder, "low"),
  read_group(trial_folder, "medium"),
  read_group(trial_folder, "high")
)

cat("Rows loaded:", nrow(df), "\n")
print(table(df$ExpertiseGroup))

## =========================================
## 3. LMM: Effect of expertise on similarity
## =========================================
## Model: SimilarityDimension ~ ExpertiseGroup
## Random: crossed random intercepts for exp_a and exp_b

## ---- 3.1 Helper: pretty-print fixed effects with significance stars ----
print_model_with_sig <- function(mod, response_name) {
  cat("\n====", response_name, "====\n")
  
  tidy(mod, effects = "fixed") %>%
    mutate(
      signif = case_when(
        p.value < 0.001 ~ "***",
        p.value < 0.01  ~ "**",
        p.value < 0.05  ~ "*",
        p.value < 0.1   ~ ".",
        TRUE            ~ ""
      ),
      term = if_else(
        term == "(Intercept)",
        "(Intercept)",
        paste0(term, " ", signif)
      )
    ) %>%
    select(effect, term, estimate, std.error, statistic, df, p.value, signif) %>%
    print(n = Inf)
}

## ---- 3.2 Detailed output for Shape ----
m_shape <- lmer(
  Shape ~ ExpertiseGroup +
    (1 | exp_a) + (1 | exp_b),
  data = df
)

summary(m_shape)
anova(m_shape)
print_model_with_sig(m_shape, "Shape")

## ---- 3.3 Run same model for all dimensions ----
print("Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1")

responses <- c("Shape", "Length", "Direction", "Position", "Duration")

models <- lapply(responses, function(y) {
  form <- as.formula(paste0(y, " ~ ExpertiseGroup + (1 | exp_a) + (1 | exp_b)"))
  mod <- lmer(form, data = df)
  print_model_with_sig(mod, y)
  invisible(mod)
})

## =========================================
## 4. Visualizations
## =========================================

## ---- 4.1 Boxplot: Shape by ExpertiseGroup ----
ggplot(df, aes(x = ExpertiseGroup, y = Shape)) +
  geom_boxplot(outlier.alpha = 0.2) +
  labs(
    title = paste0("Shape similarity by expertise (", trial_folder, ")"),
    x = "Expertise group",
    y = "Shape similarity"
  ) +
  theme_minimal(base_size = 13)

## ---- 4.2 Boxplots: All dimensions (faceted) ----
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

## ---- 4.3 Means + 95% CI for each dimension ----
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
  geom_errorbar(
    aes(ymin = lower, ymax = upper),
    width = 0.1,
    position = position_dodge(width = 0.3)
  ) +
  facet_wrap(~ Dimension, scales = "free_y") +
  labs(
    title = paste0("Mean similarity ± 95% CI by expertise (", trial_folder, ")"),
    x = "Expertise group",
    y = "Mean similarity"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")
