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
        fix_vec1 = eye_events.loc[(eye_events['experiment_id'] == exp_a[0]) & (eye_events['trial_id'] == exp_a[1])]
        fix_vec2 = eye_events.loc[(eye_events['experiment_id'] == exp_b[0]) & (eye_events['trial_id'] == exp_b[1])]

        fix_vec1 = fix_vec1[['timestamp', 'duration', 'x0', 'y0', 'aoi_name', 'aoi_x', 'aoi_y']]
        fix_vec2 = fix_vec2[['timestamp', 'duration', 'x0', 'y0', 'aoi_name', 'aoi_x', 'aoi_y']]

        random_vec1 = gen_random_fixations(len(fix_vec1))
        random_vec2 = gen_random_fixations(len(fix_vec2))

        final_v1 = random_helper(exp_a, eye_events, random_vec1)
        final_v2 = random_helper(exp_b, eye_events, random_vec2)


    elif data_set == "original":
        fix_vec1 = build_vector_nld(exp_a, eye_events)
        fix_vec2 = build_vector_nld(exp_b, eye_events)
        random_vec1 = gen_random_fixations(len(fix_vec1))
        random_vec2 = gen_random_fixations(len(fix_vec2))

        final_v1 = random_helper(exp_a, eye_events, random_vec1)
        final_v2 = random_helper(exp_b, eye_events, random_vec2)

    else:
        raise ValueError("data_set must be either 'corrected' or 'original'")

    original_distance, original_nld = nld_helper(fix_vec1, fix_vec2)
    base_line_distance, base_line_nld = nld_helper(final_v1, final_v2)
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

def random_helper(exp, eye_events, random_vec):
    trial_data = get_trial_data(eye_events, exp[0], exp[1])
    random_trial_data = gen_random_baseline_from_template(trial_data, random_vec)
    if 'participant_id' not in random_trial_data.columns:
        random_trial_data['participant_id'] = exp[0]
    if 'filename' not in random_trial_data.columns:
        random_trial_data['filename'] = f"{exp[0]}_rawdata.tsv"  # 生成默认文件名
    aoi_data = aoi.find_aoi(random_trial_data)
    result = aoi.hit_test(random_trial_data, aoi_data, radius = 25)
    result = result[['timestamp', 'duration', 'x0', 'y0', 'aoi_name', 'aoi_x', 'aoi_y']]
    return result

def nld_helper(
    df1,
    df2
):
    # empty checks
    if df1.empty and df2.empty:
        return 0.0, 0.0
    if df1.empty:
        return len(df2), 1.0
    if df2.empty:
        return len(df1), 1.0

    m = len(df1)
    n = len(df2)

    dp = np.zeros((m + 1, n + 1), dtype=float)
    for i in range(m + 1):
        dp[i][0] = i
    for j in range(n + 1):
        dp[0][j] = j

    # use .iat for positional access (faster)
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            aoi_a = df1['aoi_name'].iat[i - 1]
            aoi_b = df2['aoi_name'].iat[j - 1]
            if pd.isna(aoi_a) or pd.isna(aoi_b):
                cost = 1.0
            elif aoi_a == aoi_b:
                cost = 0.0
            else:
                cost = 1.0
            dp[i][j] = min(
                dp[i][j - 1] + 1,      # deletion
                dp[i - 1][j] + 1,      # insertion
                dp[i - 1][j - 1] + cost  # substitution
            )

    distance = dp[m][n]
    nld = distance / max(m, n) if max(m, n) > 0 else 0.0
    return distance, nld
    
def build_vector_nld(exp, eye_events):
    temp = get_fixation_aoi(exp, eye_events)

    # if hit_test returned a numpy structured/recarray, convert to DataFrame
    if isinstance(temp, np.ndarray) and getattr(temp, "dtype", None) and temp.dtype.names is not None:
        temp_df = pd.DataFrame.from_records(temp)
    elif isinstance(temp, pd.DataFrame):
        temp_df = temp.copy()
    else:
        # unexpected type
        temp_df = pd.DataFrame(temp)

    exp_id, trial_id = exp
    filtered_events = temp_df.loc[
        (temp_df['experiment_id'] == exp_id) & 
        (temp_df['trial_id'] == trial_id),
    ]

    df = filtered_events[['timestamp', 'duration', 'x0', 'y0', 'aoi_name', 'aoi_x', 'aoi_y']]
    return df

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

def gen_random_baseline_from_template(fix_df, rand_df, rng=None):
    """
    Generate a random baseline using fix_vec as template:
    - preserve all fields from fix_vec except x0, y0, duration
    - replace x0, y0, duration with values from gen_random_fixations(len(fix_vec))
    """

    rand_df.rename(columns={'start_x': 'x0', 'start_y': 'y0'}, inplace=True)
    screensize = (1920, 1080)  # default screen size
    # empty input -> return same-type empty
    if fix_df is None:
        return fix_df
    n = len(fix_df)
    if n == 0:
        return fix_df.copy()

    out = fix_df.copy().reset_index(drop=True)
    rand_df = rand_df.reset_index(drop=True)

    margin_x = 0.05 * screensize[0]
    margin_y = 0.05 * screensize[1] 

    # replace fields if present in both template and generated vector
    for fld in ("x0", "y0", "duration"):
        if fld in out.columns and fld in rand_df.columns:
            out[fld] = rand_df[fld]
        elif fld in out.columns:
            print(f"Warning: field '{fld}' not in generated random vector; using fallback values.")
            # fallback sensible defaults if gen_random_fixations didn't provide the field
            if fld == "x0":
                out["x0"] = np.random.uniform(margin_x, screensize[0] - margin_x, size=n)
            elif fld == "y0":
                out["y0"] = np.random.uniform(margin_y, screensize[1] - margin_y, size=n)
            else:  # duration
                out["duration"] = np.random.uniform(800, 1500, size=n) / 1000.0

    return out
