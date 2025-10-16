import sys, os
import pandas as pd
import matplotlib.pyplot as plt

# set up paths
package_dir = os.path.dirname(os.path.abspath(__file__))
image_generation_dir = os.path.dirname(package_dir)
Playground_dir = os.path.dirname(image_generation_dir)
Code_dir = os.path.dirname(Playground_dir)
lib_path = os.path.join(Code_dir, "EMIP-Toolkit")
sys.path.append(lib_path)
os.chdir(lib_path)

# create output directory
output_dir = os.path.join(Playground_dir, "output")
os.makedirs(output_dir, exist_ok=True)

from emtk import parsers, visualization, util

def aimadi_gen(
    experiment_id: str,
    trial_id: str,
    eye_events: pd.DataFrame
):
    
    '''
    Generate eye-tracking visualization images from AIMadi dataset.
    :param experiment_id: Experiment ID to generate
    :param trial_id: Trial ID to generate (default: '1')
    :param sample_size: Sample size for parsing (default: 8)
    :param eye_events: Pre-parsed eye events DataFrame (optional)
    '''

    trial_data = eye_events.loc[(eye_events['experiment_id'] == experiment_id) & (eye_events['trial_id'] == trial_id)]

    # Check if trial data is empty
    if trial_data.empty:
        print(f"experiment_id={experiment_id}, trial_id={trial_id} No matching data")
        raise SystemExit("No matching data")

    output_path = os.path.join(output_dir, f"AIMadi_experiment_{experiment_id}_trial_{trial_id}_default.png")
    
    visualization.draw_trial(trial_data, draw_aoi = True, draw_number = True, draw_saccade=True, save_image = output_path)
