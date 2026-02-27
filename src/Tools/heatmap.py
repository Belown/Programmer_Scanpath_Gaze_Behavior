# This code is used to generate the ICC heatmap for the paper.

import numpy as np
import matplotlib.pyplot as plt

rows = [
    "EMIP_Within-Rec",
    "EMIP_Within-Veh",
    "EMIP_Within-Group",
    "EMIP_Between-MeanDiff",
    "EMIP_Between-PairType",
    "CR_Fix-Exp-Rend",
    "CR_Fix-Exp",
    "CR_Fix-Rend-MeanDiff",
    "CR_Fix-Rend-PairType"
]

cols = ["NLD", "ScaSim", "MM-Shape", "MM-Len", "MM-Dir", "MM-Pos", "MM-Dur"]

data = np.array([
    [0.301, 0.675, 0.843, 0.793, 0.422, 0.439, 0.595],
    [0.393, 0.625, 0.820, 0.766, 0.436, 0.334, 0.547],
    [0.286, 0.566, 0.694, 0.648, 0.334, 0.289, 0.525],
    [0.319, 0.513, 0.709, 0.662, 0.310, 0.258, 0.528],
    [0.315, 0.511, 0.707, 0.659, 0.309, 0.256, 0.527],
    [0.201, 0.403, 0.269, 0.297, 0.325, 0.124, 0.312],
    [0.266, 0.396, 0.434, 0.429, 0.437, 0.218, 0.304],
    [0.111, 0.206, 0.195, 0.207, 0.218, 0.087, 0.304],
    [0.111, 0.206, 0.195, 0.207, 0.218, 0.087, 0.304],
])

plt.figure()

im = plt.imshow(data, aspect="auto", vmin=0, vmax=1)

plt.xticks(np.arange(len(cols)), cols, rotation=45)
plt.yticks(np.arange(len(rows)), rows)

plt.colorbar(im, label="Adjusted ICC")

plt.title(
    "Heatmap of Adjusted ICC Values"
)

plt.tight_layout()
plt.show()