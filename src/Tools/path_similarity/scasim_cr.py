from .scasim import scasim_helper
import pandas as pd

def scasim_cr(vec_a: pd.DataFrame, vec_b: pd.DataFrame, normalize=None) -> float:
    """
    Compute ScaSim for CR dataset

    :param: vec_a: Vector of fixations for first scanpath.
    :param: vec_b: Vector of fixations for second scanpath.
    :param: normalize: If we normalize the result at the end. Three option: 
                       'durations', 'fixations' or 'None'

    :return: ScaSim similarity score between the two scanpaths.
    """
    df1 = vec_a.rename(columns={'start_x': 'x0', 'start_y': 'y0'})
    df2 = vec_b.rename(columns={'start_x': 'x0', 'start_y': 'y0'})
    return float(scasim_helper(df1, df2, normalize=normalize))