import multimatch_gaze as m
import numpy as np
import sys, os, json
import pandas as pd

# set up path
EMIP_dir = os.path.dirname(os.path.abspath(__file__))
Playground_dir = os.path.dirname(EMIP_dir)
Code_dir = os.path.dirname(Playground_dir)
lib_path = os.path.join(Code_dir, "EMIP-Toolkit")

sys.path.append(lib_path)
os.chdir(lib_path)
from emtk import parsers, visualization, util, aoi


def main():
    # Example usage of the multimatch_gaze library

    exp_id_str_a = "100"  # Example experiment ID
    trial_id_str_a = "2"    # Example trial ID
    exp_id_str_b = "101"  # Example experiment ID
    trial_id_str_b = "2"    # Example trial ID

    eye_events, _ = parsers.EMIP(sample_size = 8)
    fix_vector1 = build_vector(exp_id_str_a, trial_id_str_a, eye_events)
    fix_vector2 = build_vector(exp_id_str_b, trial_id_str_b, eye_events)

    score = m.docomparison(fix_vector1, fix_vector2, screensize=[1920, 1080])
    print(f"Multimatch score: {score}")

    score_names = ["Shape", "Length", "Direction", "Position", "Duration"]
    score_dict = {name: float(val) for name, val in zip(score_names, score)}

    output = {
        "exp_id_str_a": exp_id_str_a,
        "trial_id_str_a": trial_id_str_a,
        "exp_id_str_b": exp_id_str_b,
        "trial_id_str_b": trial_id_str_b,
        "score": score_dict
    }
    output_path = os.path.join(os.path.dirname(__file__), "multimatch_output.json")
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

if __name__ == "__main__":
    main()