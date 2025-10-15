import sys, os
import pandas as pd
import argparse
import matplotlib.pyplot as plt

# set up argument parser
parser = argparse.ArgumentParser(description="Generate eye-tracking visualization images from AIMadi dataset.")
parser.add_argument('-i', '--id', required=True, type=str, help='Experiment ID to generate')
parser.add_argument('-t', '--trial', type=str, default='1', help='Trial ID to generate (default: 1)')
parser.add_argument('-s', '--sample', type=int, default=8, help='Sample size for parsing (default: 8)')

# set up paths
AIMadi_dir = os.path.dirname(os.path.abspath(__file__))
Playground_dir = os.path.dirname(AIMadi_dir)
Code_dir = os.path.dirname(Playground_dir)
lib_path = os.path.join(Code_dir, "EMIP-Toolkit")
sys.path.append(lib_path)
os.chdir(lib_path)

# create output directory
output_dir = os.path.join(AIMadi_dir, "output")
os.makedirs(output_dir, exist_ok=True)

from emtk import parsers, visualization, util

def main():

    args = parser.parse_args()

    # parse the AIMadi dataset
    eye_events, _ = parsers.AlMadi(sample_size = args.sample)

    # get the experiment ids from args
    experiment_id = args.id

    # get the trial id from args
    trial_id = args.trial

    trial_data = eye_events.loc[(eye_events['experiment_id'] == experiment_id) & (eye_events['trial_id'] == trial_id)]

    # Check if trial data is empty
    if trial_data.empty:
        print(f"experiment_id={experiment_id}, trial_id={trial_id} No matching data")
        raise SystemExit("No matching data")

    output_path = os.path.join(output_dir, f"experiment_{experiment_id}_trial_{trial_id}_default.png")
    
    visualization.draw_trial(trial_data, draw_aoi = True, draw_number = True, draw_saccade=True, save_image = output_path)

if __name__ == "__main__":
    main()
