# Model Analysis

1. **Random Effects**: Random intercept SDs for exp_a = 0.03478 and exp_b = 0.02070; residual SD = 0.06711.
Adjusted ICC = 0.267, meaning that ~27% of the total variance in score is attributable to stable between-participant differences (substantial individual differences).
2. **Nakagawa R²**: Marginal R² = 0.350; Conditional R² = 0.524. Rendering explains ~35% of the variance; participant-level random effects account for an additional ~17%.
3. **Post-hoc inference**:
   - render_a
     - r1 > r2 (Δ ≈ +0.1180, p < .0001)
     - r1 > r3 (Δ ≈ +0.1265, p < .0001)
     - r2 ≈ r3 (ns)
   - render_b
     - r1 ≈ r2 (ns)
     - r1 ≈ r3 (ns)
     - r2 ≈ r3 (ns)
  Effects are asymmetric: strong and significant differences are present for render_a, whereas render_b shows no reliable contrasts. Possible reason for significance only showing up for render_a might be the simplified processed_data (only stored the upper triangle data matrix).
