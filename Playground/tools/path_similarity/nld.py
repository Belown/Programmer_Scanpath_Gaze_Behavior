import pandas as pd
import os, sys
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

    aoi_fixation_a = get_fixation_aoi(exp_a, eye_events)
    aoi_fixation_b = get_fixation_aoi(exp_b, eye_events)

    return build_vector(exp_a, aoi_fixation_a)

def build_vector(exp, aoi_fixation_a):
    exp_id, trial_id = exp
    df = aoi_fixation_a.loc[
        (aoi_fixation_a['experiment_id'] == exp_id) & 
        (aoi_fixation_a['trial_id'] == trial_id),
        ['timestamp', 'duration', 'x0', 'y0', 'aoi_name', 'aoi_x', 'aoi_y']
    ]

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

