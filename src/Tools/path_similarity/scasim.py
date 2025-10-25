import sys, os
import pandas as pd
import numpy as np
import json
from math import pi, sin, cos, acos
from tools.auxiliary import build_vector, parse_corrected_emip_data, gen_random_fixations

def scasim(
    exp_a: tuple,
    exp_b: tuple,
    eye_events: pd.DataFrame,
    normalize: str = None,
    data_set: str = None
):
    '''
    Compute similarity based on the method from https://github.com/DiLi-Lab/ScanDL-2.0/blob/main/scandl_fixdur/fix_dur_module/scasim.py
    :param exp_a: Tuple of (experiment_id, trial_id) for first scanpath
    :param exp_b: Tuple of (experiment_id, trial_id) for second scanpath
    :param eye_events: Parsed data frame for eye event
    :param normalize: If we normalize the result at the end. Three option: 'durations', 'fixations' or 'None'
    :return: path similarity score
    '''

    if data_set == "corrected":
        parsed_data = parse_corrected_emip_data()
        fix_vec1 = build_vector(exp_a, parsed_data)
        fix_vec2 = build_vector(exp_b, parsed_data)
    elif data_set == "original":
        fix_vec1 = build_vector(exp_a, eye_events)
        fix_vec2 = build_vector(exp_b, eye_events)
    else:
        raise ValueError("data_set must be either 'corrected' or 'original'")
    
    random_vec1 = gen_random_fixations(len(fix_vec1))
    random_vec2 = gen_random_fixations(len(fix_vec2))

    original_score = scasim_helper(fix_vec1, fix_vec2, normalize)
    base_line_score = scasim_helper(random_vec1, random_vec2, normalize)
    final_score = original_score - base_line_score

    return {
        "original_score": original_score,
        "base_line_score": base_line_score,
        "final_score": final_score
    }

    

def scasim_helper(
    df1: pd.DataFrame,
    df2: pd.DataFrame,
    normalize: str = None
):
    if df1.empty or df2.empty:
        print("No matching data")
        raise SystemExit("No matching data")

    # lengths of scanpaths
    m, n = len(df1), len(df2)

    # extract numpy arrays for positional access
    dur1 = df1['duration'].to_numpy(dtype=float)
    dur2 = df2['duration'].to_numpy(dtype=float)
    x1 = df1['x0'].to_numpy(dtype=float)
    y1 = df1['y0'].to_numpy(dtype=float)
    x2 = df2['x0'].to_numpy(dtype=float)
    y2 = df2['y0'].to_numpy(dtype=float)

    sum_fix_vec_1 = dur1.sum()
    sum_fix_vec_2 = dur2.sum()


    # initialize distance matrix with rows = len_vec_1 + 1 and cols = len_vec_2 + 1
    mat = [[0.0] * (n + 1) for _ in range(m + 1)]

    acc = 0.0
    for fix_i in range(1, m + 1):
        acc += dur1[fix_i - 1]
        mat[fix_i][0] = acc

    acc = 0.0
    for fix_j in range(1, n + 1):
        acc += dur2[fix_j - 1]
        mat[0][fix_j] = acc

    for i in range(1, m + 1):
        for j in range(1, n + 1):

            fi = i - 1
            fj = j - 1
            
            dist = np.hypot(x2[fj] - x1[fi], y2[fj] - y1[fi])
            
            max_screen_dist = 1920
            angle = min(dist / max_screen_dist * 180.0, 180.0)

            modulator = 0.83
            mixer = modulator ** angle
            
            cost = (
                abs(dur2[fj] - dur1[fi]) * mixer +
                (dur2[fj] + dur1[fi]) * (1.0 - mixer)
            )
            
            ops = (
                mat[i - 1][j] + dur1[fi],
                mat[i][j - 1] + dur2[fj],
                mat[i - 1][j - 1] + cost,
            )
            
            mi = int(np.argmin(ops))
            mat[i][j] = ops[mi]
    
    result = mat[m][n]
    
    if normalize in ['fixations', 'fixation']:
        result /= (m + n)
    elif normalize in ['durations', 'duration']:
        denom = (sum_fix_vec_1 + sum_fix_vec_2)
        if denom != 0:
            result /= denom
        
    return result