# Model Analysis

1. **Random Effects**: Random intercept SDs for exp_a = 0.01847 and exp_b = 0.02078; residual SD = 0.03624. Adjusted ICC = 0.371, meaning that ~37% of the total variance in score is attributable to stable between-participant differences (substantial individual differences).
2. **Nakagawa R²**: Marginal R² = 0.0113; Conditional R² = 0.3777. Fixed effects (expertise_a, trial, and their interaction) explain ~1.1% of the variance; participant-level random effects account for an additional ~37%.
3. **Post-hoc inference**:
   - expertise_a
     - none ≈ low (Δ ≈ −0.00429, p = .9490)
     - none ≈ medium (Δ ≈ −0.01219, p = .3641)
     - none ≈ high (Δ ≈ −0.00741, p = .9254)
     - low ≈ medium (ns)
     - low ≈ high (ns)
     - medium ≈ high (ns)
   - trial: trial2 > trial5 (Δ ≈ +0.0116, p < .0001)
Conclusion: There are no reliable differences among expertise levels. Scores are, however, significantly higher in trial 2 than in trial 5, indicating a small but robust trial-related change. There is no evidence for an effect of expertise_a on score, but there is a clear effect of trial. Fixed effects contribute negligibly to explained variance, and most systematic variability arises from between-participant differences captured by the random effects rather than from expertise or trial effects.
