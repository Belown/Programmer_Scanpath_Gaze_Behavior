## =========================================
## Linear Mixed-Effects Model for Within-Group Data
## Includes: ExpertiseGroup + Trial (2 vs 5)
## =========================================

## ---- 0. Setup ----
# install.packages(c("tidyverse", "lme4", "lmerTest", "broom.mixed"))
library(tidyverse)
library(lme4)
library(lmerTest)
library(broom.mixed)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("within_group")

## =========================================
## 1. Load data
## =========================================

## ---- 1.1 Helper: read one expertise level from one trial ----
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
      # extract "2" or "5" from "trial_2"/"trial_5"
      Trial = factor(gsub("trial_", "", folder)),
      exp_a = factor(exp_a),
      exp_b = factor(exp_b)
    )
}

## ---- 1.2 Load all groups for trial_2 and trial_5 ----
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
## 2. LMM: ExpertiseGroup * Trial
## =========================================
## Model: SimilarityDimension ~ ExpertiseGroup * Trial
## Random: crossed random intercepts for exp_a and exp_b

## ---- 2.1 Helper: pretty-print fixed effects with significance stars ----
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

## ---- 2.2 Detailed model for Shape ----
m_shape <- lmer(
  Shape ~ ExpertiseGroup * Trial + (1 | exp_a) + (1 | exp_b),
  data = df
)

summary(m_shape)
anova(m_shape)
print_model_with_sig(m_shape, "Shape")

## =========================================
## 3. LMM for all MultiMatch dimensions
## =========================================

## ---- 3.1 Fit and print models for each dimension ----
responses <- c("Shape", "Length", "Direction", "Position", "Duration")

models <- lapply(responses, function(y) {
  form <- as.formula(
    paste0(y, " ~ ExpertiseGroup * Trial + (1 | exp_a) + (1 | exp_b)")
  )
  mod <- lmer(form, data = df)
  print_model_with_sig(mod, y)
  invisible(mod)
})

## =========================================
## 4. Visualizations
## =========================================

## ---- 4.1 Boxplot: Shape by ExpertiseGroup and Trial ----
ggplot(df, aes(x = ExpertiseGroup, y = Shape, fill = Trial)) +
  geom_boxplot(alpha = 0.7) +
  labs(
    title = "Shape similarity across expertise levels and trials",
    x = "Expertise group",
    y = "Shape similarity"
  ) +
  theme_minimal(base_size = 13)

## ---- 4.2 Boxplots: All dimensions (faceted), by Trial ----
df_long <- df %>%
  pivot_longer(
    cols = c(Shape, Length, Direction, Position, Duration),
    names_to = "Dimension",
    values_to = "Similarity"
  )

ggplot(df_long, aes(x = ExpertiseGroup, y = Similarity, fill = Trial)) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.15) +
  facet_wrap(~ Dimension, scales = "free_y") +
  labs(
    title = "MultiMatch similarity by expertise and trial",
    x = "Expertise group",
    y = "Similarity"
  ) +
  theme_minimal(base_size = 13)

## ---- 4.3 Mean ± 95% CI by ExpertiseGroup, Trial, and Dimension ----
summary_means <- df_long %>%
  group_by(ExpertiseGroup, Trial, Dimension) %>%
  summarise(
    mean = mean(Similarity, na.rm = TRUE),
    se   = sd(Similarity, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(
    lower = mean - 1.96 * se,
    upper = mean + 1.96 * se
  )

ggplot(summary_means,
       aes(x = ExpertiseGroup, y = mean,
           group = Trial, color = Trial)) +
  geom_point(position = position_dodge(width = 0.3)) +
  geom_errorbar(
    aes(ymin = lower, ymax = upper),
    width = 0.1,
    position = position_dodge(width = 0.3)
  ) +
  facet_wrap(~ Dimension, scales = "free_y") +
  labs(
    title = "Mean similarity ± 95% CI by expertise and trial",
    x = "Expertise group",
    y = "Mean similarity"
  ) +
  theme_minimal(base_size = 13)
