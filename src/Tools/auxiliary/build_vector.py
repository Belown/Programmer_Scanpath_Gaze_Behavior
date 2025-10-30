def build_vector(exp, eye_events):
    '''
    Build a fixation vector for the given experiment and trial from eye events DataFrame.

    :param: exp: Tuple of (experiment_id, trial_id)
    :param: eye_events: DataFrame containing eye event data

    :return: DataFrame with columns ['x0', 'y0', 'duration'] for fixations
    '''
    # Filter eye events for the specified experiment and trial
    exp_id, trial_id = exp
    filtered_events = eye_events.loc[
        (eye_events['experiment_id'] == exp_id) &
        (eye_events['trial_id'] == trial_id) &
        (eye_events['eye_event_type'] == 'fixation')
    ]

    df = filtered_events[['x0', 'y0', 'duration']].copy()

    df['duration'] = df['duration'] / 1000.0
    df = df.astype({'x0': 'float64', 'y0': 'float64', 'duration': 'float64'})
    return df.reset_index(drop=True)