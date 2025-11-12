## =========================================
## 3b. Build symmetric PairType (Option A only)
## =========================================

df <- df %>%
  mutate(
    # make it symmetric: sort the two expertise labels within each pair
    Exp_min = if_else(
      as.numeric(ExpertiseA) <= as.numeric(ExpertiseB),
      as.character(ExpertiseA),
      as.character(ExpertiseB)
    ),
    Exp_max = if_else(
      as.numeric(ExpertiseA) <= as.numeric(ExpertiseB),
      as.character(ExpertiseB),
      as.character(ExpertiseA)
    ),
    
    PairType = paste0(Exp_min, "_", Exp_max),
    PairType = factor(PairType)
  )

cat("PairType counts:\n")
print(table(df$PairType))

## (Optional) choose a reference level for interpretation
## e.g., use "none_low" as baseline if present
if ("none_low" %in% levels(df$PairType)) {
  df$PairType <- relevel(df$PairType, ref = "none_low")
}

## =========================================
## 4. Helper: pretty-print fixed effects (unchanged)
## =========================================

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

cat("Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n")

## =========================================
## 5. Run the categorical PairType model for each dimension
##    Model: y ~ PairType + (1 | exp_a) + (1 | exp_b)
## =========================================

responses <- c("Shape", "Length", "Direction", "Position", "Duration")

models <- lapply(responses, function(y) {
  form <- as.formula(paste0(
    y,
    " ~ PairType + (1 | exp_a) + (1 | exp_b)"
  ))
  
  mod <- lmer(form, data = df)
  print_model_with_sig(mod, y)
  invisible(mod)
})

xtabs(~ ExpertiseA + ExpertiseB, df)
