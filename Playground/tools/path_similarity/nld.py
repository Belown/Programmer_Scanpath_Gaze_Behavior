import pandas as pd
import os, sys, math
import numpy as np
# fixaiton are already process with idt, so no need to reduct jitter

path_similarity_path = os.path.dirname(os.path.abspath(__file__))
tools_path = os.path.dirname(path_similarity_path)
playground_path = os.path.dirname(tools_path)
home_path = os.path.dirname(playground_path)
lib_path = os.path.join(home_path, "EMIP-Toolkit")

sys.path.append(lib_path)
os.chdir(lib_path)
from emtk import parsers, visualization, util, aoi

def nld(
    exp_a: tuple,
    exp_b: tuple,
    eye_events: pd.DataFrame
):
    '''
    Compute Normalized Levenshtein Distance (NLD) between two scanpaths based on AOI sequence
    :param exp_a: Tuple of (experiment_id, trial_id) for first scanpath
    :param exp_b: Tuple of (experiment_id, trial_id) for second scanpath
    :param eye_events: Parsed data frame for eye event
    :return: distance, nld
    '''

    vec_a = build_vector(exp_a, eye_events)
    vec_b = build_vector(exp_b, eye_events)

    if vec_a.size == 0 or vec_b.size == 0:
        print("No matching data")
        raise SystemExit("No matching data")

    m = len(vec_a)
    n = len(vec_b)

    if m == 0 and n == 0:
        return 0.0
    elif m == 0:
        return n, 1.0
    elif n == 0:
        return m, 1.0
    else:
        dp = np.zeros((m + 1, n + 1), dtype=float)
        for i in range(m+1):
            dp[i][0] = i
        for j in range(n+1):
            dp[0][j] = j

        for i in range(1, m+1):
            for j in range(1, n+1):
                aoi_a = vec_a[i-1]['aoi_name']
                aoi_b = vec_b[j-1]['aoi_name']
                if pd.isna(aoi_a) or pd.isna(aoi_b):
                    cost = 1.0
                elif aoi_a == aoi_b:
                    cost = 0.0
                else:
                    cost = 1.0
                dp[i][j] = min(
                    dp[i][j-1] + 1,      # deletion
                    dp[i-1][j] + 1,      # insertion
                    dp[i-1][j-1] + cost  # substitution
                )
        distance = dp[m][n]
        nld = distance / max(m, n)
        return distance, nld


def build_vector(exp, eye_events):
    aoi_fixation = get_fixation_aoi(exp, eye_events)

    exp_id, trial_id = exp
    filtered_events = aoi_fixation.loc[
        (aoi_fixation['experiment_id'] == exp_id) & 
        (aoi_fixation['trial_id'] == trial_id),
    ]

    df = filtered_events[['timestamp', 'duration', 'x0', 'y0', 'aoi_name', 'aoi_x', 'aoi_y']]
    return df.to_records(index=False)

def get_fixation_aoi(exp, eye_events):
    exp_id, trial_id = exp
    trial_data = get_trial_data(eye_events, exp_id, trial_id)
    trial_data_fixation = trial_data.loc[trial_data['eye_event_type'] == 'fixation']
    aoi_data = get_aoi(eye_events, exp_id, trial_id)
    return aoi.hit_test(trial_data_fixation, aoi_data, radius = 25)

def get_aoi(eye_events, exp_id, trial_id):
    trial_data = get_trial_data(eye_events, exp_id, trial_id)
    return aoi.find_aoi(trial_data)

def get_trial_data(eye_events, exp_id, trial_id):
    return eye_events.loc[(eye_events['experiment_id'] == exp_id) & 
                            (eye_events['trial_id'] == trial_id)]

