import pandas as pd
import numpy as np
from emtk import aoi
from ..auxiliary import parse_corrected_emip_data, gen_random_fixations

def nld(
    exp_a: tuple,
    exp_b: tuple,
    eye_events: pd.DataFrame,
    data_set: str = None
):
    '''
    Compute Normalized Levenshtein Distance (NLD) between two scanpaths based on AOI sequence

    :param exp_a: Tuple of (experiment_id, trial_id) for first scanpath
    :param exp_b: Tuple of (experiment_id, trial_id) for second scanpath
    :param eye_events: Parsed data frame for eye event
    :param data_set: Specify which data set to use: "corrected" or "original"
    :return: distance, nld
    '''
    if data_set == "corrected":
        parsed_data = parse_corrected_emip_data()
        fix_vec1 = build_vector_nld(exp_a, parsed_data, data_set)
        fix_vec2 = build_vector_nld(exp_b, parsed_data, data_set)
    elif data_set == "original":
        fix_vec1 = build_vector_nld(exp_a, eye_events, data_set)
        fix_vec2 = build_vector_nld(exp_b, eye_events, data_set)
    else:
        raise ValueError("data_set must be either 'corrected' or 'original'")
    
    random_vec1 = gen_random_fixations(len(fix_vec1))
    random_vec2 = gen_random_fixations(len(fix_vec2))

    original_distance, original_nld = nld_helper(fix_vec1, fix_vec2)
    base_line_distance, base_line_nld = nld_helper(random_vec1, random_vec2,if_random=True)
    final_distance = original_distance - base_line_distance
    final_nld = original_nld - base_line_nld

    return {
        "original_distance": original_distance,
        "original_nld": original_nld,
        "base_line_distance": base_line_distance,
        "base_line_nld": base_line_nld,
        "final_distance": final_distance,
        "final_nld": final_nld
    }
    
def nld_helper(
    fix_vec1,
    fix_vec2
):
    if fix_vec1.size == 0 or fix_vec2.size == 0:
        print("No matching data")
        raise SystemExit("No matching data")

    m = len(fix_vec1)
    n = len(fix_vec2)

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
                aoi_a = fix_vec1[i-1]['aoi_name']
                aoi_b = fix_vec2[j-1]['aoi_name']
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
    


def build_vector_nld(exp, eye_events, if_random=False):
    temp = get_fixation_aoi(exp, eye_events)

    exp_id, trial_id = exp
    filtered_events = temp.loc[
        (temp['experiment_id'] == exp_id) & 
        (temp['trial_id'] == trial_id),
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

