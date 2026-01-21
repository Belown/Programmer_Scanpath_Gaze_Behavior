import numpy as np

def inv_logit(x):
    return np.exp(x) / (1 + np.exp(x))

intercept = 1.82267597

expertise = {
    "Beginner": 0,
    "Intermediate": 0.02747606
}

rendering = {
    "r1_r1": 0,
    "r1_r2": -0.03137538,
    "r1_r3": -0.11962960,
    "r2_r2": -0.04783935,
    "r2_r3": -0.10038554,
    "r3_r3": -0.12067242
}

for exp_level, exp_coef in expertise.items():
    print(f"\n{exp_level}:")
    for pair, pair_coef in rendering.items():
        baseline = inv_logit(intercept + exp_coef)
        logit_val = intercept + exp_coef + pair_coef
        similarity = inv_logit(logit_val)
        print(f"  {pair}: logit={logit_val:.3f}, sim={similarity:.4f}, diff from intercept={similarity - baseline:.4f}, %change of remaining={(similarity - baseline) / (1 - baseline) * 100:.2f}%")