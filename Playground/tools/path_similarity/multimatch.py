import multimatch_gaze as m
import numpy as np
import sys, os, json
import pandas as pd

# set up path
package_path = os.path.dirname(os.path.abspath(__file__))
path_similarity_dir = os.path.dirname(package_path)
Playground_dir = os.path.dirname(path_similarity_dir)
Home_dir = os.path.dirname(Playground_dir)
lib_path = os.path.join(Home_dir, "EMIP-Toolkit")

# sys.path.append(lib_path)
# os.chdir(lib_path)
# from emtk import parsers, visualization, util, aoi

# create output directory
output_dir = os.path.join(Playground_dir, "output")
os.makedirs(output_dir, exist_ok=True)


def multimatch(
    exp_a: tuple,
    exp_b: tuple,
    eye_events: pd.DataFrame
):
    '''
    Compute scanpath similarity by using the library multimatch_gaze
    :param exp_a: Tuple of (experiment_id, trial_id) for first scanpath
    :param exp_b: Tuple of (experiment_id, trial_id) for second scanpath
    :param eye_events: Parsed data frame for eye event
    '''
    exp_id_str_a, trial_id_str_a = exp_a
    exp_id_str_b, trial_id_str_b = exp_b

    fix_vec1 = build_vector(exp_id_str_a, trial_id_str_a, eye_events)
    fix_vec2 = build_vector(exp_id_str_b, trial_id_str_b, eye_events)

    score = m.docomparison(fix_vec1, fix_vec2, screensize=[1920, 1080])

    score_names = ["Shape", "Length", "Direction", "Position", "Duration"]
    score_dict = {}
    if isinstance(score, list) and len(score) == 1 and isinstance(score[0], list):
        for name, val in zip(score_names, score[0]):
            score_dict[name] = val
    else:
        for name, val in zip(score_names, score):
            score_dict[name] = val

    output = {
        "exp_id_str_a": exp_id_str_a,
        "trial_id_str_a": trial_id_str_a,
        "exp_id_str_b": exp_id_str_b,
        "trial_id_str_b": trial_id_str_b,
        "score": score_dict
    }
    output_path = os.path.join(output_dir, "multimatch_output.json")
    with open(output_path, "w") as f:
        json.dump(output, f, indent=2)
    print(f"Results saved to {output_path}")

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