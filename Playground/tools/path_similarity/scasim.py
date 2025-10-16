import sys, os
import pandas as pd
import numpy as np
import json
from math import pi, sin, cos, acos

# set up path
EMIP_dir = os.path.dirname(os.path.abspath(__file__))
Playground_dir = os.path.dirname(EMIP_dir)
Code_dir = os.path.dirname(Playground_dir)
lib_path = os.path.join(Code_dir, "EMIP-Toolkit")

# sys.path.append(lib_path)
# os.chdir(lib_path)
# from emtk import parsers, visualization, util, aoi

def scasim(
    exp_id_str_a: str,
    trial_id_str_a: str,
    exp_id_str_b: str,
    trial_id_str_b: str,
    eye_events: pd.DataFrame,
    normalize: str,
):
    '''
    Compute similarity based on the method from https://github.com/DiLi-Lab/ScanDL-2.0/blob/main/scandl_fixdur/fix_dur_module/scasim.py
    :param exp_id_str_a: Experiment id for first scanpath
    :param trial_id_str_a: Trial id foor first scanpah
    :param exp_id_str_b: Experiment id for second scanpath
    :param trial_id_str_b: Trial id foor second scanpah
    :param eye_events: Parsed data frame for eye event
    :param normalize: If we normalize the result at the end. Three option: 'durations', 'fixations' or 'None'
    '''

    fix_vec1 = build_vector(exp_id_str_a, trial_id_str_a, eye_events)
    fix_vec2 = build_vector(exp_id_str_b, trial_id_str_b, eye_events)

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

    for fix_i in range(n):
        for fix_j in range(m):
            slon = fix_vec1[fix_j][0] / (180 / pi)  # longitude (x-axis)
            tlon = fix_vec2[fix_i][0] / (180 / pi)
            slat = fix_vec1[fix_j][1] / (180 / pi)  # latitude (y-axis)
            tlat = fix_vec2[fix_i][1] / (180 / pi)

            angle = acos(sin(slat) * sin(tlat) + cos(slat) * cos(tlat) * cos(slon - tlon)) * (180 / pi)

            # default modulator value
            modulator = 0.83

            mixer = modulator ** angle

            # cost for substitution:
            cost = (
                abs(fix_vec2[fix_i][2] - fix_vec1[fix_j][2]) * mixer +
                (fix_vec2[fix_i][2] + fix_vec1[fix_j][2]) * (1.0 - mixer)
            )

            ops = (
                mat[fix_j][fix_i + 1] + fix_vec1[fix_j][2],
                mat[fix_j + 1][fix_i] + fix_vec2[fix_i][2],
                mat[fix_j][fix_i] + cost,
            )

            mi = np.argmin(ops)

            mat[fix_j + 1][fix_i + 1] = ops[mi]

    result = mat[-1][-1]
    if normalize == 'fixations':
        result /= (m + n)
    elif normalize == 'durations':
        result /= (sum_fix_vec_1 + sum_fix_vec_2)

    return result

def build_vector(exp_id, trial_id, eye_events):
    # Filter eye events for the specified experiment and trial
    filtered_events = eye_events[
        (eye_events['experiment_id'] == exp_id) &
        (eye_events['trial_id'] == trial_id) &
        (eye_events['eye_event_type'] == 'fixation')
    ]

    df = filtered_events[['x0', 'y0', 'duration']]
    df = df.rename(columns={'x0': 'start_x', 'y0': 'start_y'})
    df['duration'] = df['duration'] / 1000.0

    df = df.astype({'start_x': 'float64', 'start_y': 'float64', 'duration': 'float64'})
    return df.to_records(index=False)