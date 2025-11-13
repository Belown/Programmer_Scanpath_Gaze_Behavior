import sys, os
import pandas as pd
import matplotlib.pyplot as plt
from ..path import setup_paths
from emtk import visualization

# set up paths
paths = setup_paths()
output_dir = os.path.join(paths["output_path"], "dataset_images", "aimadi")
os.makedirs(output_dir, exist_ok=True)

def aimadi_gen(
    experiment_id: str,
    trial_id: str,
    eye_events: pd.DataFrame
):
    
    '''
    Generate eye-tracking visualization images from AIMadi dataset.

    :param: experiment_id: Experiment ID to generate
    :param: trial_id: Trial ID to generate (default: '1')
    :param: eye_events: Pre-parsed eye events DataFrame

    :return: None
    '''
    # Filter eye_events for the specified experiment_id and trial_id
    trial_data = eye_events.loc[(eye_events['experiment_id'] == experiment_id) & (eye_events['trial_id'] == trial_id)]

    # Check if trial data is empty
    if trial_data.empty:
        print(f"experiment_id={experiment_id}, trial_id={trial_id} No matching data")
        raise SystemExit("No matching data")

    # Generate output path
    output_path = os.path.join(output_dir, f"{experiment_id}_trial_{trial_id}_default.png")
    
    # Display and save the visualization
    visualization.draw_trial(trial_data, draw_aoi = True, draw_number = True, draw_saccade=True, save_image = output_path)
