library(here)
library(tidyverse)
library(lme4)

source(file.path(here(), "src", "R", "auxiliary", "models.R"))
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))
source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))

combined_path = file.path(here(), "output", "processed_dataset", "EMIP_corrected", 
                        "within_group", "trial_2", "combined_data.csv")
df <- read_csv(combined_path, show_col_types = FALSE) %>%
  mutate(
    expertise_a = factor(expertise_a,
                         levels = c("none", "low", "medium", "high"),
                         ordered = TRUE),
    across(c(exp_a, exp_b), as.factor)
  )
df$Shape <- scale(df$Shape, center = TRUE, scale = TRUE)

model <- lmer(Shape ~ expertise_a + (1 | exp_a) + (1 | exp_b), data = df)

# (colour_plot <- ggplot(df, aes(x = exp_a, y = Shape, colour = expertise_a)) +
#     geom_point(size = 2) +
#     theme_classic()
#     # + theme(legend.position = "none")
#   )
# 
# (split_plot <- ggplot(aes(exp_a, Shape), data = df) + 
#     geom_point() + 
#     facet_wrap(~ expertise_a) + # create a facet for each mountain range
#     xlab("length") + 
#     ylab("test score"))

model_list = list("Shape" = model)

family_list <- setNames(
  replicate(length(names(model_list)), gaussian(), simplify = FALSE),
  names(model_list)
)

glmm_list <- lmm_to_glmm(model_list, family_list)

temp <- glmm_list$Shape
summary(temp)

# summary(model)
# plot(model, which=1)
# plot(model, which=2)

# qqnorm(resid(model))
# qqline(resid(model))