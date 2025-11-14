
library(lme4)

## 1. Create an lmerMod object
m_lmer <- lmer(Reaction ~ Days + (Days | Subject), data = sleepstudy)

## 2. Create a glmerMod object
m_glmer <- glmer(cbind(incidence, size - incidence) ~ period + (1 | herd),
                 data = cbpp, family = binomial)

## 3. Create a non-mixed model (lm)
m_lm <- lm(Sepal.Length ~ Sepal.Width, data = iris)

## Function to test model type
check_model_type <- function(final_model) {
  if (inherits(final_model, "lmerMod")) {
    message("Final model is a linear mixed model (lmerMod).")
  } else if (inherits(final_model, "glmerMod")) {
    message("Final model is a generalized linear mixed model (glmerMod).")
  } else {
    stop("Final model is of unknown type.")
  }
}

## Test all three cases
check_model_type(m_lmer)
check_model_type(m_glmer)
try(check_model_type(m_lm))   # wrapped in try() to prevent stopping the script
