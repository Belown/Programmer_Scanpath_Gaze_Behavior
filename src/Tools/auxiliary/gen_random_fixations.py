import numpy as np
import pandas as pd

def gen_random_fixations(n, screensize=(1920, 1080), seed=None):
    """
    Generate n random fixations as a baseline scanpath and return a pandas.DataFrame.
    
    Coordinates follow uniform distribution U(0.05, 0.95) in normalized screen coordinates,
    then scaled to actual screen size. Duration follows uniform distribution U(0.8, 1.5) seconds.
    
    :param: n: Number of random fixations to generate
    :param: screensize: Tuple specifying the screen size (width, height)
    :param: seed: Optional seed for random number generator for reproducibility

    :return: pandas.DataFrame with columns ['x0', 'y0', 'duration'] where coordinates are in pixels and duration in seconds
    """
    cols = ['x0', 'y0', 'duration']
    if n <= 0:
        return pd.DataFrame({c: pd.Series(dtype='float64') for c in cols})

    if seed is not None:
        np.random.seed(seed)
    
    # Generate normalized coordinates first, then scale to screen size
    # Follow a Uniform distribution between 0.05 and 0.95 of the screen dimensions
    start_x_norm = np.random.uniform(0.05, 0.95, size=n)
    start_y_norm = np.random.uniform(0.05, 0.95, size=n)
    start_x = start_x_norm * screensize[0]
    start_y = start_y_norm * screensize[1]
    duration = np.random.uniform(800, 1500, size=n) / 1000.0  # in seconds
    
    df = pd.DataFrame({
        'x0': start_x,
        'y0': start_y,
        'duration': duration
    }).astype({'x0': 'float64', 'y0': 'float64', 'duration': 'float64'})

    return df