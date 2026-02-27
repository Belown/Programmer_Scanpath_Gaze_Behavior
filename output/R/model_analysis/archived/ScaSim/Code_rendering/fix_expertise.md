# Model Analysis

1. **Random Effects**: Random intercept SDs for exp_a = 0.02167 and exp_b = 0.01784; residual SD = 0.03468. Adjusted ICC = 0.396, meaning that ~40% of the total variance in score is attributable to stable between-participant differences (substantial individual differences).
2. **Nakagawa R²**: Marginal R² = 0.3368; Conditional R² = 0.5993. Rendering explains ~34% of the variance; participant-level random effects account for an additional ~26%.
3. **Post-hoc inference**:
   - render_a
     - r1 > r2 (Δ ≈ +0.0628, p < .0001)
     - r1 > r3 (Δ ≈ +0.0726, p < .0001)
     - r2 > r3 (Δ ≈ +0.00975, p = .0147)
   - render_b
     - r1 ≈ r2 (ns)
     - r1 ≈ r3 (ns)
     - r2 > r3 (Δ ≈ +0.00604, p = .0163; note r3 > r2 in means)
Conclusion: For render_a, r1 yields the highest score, followed by r2, then r3 (all pairwise differences significant). For render_b, scores are largely similar across levels, with only a small difference between r2 and r3. Rendering is a major driver of variance in score, alongside substantial between-participant variability captured by the random effects.
