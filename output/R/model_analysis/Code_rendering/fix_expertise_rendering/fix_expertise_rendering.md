
# Dimensions

## Shape

1. **Random Effects**: Random intercept SDs are identical for exp_a and exp_b (0.00099), with residual SD = 0.00230. Adjusted ICC = 0.269, indicating that ~27% of variance in Shape similarity is attributable to stable participant-specific differences.
2. **Nakagawa R²**: Marginal R² = 0.334; Conditional R² = 0.513. Fixed effects (expertise, rendering, and their interaction) explain ~33% of variance; participant-level effects add ~18%.
3. **Post-hoc inference**:
   - Expertise: Beginner ≈ Intermediate (ns).
   - Rendering:
     - r1 < r2 (Δ ≈ −0.00344, p < .0001)
     - r1 < r3 (Δ ≈ −0.00340, p < .0001)
     - r2 ≈ r3 (ns)
    Conclusion: Shape similarity is driven by rendering method (r1 lowest), not by expertise.

## Length

1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.00138; residual SD = 0.00301. Adjusted ICC = 0.297, meaning ~30% of variance reflects stable participant-level differences.
2. **Nakagawa R²**: Marginal R² = 0.284; Conditional R² = 0.497. Fixed effects explain ~28% of variance; random effects contribute an additional ~21%.
3. **Post-hoc inference**:
   - Expertise: Beginner ≈ Intermediate (ns).
   - Rendering:
     - r1 < r2 (Δ ≈ −0.00457, p < .0001)
     - r1 < r3 (Δ ≈ −0.00406, p < .0001)
     - r2 ≈ r3 (ns; p = .102)
    Conclusion: Length similarity is strongly affected by rendering, not by expertise.

## Direction
  
1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.02029; residual SD = 0.04137. Adjusted ICC = 0.325, indicating strong participant-level variance.
2. **Nakagawa R²**: Marginal R² = 0.351; Conditional R² = 0.562. Fixed effects explain ~35% of variance; participant-level effects add ~21%.
3. **Post-hoc inference**:
   - Expertise: Beginner ≈ Intermediate (ns).
   - Rendering:
     - r1 < r2 (Δ ≈ −0.0816, p < .0001)
     - r1 < r3 (Δ ≈ −0.0671, p < .0001)
     - r2 > r3 (Δ ≈ 0.0145, p < .0001)
    Conclusion: Direction similarity is highly sensitive to rendering method (r2 highest, r1 lowest), with no reliable expertise effect.

## Position
  
1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.00840; residual SD = 0.03155. Adjusted ICC = 0.124, indicating modest participant-specific variance.
2. **Nakagawa R²**: Marginal R² = 0.133; Conditional R² = 0.241. Fixed effects explain ~13% of variance; random effects add ~11%.
3. **Post-hoc inference**:
   - Expertise: Beginner < Intermediate (Δ ≈ −0.00846, p = .043).
   - Rendering:
     - r1 < r2 (Δ ≈ −0.0257, p < .0001)
     - r1 < r3 (Δ ≈ −0.0261, p < .0001)
     - r2 ≈ r3 (ns)
    Conclusion: Position similarity is affected by both rendering and expertise, with intermediates showing slightly higher similarity than beginners.

## Duration
  
1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.01507; residual SD = 0.03166. Adjusted ICC = 0.312, indicating substantial participant-level variance.
2. **Nakagawa R²**: Marginal R² = 0.0629; Conditional R² = 0.355. Fixed effects explain very little variance; participant-level effects dominate.
3. **Post-hoc inference**:
   - Expertise: Beginner ≈ Intermediate (ns).
   - Rendering:
     - r1 ≈ r2 (ns)
     - r1 > r3 (Δ ≈ 0.0196, p < .0001)
     - r2 > r3 (Δ ≈ 0.0212, p < .0001)
    Conclusion: Duration similarity is weakly sensitive to rendering (r3 lowest), with no detectable expertise effect.

## Summary

- Participant identity remains a major source of variance across all dimensions (ICC ≈ 0.12–0.33), confirming strong individual differences in gaze behavior.
- Rendering method robustly affects Shape, Length, Direction, Position, and Duration, with r1 consistently yielding the lowest similarity and r2/r3 the highest.
- Expertise has limited impact overall, showing:
  - no effect for Shape, Length, Direction, or Duration
  - a small but significant effect for Position (Intermediate > Beginner).
- Direction is the most sensitive dimension to rendering differences (largest effect sizes and highest marginal R²).
- Duration is dominated by participant-specific variability, with fixed effects explaining little variance (Marginal R² ≈ 0.06).
This model provides a clean separation between rendering-driven effects, expertise effects, and stable individual differences, and it is methodologically appropriate for pairwise MultiMatch similarity data.
