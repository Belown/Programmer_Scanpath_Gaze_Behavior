model_analysis <- function(model, dimension, path, adjust = "tukey") {
  
  # 0) Structure checks
  sing <- if (inherits(model, "glmmTMB")) {
    vc <- glmmTMB::VarCorr(model)
    any(sapply(vc$cond, function(x) any(diag(x) < 1e-4)))
  } else {
    lme4::isSingular(model)
  }
  
  vc <- if (inherits(model, "glmmTMB")) {
    glmmTMB::VarCorr(model)
  } else {
    lme4::VarCorr(model)
  }
  
  cat("\nRandom-effects (VarCorr):")
  print(vc)
  
  library(performance)
  icc_val <- performance::icc(model, tolerance = 1e-10)
  print(icc_val)
  
  fixed_terms <- attr(stats::terms(model), "term.labels")
  cat("\n--- Fixed-effect terms (as in formula) ---\n")
  print(fixed_terms)
  
  interaction_terms <- fixed_terms[grepl(":", fixed_terms)]
  has_interaction <- length(interaction_terms) > 0
  main_terms <- fixed_terms[!grepl(":", fixed_terms)]
  
  cat("\nHas interaction terms:", has_interaction, "\n")
  cat("Main terms:", paste(main_terms, collapse = ", "), "\n")
  if (has_interaction) cat("Interaction terms:", paste(interaction_terms, collapse = ", "), "\n")
  
  # 1) Nakagawa R²
  cat("\n--- Nakagawa R² ---\n")
  r2_full <- tryCatch(performance::r2_nakagawa(model), error = function(e) e)
  
  r2_marg <- r2_cond <- NA_real_
  if (inherits(r2_full, "error")) {
    cat("r2_nakagawa() failed:\n  ", conditionMessage(r2_full), "\n")
  } else {
    r2_df <- as.data.frame(r2_full)
    r2_marg <- r2_df[["R2_marginal"]][1]
    r2_cond <- r2_df[["R2_conditional"]][1]
    cat("Marginal R² (fixed effects):    ", round(r2_marg, 4), "\n")
    cat("Conditional R² (fixed+random):  ", round(r2_cond, 4), "\n")
  }
  
  # 2) Post-hoc for factors
  cat("\n--- Post-hoc inference (emmeans for categorical predictors) ---\n")
  mf <- stats::model.frame(model)
  
  factor_terms <- main_terms[
    main_terms %in% names(mf) &
      vapply(main_terms, function(t) is.factor(mf[[t]]) || is.character(mf[[t]]), logical(1))
  ]
  
  if (length(factor_terms) == 0) {
    cat("No categorical fixed effects found (all are numeric).\n")
    cat("Using summary(model) for slope estimates.\n\n")
    print(summary(model))
  } else {
    for (term in factor_terms) {
      cat(sprintf("\nEMMs for %s:\n", term))
      emm_term <- emmeans::emmeans(model, as.formula(paste("~", term)))
      print(emm_term)
      
      cat(sprintf("\nPairwise comparisons for %s (%s adjustment):\n", term, adjust))
      print(emmeans::contrast(emm_term, method = "pairwise", adjust = adjust))
    }
  }
  
  invisible(list(
    singular = sing,
    varcorr = vc,
    fixed_terms = fixed_terms,
    main_terms = main_terms,
    interaction_terms = interaction_terms,
    r2_marginal = r2_marg,
    r2_conditional = r2_cond,
    model_frame = mf
  ))
}
