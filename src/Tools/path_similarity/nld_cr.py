import pandas as pd
import numpy as np
from .nld import nld_helper

def vec_to_aoi_df(vec: pd.DataFrame, screensize=(1920, 1080), grid=(12, 8)) -> pd.DataFrame:
    """
    Make CR dataset' fixation vector discrete into AOI token sequence for Levenshtein/NLD.

    :param: vec: Vector of fixations.
    :param: screensize: Tuple of (width, height) of the screen in pixels.
    :param: grid: Tuple of (cols, rows) defining the grid size.

    :return: DataFrame with 'aoi_name' column representing AOI tokens.
    """
    if vec is None or vec.empty:
        return pd.DataFrame({'aoi_name': []})

    required = {'start_x', 'start_y'}
    missing = required - set(vec.columns)
    if missing:
        raise KeyError(f'CR vector missing columns: {sorted(missing)}')

    w, h = screensize
    cols, rows = grid
    # clip to avoid out-of-screen fixations
    x = vec['start_x'].astype(float).clip(0, w - 1)
    y = vec['start_y'].astype(float).clip(0, h - 1)

    cell_w = w / cols
    cell_h = h / rows
    ix = (x / cell_w).astype(int).clip(0, cols - 1)
    iy = (y / cell_h).astype(int).clip(0, rows - 1)

    aoi_name = ix.astype(str) + '_' + iy.astype(str)
    return pd.DataFrame({'aoi_name': aoi_name})

def nld_cr(vec_a: pd.DataFrame, vec_b: pd.DataFrame, screensize=(1920, 1080), grid=(12, 8)) -> float:
    """
    Compute NLD for CR dataset
    
    :param: vec_a: Vector of fixations for first scanpath.
    :param: vec_b: Vector of fixations for second scanpath.
    :param: screensize: Tuple of (width, height) of the screen in pixels.
    :param: grid: Tuple of (cols, rows) defining the grid size.

    :return: NLD similarity score between the two scanpaths.
    """
    df1 = vec_to_aoi_df(vec_a, screensize=screensize, grid=grid)
    df2 = vec_to_aoi_df(vec_b, screensize=screensize, grid=grid)
    _distance, nld = nld_helper(df1, df2)
    return float(nld)