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

def nld_for_corrected(
    exp_a: tuple,
    exp_b: tuple,
    eye_events: pd.DataFrame
):
    '''
    Compute Normalized Levenshtein Distance (NLD) between two scanpaths based on line and part
    :param exp_a: Tuple of (experiment_id, trial_id) for first scanpath
    :param exp_b: Tuple of (experiment_id, trial_id) for second scanpath
    :param eye_events: Parsed data frame for eye event
    :return: distance, nld
    '''

    exp_id_a, trial_id_a = exp_a
    exp_id_b, trial_id_b = exp_b
    
    vec_a = build_vector(exp_id_a, trial_id_a, eye_events)
    vec_b = build_vector(exp_id_b, trial_id_b, eye_events)

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
                # Check if both line and part fields exist in the records
                if 'line' in vec_a.dtype.names and 'part' in vec_a.dtype.names and \
                   'line' in vec_b.dtype.names and 'part' in vec_b.dtype.names:
                    line_a = vec_a[i-1]['line']
                    part_a = vec_a[i-1]['part']
                    line_b = vec_b[j-1]['line']
                    part_b = vec_b[j-1]['part']
                    
                    # Check for NaN values
                    if pd.isna(line_a) or pd.isna(part_a) or pd.isna(line_b) or pd.isna(part_b):
                        cost = 1.0
                    # Compare both line and part - only if both match, cost is 0
                    elif line_a == line_b and part_a == part_b:
                        cost = 0.0
                    else:
                        cost = 1.0
                else:
                    # Fallback to coordinate-based comparison if line/part not available
                    print("Warning: 'line' or 'part' fields not available for comparison")
                    cost = 1.0  # Default to different if we can't compare
                
                dp[i][j] = min(
                    dp[i][j-1] + 1,      # deletion
                    dp[i-1][j] + 1,      # insertion
                    dp[i-1][j-1] + cost  # substitution
                )
        distance = dp[m][n]
        nld = distance / max(m, n)
        return distance, nld

def build_vector(exp_id, trial_id, eye_events):
    # Filter eye events for the specified experiment and trial
    filtered_events = eye_events.loc[
        (eye_events['experiment_id'] == exp_id) &
        (eye_events['trial_id'] == trial_id) &
        (eye_events['eye_event_type'] == 'fixation')
    ]

    # Select the required columns, including the new ones
    columns_to_select = ['x0', 'y0', 'duration']
    
    # Check if additional columns exist and include them
    additional_columns = ['aoi_x', 'aoi_y', 'line', 'part']
    
    # Check specifically for 'line' and 'part' as they're critical now
    if 'line' not in filtered_events.columns:
        print("Critical warning: 'line' column not found in data - NLD comparison may not work correctly")
    if 'part' not in filtered_events.columns:
        print("Critical warning: 'part' column not found in data - NLD comparison may not work correctly")
    
    for col in additional_columns:
        if col in filtered_events.columns:
            columns_to_select.append(col)
        else:
            print(f"Warning: Column '{col}' not found in data")
    
    df = filtered_events[columns_to_select]
    df = df.rename(columns={'x0': 'start_x', 'y0': 'start_y'})
    df['duration'] = df['duration'] / 1000.0  # Convert to seconds

    # Ensure all numeric columns have the correct data types
    float_columns = ['start_x', 'start_y', 'duration']
    for col in float_columns:
        df[col] = df[col].astype('float64')
    
    # Convert additional columns to appropriate types if they exist
    for col in ['aoi_x', 'aoi_y']:
        if col in df.columns:
            df[col] = df[col].astype('float64')
    
    return df.to_records(index=False)