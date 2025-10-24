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
    fix_vec1,
    fix_vec2,
    normalize: str = None
):
    if fix_vec1.size == 0 or fix_vec2.size == 0:
        print("No matching data")
        raise SystemExit("No matching data")

    # lengths of scanpaths
    m, n = len(fix_vec1), len(fix_vec2)

    # sum of fixation durations for scanpaths
    sum_fix_vec_1 = fix_vec1['duration'].sum()
    sum_fix_vec_2 = fix_vec2['duration'].sum()


    # initialize distance matrix with rows = len_vec_1 + 1 and cols = len_vec_2 + 1
    mat = [list(map(lambda i: 0, range(n + 1))) for _ in range(m + 1)]

    acc = 0
    for fix_i in range(1, m + 1):
        acc += fix_vec1[fix_i - 1]['duration']
        mat[fix_i][0] = acc
    
    acc = 0
    for fix_j in range(1, n + 1):
        acc += fix_vec2[fix_j - 1]['duration']
        mat[0][fix_j] = acc

    for i in range(1, m + 1):
        for j in range(1, n + 1):

            fix_i_idx = i - 1
            fix_j_idx = j - 1

            x1, y1 = fix_vec1[fix_i_idx]['start_x'], fix_vec1[fix_i_idx]['start_y']
            x2, y2 = fix_vec2[fix_j_idx]['start_x'], fix_vec2[fix_j_idx]['start_y']
            
            dist = np.sqrt((x2-x1)**2 + (y2-y1)**2)
            
            max_screen_dist = 1920
            angle = min(dist / max_screen_dist * 180, 180)

            modulator = 0.83
            mixer = modulator ** angle
            
            cost = (
                abs(fix_vec2[fix_j_idx]['duration'] - fix_vec1[fix_i_idx]['duration']) * mixer +
                (fix_vec2[fix_j_idx]['duration'] + fix_vec1[fix_i_idx]['duration']) * (1.0 - mixer)
            )
            
            ops = (
                mat[i-1][j] + fix_vec1[fix_i_idx]['duration'],
                mat[i][j-1] + fix_vec2[fix_j_idx]['duration'],
                mat[i-1][j-1] + cost,
            )
            
            mi = np.argmin(ops)
            mat[i][j] = ops[mi]
    
    result = mat[m][n]
    
    if normalize in ['fixations', 'fixation']:
        result /= (m + n)
    elif normalize in ['durations', 'duration']:
        result /= (sum_fix_vec_1 + sum_fix_vec_2)
        
    return result