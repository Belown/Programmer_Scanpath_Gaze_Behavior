
# Dimensions

## Shape

1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.00102; residual SD = 0.00294. Adjusted ICC = 0.195, indicating that ~20% of variance in Shape similarity is attributable to stable participant-specific differences.
2. **Nakagawa R²**: Marginal R² = 0.0001; Conditional R² = 0.1947. Fixed effects explain essentially no variance; nearly all explained variance comes from participant-level random effects.
3. **Post-hoc inference**:
   - No categorical fixed effects. From slope estimates:
     - expertise_mean: β ≈ −6.36e−05, p = 0.895 (ns)
     - expertise_diff: β ≈ 3.12e−05, p = 0.824 (ns)
    Conclusion: Shape similarity is not related to either the average expertise of a scanpath pair or the expertise difference between the two participants.

## Length

1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.00138; residual SD = 0.00382. Adjusted ICC = 0.207, meaning ~21% of variance reflects stable participant-level differences.
2. **Nakagawa R²**: Marginal R² = 0.0002; Conditional R² = 0.2067. Fixed effects explain essentially no variance; participant effects dominate.
3. **Post-hoc inference**:
   - From slope estimates:
   - expertise_mean: β ≈ −1.79e−04, p = 0.781 (ns)
   - expertise_diff: β ≈ 2.34e−06, p = 0.990 (ns)
  Conclusion: Length similarity is not related to expertise level or expertise disparity between participants.

## Direction

1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.02139; residual SD = 0.05732. Adjusted ICC = 0.218, indicating substantial participant-level variance.
2. **Nakagawa R²**: Marginal R² = 0.0027; Conditional R² = 0.2199. Fixed effects explain <1% of variance; nearly all explained variance is due to random effects.
3. **Post-hoc inference**:
   - From slope estimates:
   - expertise_mean: β ≈ 0.00897, p = 0.366 (ns)
   - expertise_diff: β ≈ −0.00266, p = 0.331 (ns)
  Conclusion: Direction similarity is not reliably related to average expertise or expertise difference.

## Position
  
1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.00721; residual SD = 0.03295. Adjusted ICC = 0.087, indicating modest participant-specific variance.
2. **Nakagawa R²**: Marginal R² = 0.0067; Conditional R² = 0.0934. Fixed effects explain <1% of variance; participant-level effects dominate.
3. **Post-hoc inference**:
   - From slope estimates:
   - expertise_mean: β ≈ 0.00816, p = 0.0321 (*)
   - expertise_diff: β ≈ 3.78e−04, p = 0.809 (ns)
  Conclusion: Position similarity increases slightly with higher average expertise of the scanpath pair; expertise difference has no effect.

## Duration
  
1. **Random Effects**: Random intercept SDs for exp_a and exp_b are both 0.01576; residual SD = 0.03376. Adjusted ICC = 0.304, indicating strong participant-level variance.
2. **Nakagawa R²**: Marginal R² = 0.0020; Conditional R² = 0.305. Fixed effects explain virtually no variance; participant-level effects dominate.
3. **Post-hoc inference**:
   - From slope estimates:
   - expertise_mean: β ≈ −0.00501, p = 0.481 (ns)
   - expertise_diff: β ≈ −9.66e−04, p = 0.550 (ns)
  Conclusion: Duration similarity is not related to either average expertise or expertise difference.

## Summary

- Participant identity remains a major source of variance across all dimensions (ICC ≈ 0.09–0.30), confirming strong individual differences in gaze behavior.
- Expertise_mean and expertise_diff explain essentially no variance in MultiMatch similarity for Shape, Length, Direction, and Duration (Marginal R² ≈ 0.000–0.003).
- Only Position similarity shows a small but significant expertise effect: higher average expertise is associated with slightly higher positional scanpath similarity.
- Expertise difference between paired participants has no detectable effect on any MultiMatch dimension.
- Substantively, this model indicates that rendering method (from earlier models), not expertise level, is the primary systematic driver of scanpath similarity, while stable individual gaze styles dominate residual structure.
This provides a clean contrast with your rendering-based models and strengthens the conclusion that expertise plays, at most, a minor role in shaping pairwise gaze similarity under your task conditions.
