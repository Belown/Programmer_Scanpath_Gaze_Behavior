
# Dimensions

## Shape

1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.00102; residual SD = 0.00294. Adjusted ICC = 0.195, indicating that ~20% of variance in Shape similarity is attributable to stable participant-specific differences.
2. **Nakagawa R²**: Marginal R² = 0.0001; Conditional R² = 0.1947. PairType explains virtually no variance; nearly all explained variance is due to participant-level random effects.
3. **Post-hoc inference**:
   - BB ≈ BI (ns)
   - BB ≈ II (ns)
   - BI ≈ II (ns)
  Conclusion: Shape similarity does not differ by expertise pairing type.

## Length

1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.00138; residual SD = 0.00382. Adjusted ICC = 0.207, indicating that ~21% of variance reflects stable participant-level differences.
2. **Nakagawa R²**: Marginal R² = 0.0002; Conditional R² = 0.2067. PairType explains essentially no variance; participant effects dominate.
3. **Post-hoc inference**:
   - BB ≈ BI (ns)
   - BB ≈ II (ns)
   - BI ≈ II (ns)
  Conclusion: Length similarity does not differ by pairing type.

## Direction

1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both ≈ 0.02139; residual SD = 0.05732. Adjusted ICC = 0.218, indicating substantial participant-level variance.
2. **Nakagawa R²**: Marginal R² = 0.0027; Conditional R² = 0.2199. PairType explains <1% of variance; random effects dominate.
3. **Post-hoc inference**:
   - BB ≈ BI (ns)
   - BB ≈ II (ns)
   - BI ≈ II (ns)
  Conclusion: Direction similarity does not differ by expertise pairing.

## Position
  
1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.00721; residual SD = 0.03295. Adjusted ICC = 0.087, indicating modest participant-level variance.
2. **Nakagawa R²**: Marginal R² = 0.0067; Conditional R² = 0.0934. PairType explains <1% of variance; participant-level effects dominate.
3. **Post-hoc inference**:
   - BB ≈ BI (ns)
   - BB ≈ II (ns)
   - BI ≈ II (ns)
  Conclusion: Position similarity does not differ significantly by pairing type (at most a weak, non-significant trend). 

## Duration
  
1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.01576; residual SD = 0.03376. Adjusted ICC = 0.304, indicating strong participant-level variance.
2. **Nakagawa R²**: Marginal R² = 0.0020; Conditional R² = 0.305. PairType explains virtually no variance; random effects dominate.
3. **Post-hoc inference**:
   - BB ≈ BI (ns)
   - BB ≈ II (ns)
   - BI ≈ II (ns)
  Conclusion: Duration similarity does not differ by expertise pairing.

## Summary

- Expertise pairing type (BB, BI, II) has no reliable effect on scanpath similarity for any MultiMatch dimension (Shape, Length, Direction, Position, Duration).
- Marginal R² values are effectively zero across all dimensions, indicating that PairType explains none of the systematic variance in similarity.
- Participant identity remains the dominant source of variance, with ICCs ranging from ~0.09 to ~0.30, reflecting strong individual differences in gaze behavior.
- These results converge with your numeric-expertise model: whether expertise is treated as a continuous variable (expertise_mean, expertise_diff) or a categorical pairing (PairType), expertise does not meaningfully structure pairwise gaze similarity.
- Substantively, this strengthens the conclusion that rendering method (from earlier models), not programmer expertise or expertise pairing, is the primary driver of scanpath similarity in your dataset.
This model provides a clean negative result for expertise-based hypotheses and supports a theoretically coherent narrative: programmers’ individual gaze styles and visual encoding of code layout dominate similarity structure, not their expertise level or pairing composition.
