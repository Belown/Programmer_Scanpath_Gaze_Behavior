import pandas as pd
import numpy as np
from emtk import aoi

def nld(
    exp_a: tuple,
    exp_b: tuple,
    eye_events: pd.DataFrame,
    data_set: str = None
):
    '''
    Compute Normalized Levenshtein Distance (NLD) between two scanpaths based on AOI sequence

    :param: exp_a: Tuple of (experiment_id, trial_id) for first scanpath
    :param: exp_b: Tuple of (experiment_id, trial_id) for second scanpath
    :param: eye_events: Parsed data frame for eye event (Can be either corrected EMIP or original EMIP)
    :param: data_set: Specify which data that is used: "corrected" or "original"

    :return: distance, nld
    '''
    if data_set == "corrected":
        # Because corrected data alread have AOI information, we can directly use get_trial_data
        fix_vec1 = get_trial_data(eye_events, exp_a)
        fix_vec2 = get_trial_data(eye_events, exp_b)

        # Select only necessary columns
        fix_vec1 = fix_vec1[['timestamp', 'duration', 'x0', 'y0', 'aoi_name', 'aoi_x', 'aoi_y']]
        fix_vec2 = fix_vec2[['timestamp', 'duration', 'x0', 'y0', 'aoi_name', 'aoi_x', 'aoi_y']]

    elif data_set == "original":
        fix_vec1 = build_vector_nld(exp_a, eye_events)
        fix_vec2 = build_vector_nld(exp_b, eye_events)

    else:
        raise ValueError("data_set must be either 'corrected' or 'original'")

    distance, nld = nld_helper(fix_vec1, fix_vec2)

    return {
        "distance": distance,
        "score": nld,
    }

def nld_helper(
    df1,
    df2
):
    """
    Compute the Normalized Levenshtein Distance (NLD) between two dataframes.

    :param: df1: First DataFrame containing AOI sequences.
    :param: df2: Second DataFrame containing AOI sequences.

    :return: Tuple of (distance, nld).
    """
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
    """
    Build a vector for NLD computation from eye event data.

    :param: exp: Tuple of (experiment_id, trial_id) for the experiment.
    :param: eye_events: DataFrame containing eye event data.

    :return: DataFrame with fixation data and AOI information.
    """
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
    """
    Get fixation data with AOI information for a given experiment.

    :param: exp: Tuple of (experiment_id, trial_id) for the experiment.
    :param: eye_events: DataFrame containing eye event data.

    :return: DataFrame with fixation data and AOI information.
    """
    trial_data = get_trial_data(eye_events, exp)
    trial_data_fixation = trial_data.loc[trial_data['eye_event_type'] == 'fixation']
    aoi_data = aoi.find_aoi(trial_data)
    return aoi.hit_test(trial_data_fixation, aoi_data, radius = 25)

def get_trial_data(eye_events, exp):
    """
    Retrieve trial data for a specific experiment from eye events.

    :param: eye_events: DataFrame containing eye event data.
    :param: exp: Tuple of (experiment_id, trial_id) for the experiment.

    :return: DataFrame with trial data.
    """
    exp_id, trial_id = exp
    return eye_events.loc[(eye_events['experiment_id'] == exp_id) & 
                            (eye_events['trial_id'] == trial_id)]