# Cross-algorithm model-analysis synthesis (ScaSim vs NLD vs MultiMatch)

## 1. Hypotheses and clues (with cross-algorithm comparison)

### H1 — Rendering method systematically affects outcomes

**Hypothesis.** Manipulating rendering (especially `render_a`) causes systematic changes in the outcome (scores or similarity).

**Clues (support, strong).**

- **ScaSim (score, Code_rendering):** Rendering is the dominant determinant; marginal R² ≈ 0.34–0.36. The full rendering model reports **r1 > r2 > r3** (all pairwise significant).
- **NLD (score, Code_rendering):** Rendering effects dominate; marginal R² ≈ 0.35. Stable pattern: **r1 > r2 and r1 > r3**, with **r2 ≈ r3** .
- **MultiMatch (scanpath similarity, Code_rendering):** Rendering robustly structures similarity across multiple dimensions; marginal R² spans **≈ 0.13–0.35** for Shape/Length/Direction/Position. A stable pattern emerges: **r1 yields the lowest similarity**, **r2 and r3 the highest**, often **r2 ≈ r3**; Direction is most sensitive.

**Clues (nuance).**

- For **ScaSim** and **NLD**, `render_b` is weak or inconsistent.

**Cross-algorithm interpretation.** Rendering is the only predictor that is **consistently large and reliable across all three algorithms**, despite different outcomes (performance vs gaze similarity). This supports rendering as a primary experimental driver.

---

### H2 — Expertise has a positive, reliable effect on outcomes

**Hypothesis.** Higher expertise leads to higher score (ScaSim/NLD) and systematically different scanpath similarity (MultiMatch).

**Clues (contradict, overall).**

- **ScaSim (EMIP):** No reliable expertise contrasts; marginal R² is low (≈ 0.2–3.5% across models) and **random effects dominate** (ICC ≈ 0.51–0.68).
- **NLD (EMIP):** Expertise-only models have **marginal R² < 1%**; pairwise contrasts are mostly non-significant.
- **MultiMatch (EMIP + Code_rendering):** Expertise is largely non-informative; the integrated conclusion is that expertise does not meaningfully structure scanpath similarity.

**Clues (exceptions / small effects).**

- **ScaSim (Code_rendering):** `expertise_mean` shows a small *negative* association (β ≈ −0.025, p = .0089), and `expertise_diff` has no effect.
- **NLD (Code_rendering):** `expertise_mean` shows only a trend-level negative slope (p ≈ .09).
- **MultiMatch (Code_rendering):** A small expertise effect is noted for **Position** similarity only; other dimensions are null.

**Cross-algorithm interpretation.** The data do not support a strong monotonic “higher expertise → better performance / different gaze similarity” claim. Where effects appear, they are small, sometimes directionally unexpected, and limited to specific specifications or dimensions.

---

### H3 — Expertise moderates rendering (expertise × rendering interaction)

**Hypothesis.** Rendering effects differ by expertise.

**Clues (weak/inconsistent).**

- **ScaSim (Code_rendering):** Interaction models keep rendering as dominant; beginners slightly higher than intermediates (p = .026) is not a clean “expertise advantage”.
- **NLD (Code_rendering):** Interaction adds little; beginner vs intermediate is borderline (p ≈ .050).
- **MultiMatch (Code_rendering):** Interactions add no meaningful variance; rendering effects remain strong and unchanged.

**Cross-algorithm interpretation.** Interaction effects are not a major explanatory mechanism; rendering acts largely independently of expertise.

---

### H4 — Pair composition / PairType affects outcomes

**Hypothesis.** Pair composition (e.g., BB/BI/II) changes score/similarity.

**Clues (mostly contradict; small unstable signals).**

- **ScaSim:** PairType can show a small effect when rendering is omitted (**BB > II**), but explained variance is small (~2.4%) and other contrasts are weak. In EMIP analyses, PairType is non-influential.
- **NLD:** PairType is non-significant in both blocks.
- **MultiMatch:** PairType has no effect across dimensions; marginal R² ≈ 0 for PairType models.

**Cross-algorithm interpretation.** Pair composition is not a reliable determinant; the only clearer PairType signal (ScaSim, when rendering omitted) is plausibly confounded by missing strong predictors.

---

### H5 — Stimulus effects exist

**Hypothesis.** Stimulus type (e.g., Rectangle vs Vehicle) systematically influences the outcome, independent of expertise.

**Clues (support, modest but reliable where reported).**

- **NLD (EMIP):** NLD (EMIP): A clear stimulus effect is reported (Rectangle > Vehicle, Δ ≈ +0.0343, p < 0.0001)
- **MultiMatch (EMIP):** Stimulus context modulates similarity in a dimension-specific way: significant but small effects for Shape, Position, Duration (Length marginal; Direction non-significant)
- **ScaSim (EMIP):** A small but significant within-group stimulus shift is reported (Rectangle > Vehicle, estimate ≈ +0.00451, p = 0.0358)

**Cross-algorithm interpretation.** Beyond rendering, **stimulus/context** introduces a secondary, modest but sometimes reliable shift. Its magnitude is smaller than rendering, and for MultiMatch it depends on the specific similarity dimension.

---

### H6 — Stable individual differences are a major source of variance

**Hypothesis.** Participant-level random effects explain substantial variance, exceeding many fixed effects.

**Clues (support, strong).**

- **ScaSim (EMIP):** ICC is often high (e.g., ~0.51–0.64 depending on subset/model), indicating large participant heterogeneity (example: adjusted ICC = 0.566 in within_group).
- **NLD (EMIP):** ICC is meaningful though smaller (~0.29–0.39 in expertise-centric models).
- **MultiMatch (EMIP):** participant clustering is very strong for Shape/Length (ICC ~0.65–0.83), indicating stable individual gaze style; Direction/Position have lower ICC (~0.23–0.32) and more residual/context dependence.
- **MultiMatch (Code_rendering):** emphasizes the necessity of pairwise random effects such as [`(1 | exp_a) + (1 | exp_b)`].

**Cross-algorithm interpretation.** Individual differences are a consistent and often dominant component of variability—especially for gaze-based similarity—highlighting the necessity of mixed-effects modeling and participant-level controls.

---

## 2. Algorithm-by-algorithm takeaway (thesis comparison)

### ScaSim (score)

- Primary driver: **`render_a`** (large effects; high marginal R²; **r1 > r2 > r3**).
- Expertise: largely **non-reliable** in EMIP; continuous expertise shows at most small and sometimes negative associations.
- PairType: mostly null; a small `BB > II` signal appears only when rendering is omitted.
- Random effects: large ICC in EMIP indicates substantial participant heterogeneity.

### NLD (score)

- Primary driver: **`render_a`**, with **r1 > r2,r3** and **r2 ≈ r3**; marginal R² ≈ 0.35.
- Expertise: **weak/absent** across models; continuous expertise at most trend-level.
- Stimulus: **small but reliable** in EMIP (Rectangle > Vehicle)
- Random effects: meaningful but smaller than ScaSim/MultiMatch.

### MultiMatch (scanpath similarity)

- Primary driver: **rendering method**, affecting multiple dimensions; **r1 lowest similarity**, **r2/r3 highest**; Direction most sensitive.
- Expertise: mostly **null**; at most a small Position-specific effect.
- Stimulus/context: **dimension-specific** small effects in EMIP
- Random effects: **very large** for some dimensions (Shape/Length ICC ~0.65–0.83), implying strong stable gaze signatures.

---

## 3. Conclusion

Across three algorithms spanning performance-like scores (ScaSim, NLD) and gaze-behavior similarity (MultiMatch), the analyses converge on a consistent result: **rendering (especially `render_a`) is the most robust and practically important experimental driver**. Rendering explains a substantial portion of variance in score-based outcomes (marginal R² ≈ 0.34–0.36 for ScaSim; ≈ 0.35 for NLD) and in scanpath similarity across multiple MultiMatch dimensions (marginal R² ≈ 0.13–0.35). In contrast, **expertise and pair-composition predictors are weak, inconsistent, or absent**, with very low marginal R² in expertise-centric models and largely non-significant contrasts. Stimulus/context effects emerge as small but statistically reliable where modeled, though their presence and direction depend on the algorithm and (for MultiMatch) the specific dimension. Finally, elevated ICC values—particularly for MultiMatch—show that **stable individual differences contribute substantially to observed variability**, underscoring both the methodological necessity of mixed-effects modeling and the substantive importance of participant heterogeneity.

---

## 4. Reporting notes

- When comparing algorithms, report (i) dominant fixed effects (rendering), (ii) magnitude indicators (marginal R²), and (iii) clustering/heterogeneity (ICC), with links to the per-block summaries.
- Treat PairType effects that appear only when rendering is excluded as potentially confounded rather than causal (e.g., ScaSim `BB > II`).
- For MultiMatch, emphasize that “expertise is null” does not imply “no structure”: the structure is dominated by **rendering** and **individual gaze style**, with some **dimension-specific stimulus/context sensitivity**.
