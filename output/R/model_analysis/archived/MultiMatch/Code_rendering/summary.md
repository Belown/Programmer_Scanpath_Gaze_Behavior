# High-Level Summary Across All Models

## 1: Rendering is the dominant systematic driver of scanpath similarity

Across all MultiMatch dimensions (Shape, Length, Direction, Position, Duration):

* **Rendering method produces robust, consistent effects** , especially for:
  * Shape, Length, Direction, Position`
* Rendering explains a  **substantial share of variance** :
  * Marginal R² ≈ **0.13–0.35** for Shape, Length, Direction, Position
  * Direction is the **most sensitive** dimension to rendering differences
* A stable pattern emerges:
  * **r1 consistently yields the lowest similarity**
  * **r2 and r3 yield the highest similarity**
  * r2 ≈ r3 in most dimensions (except Direction)

**Conclusion**: Visual layout and code rendering structure how programmers scan code far more than who they are.

## 2: Participant identity (individual gaze style) explains a large share of variance

Across all model specifications:

* **ICCs range from ~0.09 to ~0.36**
* This means **9–36% of variance** in similarity is explained by stable participant-specific effects
* Conditional R² jumps dramatically relative to marginal R²

Interpretation: Some programmers consistently produce more stereotyped or idiosyncratic scanpaths, regardless of rendering or expertise.

**Conclusion**:  There are strong, stable **individual differences in gaze behavior** that dominate residual structure.

## 3: Expertise has little to no effect on scanpath similarity

This holds across all three expertise operationalizations:

### (a) Categorical expertise (Beginner vs Intermediate)

* No effect for: Shape, Length, Direction, Duration
* A **small effect for Position only** (Intermediates slightly more similar than beginners) from fix_expertise_rendering

### (b) Numeric expertise (expertise_mean, expertise_diff)

* No effect for: Shape, Length, Direction, Duration
* A **small positive effect of expertise_mean on Position**
* **No effect of expertise_diff** on any dimension

### (c) PairType (BB, BI, II)

* **No significant differences** for any dimension
* Marginal R² ≈ 0 across all dimensions

**Conclusion**: Whether expertise is treated as **categorical**, **continuous**, or **pairwise composition** it  **does not meaningfully structure scanpath similarity** .

## 4: Rendering × Expertise interactions add little explanatory value

When including both rendering and expertise:

* Rendering effects remain **strong and unchanged**
* Expertise effects remain **weak or null**
* Interactions contribute **no meaningful additional variance**

**Conclusion**: Rendering drives similarity patterns **independently** of programmer expertise.

## Final Integrated Conclusion

1. Code rendering method is the primary systematic determinant of scanpath similarity.
2. Stable individual gaze styles explain a large fraction of variance across all dimensions.
3. Programmer expertise plays, at most, a minor role, with only a weak effect for Position similarity.
4. Expertise pairing composition (BB, BI, II) has no effect whatsoever.

* $(1 | exp\_ a) + (1 | exp\_ b)$ is both statistically necessary and substantively meaningful, because it captures:
* dependency in pairwise similarity data.
* large individual differences in visual scanning behavior.
