import pandas as pd

def build_vector_emip(exp, eye_events):
    '''
    Build a fixation vector for the given experiment and stimulus from eye events DataFrame for EMIP dataset.

    :param: exp: Tuple of (experiment_id, stimulus)
    :param: eye_events: DataFrame containing eye event data

    :return: DataFrame with columns ['x0', 'y0', 'duration'] for fixations
    '''
    # Filter eye events for the specified experiment and stimulus
    exp_id, stimulus_list = exp
    filtered_events = eye_events.loc[
        (eye_events['experiment_id'] == exp_id) &
        (eye_events['stimulus'].isin(stimulus_list)) &
        (eye_events['eye_event_type'] == 'fixation')
    ]

    df = filtered_events[['x0', 'y0', 'duration']].copy()

    df['duration'] = df['duration'] / 1000.0
    df = df.astype({'x0': 'float64', 'y0': 'float64', 'duration': 'float64'})
    return df.reset_index(drop=True)

def build_vector_cr(path):
    '''
    Build a fixation vector for the Code Rendering dataset.
    
    :param path: Path to the data file

    :return: Tuple contain expertise and DataFrame with columns ['start_x', 'start_y', 'duration'] for fixations
    '''

    data = pd.read_csv(path)
    expertise = data['expertise'].iloc[0]
    render = data['render'].iloc[0]
    id = data['session_id'].iloc[0]
    code = data['code'].iloc[0]

    df = data[['location_x', 'location_y', 'duration']].copy()
    df = df.rename(columns={'location_x': 'start_x', 'location_y': 'start_y'})
    df = df.astype({'start_x': 'float64', 'start_y': 'float64', 'duration': 'float64'})
    df['duration'] = df['duration'] / 1000.0
    result = df.reset_index(drop=True)
    return expertise, render, id, result, code