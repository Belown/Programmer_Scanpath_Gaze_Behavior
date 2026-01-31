# Cross-algorithm model-analysis synthesis (ScaSim vs NLD vs MultiMatch)

## 1. Purpose and structure

This document consolidates mixed-effects model findings into **explicit hypotheses** and **empirical clues** (supporting or contradicting evidence). It is designed to be directly reusable in a bachelor thesis as a results-and-interpretation section.

### Algorithms / outcome types compared

- **ScaSim** and **NLD**: outcome is a *score* (performance-like measure).
- **MultiMatch**: outcome is *scanpath similarity* (behavioral similarity across pairs) across five dimensions (Shape, Length, Direction, Position, Duration).

---

## 2. Hypotheses and clues (with cross-algorithm comparison)

### H1 — Rendering method systematically affects outcomes

**Hypothesis.** Manipulating rendering (especially render_a) causes systematic changes in the outcome (scores or similarity).

**Clues (support, strong).**

- **ScaSim (score):** Rendering is described as the dominant determinant; marginal R² is high (~0.34–0.36) and there are robust pairwise differences. The full rendering model reports **r1 > r2 > r3** (all pairwise significant) (see [`Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md`](Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md:3)).
- **NLD (score):** Rendering effects are again dominant; marginal R² ≈ 0.35. The stable pattern is **r1 > r2 and r1 > r3**, with **r2 ≈ r3** (see [`Code/output/R/model_analysis/NLD/Code_rendering/summary.md`](Code/output/R/model_analysis/NLD/Code_rendering/summary.md:3)).
- **MultiMatch (scanpath similarity):** Rendering robustly structures similarity across multiple dimensions; marginal R² spans **~0.13–0.35** for Shape/Length/Direction/Position. A stable pattern emerges: **r1 yields the lowest similarity**, **r2 and r3 the highest**, often **r2 ≈ r3**; Direction is most sensitive (see [`Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md`](Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md:3)).

**Clues (nuance).**

- For **ScaSim** and **NLD**, render_b is weak or inconsistent (see [`Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md`](Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md:9) and [`Code/output/R/model_analysis/NLD/Code_rendering/summary.md`](Code/output/R/model_analysis/NLD/Code_rendering/summary.md:5)). Also see why_exp_b_is_weak.md

**Cross-algorithm interpretation.** Rendering is the only predictor that is *consistently large and reliable* across all three algorithms, despite different outcomes (performance vs gaze similarity). This strongly supports rendering as a primary experimental driver.

---

### H2 — Expertise has a positive, reliable effect on outcomes

**Hypothesis.** Higher expertise leads to higher score (ScaSim/NLD) and systematically different scanpath similarity (MultiMatch).

**Clues (contradict, overall).**

- **ScaSim (EMIP):** No reliable expertise contrasts; marginal R² ~0.4%–1.9% indicates minimal explanatory power (see [`Code/output/R/model_analysis/ScaSim/EMIP/summary.md`](Code/output/R/model_analysis/ScaSim/EMIP/summary.md:3)).
- **NLD (EMIP):** Expertise-only models have marginal R² < 1%; pairwise contrasts among none/low/medium/high are non-significant (see [`Code/output/R/model_analysis/NLD/EMIP/summary.md`](Code/output/R/model_analysis/NLD/EMIP/summary.md:3)).
- **MultiMatch:** Expertise is largely non-informative; the integrated conclusion is that expertise does not meaningfully structure scanpath similarity (see [`Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md`](Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md:31) and [`Code/output/R/model_analysis/MultiMatch/EMIP/summary.md`](Code/output/R/model_analysis/MultiMatch/EMIP/summary.md:16)).

**Clues (exceptions / small effects).**

- **ScaSim (Code_rendering block):** mean expertise shows a small *negative* association (β ≈ −0.025, p = .0089), and expertise_diff has no effect (see [`Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md`](Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md:29)).
- **NLD (Code_rendering block):** expertise_mean has a trend-level negative slope (p ≈ .09) (see [`Code/output/R/model_analysis/NLD/Code_rendering/summary.md`](Code/output/R/model_analysis/NLD/Code_rendering/summary.md:20)).
- **MultiMatch:** a small expertise effect is noted for **Position** similarity only; other dimensions show null effects (see [`Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md`](Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md:35)).

**Cross-algorithm interpretation.** The data do not support a strong monotonic “higher expertise → different gaze similarity” claim. Where effects appear, they are small, sometimes directionally unexpected, and limited to specific specifications or dimensions.

---

### H3 — Expertise moderates rendering (expertise × rendering interaction)

**Hypothesis.** Rendering effects differ by expertise.

**Clues (weak/inconsistent).**

- **ScaSim:** interaction models keep rendering as dominant; the reported expertise difference (beginners slightly higher than intermediates, p = .026) is not consistent with a simple expertise advantage (see [`Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md`](Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md:13)).
- **NLD:** interaction adds little; rendering remains dominant; beginner vs intermediate is only borderline (p ≈ .050) (see [`Code/output/R/model_analysis/NLD/Code_rendering/summary.md`](Code/output/R/model_analysis/NLD/Code_rendering/summary.md:12)).
- **MultiMatch:** interactions add no meaningful variance; rendering effects remain strong and unchanged (see [`Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md`](Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md:53)).

**Cross-algorithm interpretation.** Interaction effects are not a major explanatory mechanism; rendering acts largely independently of expertise.

---

### H4 — Pair composition / PairType affects outcomes

**Hypothesis.** Pair composition (e.g., BB/BI/II or LN/LM/…) changes score/similarity.

**Clues (mostly contradict, small unstable signals).**

- **ScaSim:** PairType can show a small effect when rendering is omitted (BB > II), but the explained variance is small (~2.4%) and other contrasts are weak (see [`Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md`](Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md:21)). In EMIP analyses, pair composition is non-influential (see [`Code/output/R/model_analysis/ScaSim/EMIP/summary.md`](Code/output/R/model_analysis/ScaSim/EMIP/summary.md:19)).
- **NLD:** PairType is non-significant in both blocks (see [`Code/output/R/model_analysis/NLD/Code_rendering/summary.md`](Code/output/R/model_analysis/NLD/Code_rendering/summary.md:29) and [`Code/output/R/model_analysis/NLD/EMIP/summary.md`](Code/output/R/model_analysis/NLD/EMIP/summary.md:19)).
- **MultiMatch:** PairType (BB/BI/II) has no effect across dimensions; marginal R² ≈ 0 for PairType models (see [`Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md`](Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md:46) and [`Code/output/R/model_analysis/MultiMatch/EMIP/summary.md`](Code/output/R/model_analysis/MultiMatch/EMIP/summary.md:16)).

**Cross-algorithm interpretation.** Pairing composition is not a reliable determinant; any observed PairType effect (ScaSim, when rendering omitted) is plausibly confounded by missing strong predictors.


**Rationale for modeling expertise as categorical / PairType.** Although the expertise labels (none/low/medium/high) have an intuitive ordering, imposing a numeric coding (e.g., 0–3) would introduce a strong modeling assumption of a linear, monotonic effect with equal spacing between levels. Because our research question does not warrant assuming that scanpath similarity (or performance) changes monotonically across expertise levels, we treat expertise as a factor and encode pair composition via PairType. This allows for non-linear and asymmetric patterns between levels without imposing a predefined trend. Where relevant, we additionally report models using continuous summaries (e.g., expertise_mean and expertise_diff) as sensitivity analyses.

---

### H5 — Trial/order effects exist (learning, adaptation, fatigue)

**Hypothesis.** Trial number influences the outcome, independent of expertise.

**Clues (support, small but reliable; direction differs).**

- **ScaSim:** trial effect reported as trial 2 > trial 5 (Δ ≈ +0.0116, p < .0001) (see [`Code/output/R/model_analysis/ScaSim/EMIP/summary.md`](Code/output/R/model_analysis/ScaSim/EMIP/summary.md:11)).
- **NLD:** trial effect reported as trial 5 > trial 2 (Δ ≈ +0.0040, p = .0005) (see [`Code/output/R/model_analysis/NLD/EMIP/summary.md`](Code/output/R/model_analysis/NLD/EMIP/summary.md:11)).
- **MultiMatch:** trial effects depend on the dimension: Shape/Duration show Trial 2 > Trial 5, while Direction/Position show Trial 5 > Trial 2; effects are described as small but reliable (see [`Code/output/R/model_analysis/MultiMatch/EMIP/summary.md`](Code/output/R/model_analysis/MultiMatch/EMIP/summary.md:29)).

**Cross-algorithm interpretation.** Trial/order effects are present, but modest in magnitude and not uniform across outcomes. This pattern is consistent with a mixture of learning/adaptation and task/context dependence.

---

### H6 — Stable individual differences are a major source of variance

**Hypothesis.** Participant-level random effects explain substantial variance, exceeding many fixed effects.

**Clues (support, strong).**

- **ScaSim:** ICC often ~0.33–0.43 in EMIP models; random effects dominate (see [`Code/output/R/model_analysis/ScaSim/EMIP/summary.md`](Code/output/R/model_analysis/ScaSim/EMIP/summary.md:9)).
- **NLD:** ICC is substantial though smaller (~0.14–0.23 in EMIP; ~0.11–0.27 mentioned across models) (see [`Code/output/R/model_analysis/NLD/EMIP/summary.md`](Code/output/R/model_analysis/NLD/EMIP/summary.md:9) and [`Code/output/R/model_analysis/NLD/Code_rendering/summary.md`](Code/output/R/model_analysis/NLD/Code_rendering/summary.md:42)).
- **MultiMatch:** participant clustering is very strong for Shape/Length (ICC ~0.65–0.83), indicating that scanpath similarity strongly reflects stable individual gaze style; other dimensions are more context-dependent (see [`Code/output/R/model_analysis/MultiMatch/EMIP/summary.md`](Code/output/R/model_analysis/MultiMatch/EMIP/summary.md:5) and ICC range statement in [`Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md`](Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md:19)).

**Cross-algorithm interpretation.** Individual differences are a consistent and often dominant component of variability—especially for gaze-based similarity—highlighting the importance of mixed-effects modeling and participant-level controls.

---

## 3. Algorithm-by-algorithm takeaway (ready for thesis comparison)

### ScaSim (score)

- Primary driver: **render_a** (large effects; high marginal R²) (see [`Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md`](Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md:3)).
- Expertise: largely **non-reliable**; occasional small and inconsistent effects (see [`Code/output/R/model_analysis/ScaSim/EMIP/summary.md`](Code/output/R/model_analysis/ScaSim/EMIP/summary.md:3)).
- Trial: **small but robust** (trial 2 > trial 5) (see [`Code/output/R/model_analysis/ScaSim/EMIP/summary.md`](Code/output/R/model_analysis/ScaSim/EMIP/summary.md:11)).
- Random effects: **large ICC** indicates substantial participant heterogeneity (see [`Code/output/R/model_analysis/ScaSim/EMIP/summary.md`](Code/output/R/model_analysis/ScaSim/EMIP/summary.md:9)).

### NLD (score)

- Primary driver: **render_a**, with r1 > r2,r3 and r2 ≈ r3; marginal R² ≈ 0.35 (see [`Code/output/R/model_analysis/NLD/Code_rendering/summary.md`](Code/output/R/model_analysis/NLD/Code_rendering/summary.md:3)).
- Expertise: **weak/absent** across models (see [`Code/output/R/model_analysis/NLD/EMIP/summary.md`](Code/output/R/model_analysis/NLD/EMIP/summary.md:3)).
- Trial: **small but reliable**, opposite direction to ScaSim (trial 5 > trial 2) (see [`Code/output/R/model_analysis/NLD/EMIP/summary.md`](Code/output/R/model_analysis/NLD/EMIP/summary.md:11)).
- Random effects: meaningful but smaller than ScaSim/MultiMatch in EMIP (see [`Code/output/R/model_analysis/NLD/EMIP/summary.md`](Code/output/R/model_analysis/NLD/EMIP/summary.md:9)).

### MultiMatch (scanpath similarity)

- Primary driver: **rendering method**, consistently affecting multiple dimensions, with r1 lowest similarity and r2/r3 highest; Direction most sensitive (see [`Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md`](Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md:3)).
- Expertise: mostly **null**; at most a small Position-specific effect (see [`Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md`](Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md:35)).
- Trial: **dimension-specific** small effects (see [`Code/output/R/model_analysis/MultiMatch/EMIP/summary.md`](Code/output/R/model_analysis/MultiMatch/EMIP/summary.md:29)).
- Random effects: **very large** for some dimensions (Shape/Length ICC ~0.65–0.83), implying strong stable gaze signatures (see [`Code/output/R/model_analysis/MultiMatch/EMIP/summary.md`](Code/output/R/model_analysis/MultiMatch/EMIP/summary.md:5)).

---

## 4. Integrated conclusion paragraph (thesis-ready)

Across three algorithms spanning performance-like scores (ScaSim, NLD) and gaze-behavior similarity (MultiMatch), the analyses converge on a consistent result: **rendering (especially render_a) is the most robust and practically important experimental driver**. Rendering explains a substantial portion of variance in both score-based outcomes (marginal R² ≈ 0.34–0.36 for ScaSim and ≈ 0.35 for NLD; see [`Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md`](Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md:3) and [`Code/output/R/model_analysis/NLD/Code_rendering/summary.md`](Code/output/R/model_analysis/NLD/Code_rendering/summary.md:3)) and in scanpath similarity across multiple MultiMatch dimensions (marginal R² ≈ 0.13–0.35; see [`Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md`](Code/output/R/model_analysis/MultiMatch/Code_rendering/summary.md:3)). In contrast, **expertise and pair-composition predictors are weak, inconsistent, or absent**, with very low marginal R² in expertise-centric models and largely non-significant contrasts (see [`Code/output/R/model_analysis/ScaSim/EMIP/summary.md`](Code/output/R/model_analysis/ScaSim/EMIP/summary.md:3) and [`Code/output/R/model_analysis/NLD/EMIP/summary.md`](Code/output/R/model_analysis/NLD/EMIP/summary.md:3)). Trial/order effects emerge as **small but statistically reliable**, though their direction can depend on the algorithm and, for MultiMatch, on the specific dimension (see [`Code/output/R/model_analysis/MultiMatch/EMIP/summary.md`](Code/output/R/model_analysis/MultiMatch/EMIP/summary.md:29)). Finally, consistently elevated ICC values—particularly for MultiMatch—show that **stable individual differences contribute substantially to observed variability**, underscoring the methodological necessity of mixed-effects modeling and the substantive importance of participant heterogeneity (see [`Code/output/R/model_analysis/MultiMatch/EMIP/summary.md`](Code/output/R/model_analysis/MultiMatch/EMIP/summary.md:5)).

---

## 5. Reporting notes (bachelor thesis friendly)

- When comparing algorithms, report (i) dominant fixed effects (rendering), (ii) typical magnitude indicators (marginal R²), and (iii) clustering/heterogeneity (ICC).
- Treat PairType effects that appear only when rendering is excluded as potentially confounded rather than causal (e.g., ScaSim BB > II in a rendering-omitted model; see [`Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md`](Code/output/R/model_analysis/ScaSim/Code_rendering/summary.md:21)).
- For MultiMatch, emphasize that “expertise is null” does not imply “no structure”: rather, the structure is dominated by **rendering** and **individual gaze style**, with some **dimension-specific trial/context sensitivity** (see [`Code/output/R/model_analysis/MultiMatch/EMIP/summary.md`](Code/output/R/model_analysis/MultiMatch/EMIP/summary.md:23)).
