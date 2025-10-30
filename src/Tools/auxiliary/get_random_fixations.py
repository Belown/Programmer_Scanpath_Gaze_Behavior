import numpy as np
import pandas as pd

def gen_random_fixations(n, screensize=(1920, 1080), seed=None):
    """
    Generate n random fixations as a baseline scanpath and return a pandas.DataFrame.
    
    :param: n: Number of random fixations to generate
    :param: screensize: Tuple specifying the screen size (width, height)
    :param: seed: Optional seed for random number generator for reproducibility

    :return: pandas.DataFrame with columns ['x0', 'y0', 'duration']
    """
    cols = ['x0', 'y0', 'duration']
    if n <= 0:
        return pd.DataFrame({c: pd.Series(dtype='float64') for c in cols})

    if seed is not None:
        np.random.seed(seed)

    arr = pd.DataFrame({c: pd.Series(dtype='float64') for c in cols})
    margin_x = 0.05 * screensize[0]
    margin_y = 0.05 * screensize[1]
    
    start_x = np.random.uniform(margin_x, screensize[0] - margin_x, size=n)
    start_y = np.random.uniform(margin_y, screensize[1] - margin_y, size=n)
    duration = np.random.uniform(800, 1500, size=n) / 1000.0  # in seconds
    
    df = pd.DataFrame({
        'x0': start_x,
        'y0': start_y,
        'duration': duration
    }).astype({'x0': 'float64', 'y0': 'float64', 'duration': 'float64'})

    return df