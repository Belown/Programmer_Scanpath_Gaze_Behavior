# Model Analysis

1. **Random Effects**: Random intercept SDs for exp_a = 0.01026 and exp_b = 0.01176; residual SD = 0.03904. Adjusted ICC = 0.138, meaning that ~14% of the total variance in score is attributable to stable between-participant differences (small-to-moderate individual differences).
2. **Nakagawa R²**: Marginal R² = 0.0105; Conditional R² = 0.1468. Fixed effects (expertise_a and trial) explain ~1% of the variance; participant-level random effects account for an additional ~13%.
3. **Post-hoc inference**:
   - expertise_a
     - none < low (Δ ≈ −0.0137, p = .0303)
     - none < medium (Δ ≈ −0.0154, p = .0060)
     - none ≈ high (ns)
     - low ≈ medium (ns)
     - low ≈ high (ns)
     - medium ≈ high (ns)
   - trial: trial2 < trial5 (Δ ≈ −0.0040, p = .0005)
Conclusion: Participants with no expertise score reliably lower than those with low or medium expertise, but do not differ from the high-expertise group. No reliable differences are observed among low, medium, and high expertise levels. In addition, scores are slightly but significantly higher in trial 5 than in trial 2. There is a small but statistically reliable effect of expertise_a (driven by lower scores in the “none” group) and a small learning or adaptation effect across trials. However, fixed effects contribute negligibly to explained variance, and most systematic variability arises from between-participant differences captured by the random effects.
