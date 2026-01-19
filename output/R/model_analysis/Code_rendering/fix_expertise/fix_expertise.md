# Dimensions

## Shape

1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.00103; residual SD = 0.00244.
   Adjusted ICC = 0.263, meaning that ~26% of the total variance in Shape similarity is attributable to stable between-participant differences (substential individual differences).
2. **Nakagawa R²**: Marginal R² = 0.166; Conditional R² = 0.385. Rendering explains ~17% of variance; participant-level random effects account for an additional ~22%.
3. **Post-hoc inference**:
   - r1 < r2 (Δ ≈ −0.00193, p < .0001)
   - r1 < r3 (Δ ≈ −0.00182, p < .0001)
   - r2 ≈ r3 (ns)
    Effects are symmetric for render_a and render_b.
    Conclusion: r1 yields significantly lower shape similarity than r2 and r3.

## Length

1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.00145; residual SD = 0.00316. Adjusted ICC = 0.296, indicating that ~30% of variance reflects stable between-participant differences.
2. **Nakagawa R²**: Marginal R² = 0.156; Conditional R² = 0.406. Rendering explains ~16% of variance; participant-level effects contribute an additional ~25%.
3. **Post-hoc inference**:
   - r1 < r2 (Δ ≈ −0.00255, p < .0001)
   - r1 < r3 (Δ ≈ −0.00221, p < .0001)
   - r2 ≈ r3 (marginal, p = .059)
    Symmetric for render_a and render_b.
    Conclusion: Length similarity is significantly lower for r1 than for r2 and r3.

## Direction

1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.02356; residual SD = 0.04447. Adjusted ICC = 0.360, meaning ~36% of variance is attributable to stable participant-level effects.
2. **Nakagawa R²**: Marginal R² = 0.196; Conditional R² = 0.485. Rendering explains ~20% of variance; participant-level random effects add ~29%.
3. **Post-hoc inference**:
   - r1 < r2 (Δ ≈ −0.0449, p < .0001)
   - r1 < r3 (Δ ≈ −0.0349, p < .0001)
   - r2 > r3 (Δ ≈ 0.00998, p < .0001)
    Symmetric for render_a and render_b.
    Conclusion: All three rendering methods differ significantly for Direction similarity, with r2 highest and r1 lowest.

## Position

1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.00905; residual SD = 0.03223. Adjusted ICC = 0.136, indicating modest but non-negligible participant-level variance.
2. **Nakagawa R²**: Marginal R² = 0.148; Conditional R² = 0.264. Rendering explains ~15% of variance; participant-level effects add ~12%.
3. **Post-hoc inference**:
   - r1 < r2 (Δ ≈ −0.01828, p < .0001)
   - r1 < r3 (Δ ≈ −0.01809, p < .0001)
   - r2 ≈ r3 (ns)
    Symmetric for render_a and render_b.
    Conclusion: Position similarity is substantially lower for r1 than for r2 and r3.

## Duration

1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both ≈ 0.01412; residual SD = 0.03339. Adjusted ICC = 0.263, meaning ~26% of variance is attributable to stable participant-specific effects.
2. **Nakagawa R²**: Marginal R² = 0.038; Conditional R² = 0.291. Rendering explains very little variance; participant-level random effects dominate.
3. **Post-hoc inference**:
   - r1 ≈ r2 (ns)
   - r1 > r3 (Δ ≈ 0.00943, p < .0001)
   - r2 > r3 (Δ ≈ 0.01156, p < .0001)
    Symmetric for render_a and render_b.
    Conclusion: Duration similarity is significantly lower for r3 than for r1 and r2.

## Summary (Corrected Interpretation)

- Participant identity is a major driver of scanpath similarity. With ICCs between 0.136 and 0.360, roughly 14–36% of variance across MultiMatch dimensions is explained by stable, participant-specific gaze behavior.
- Rendering method has robust effects on Shape, Length, Direction, and Position similarity, with r1 consistently producing the lowest similarity and r2/r3 the highest.
- Directpion is the most sensitive dimension to rendering differences: all three methods differ significantly.
- Duration is weakly exlained by rendering (Marginal R² ≈ 0.04); similarity here is dominated by participant-specific and residual variability.
- The (1 | exp_a) + (1 | exp_b) structure is methodologically appropriate for scanpath-pair data: it correctly accounts for the non-independence introduced by reusing the same participant in multiple scanpath comparisons.
