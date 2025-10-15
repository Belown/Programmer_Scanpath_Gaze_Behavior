import sys, os
import pandas as pd
import argparse, json
import matplotlib.pyplot as plt

# set up argument parser
parser = argparse.ArgumentParser(description="Generate eye-tracking visualization images from McChesney dataset based on query.")

# format of the visualization to generate
parser.add_argument('-he','--heatmap', action='store_true', help='Generate Heatmap')
parser.add_argument('-fd', '--fixation_duration', action='store_true', help='Generate duration of fixation on each line')
parser.add_argument('-ft', '--fixation_timeline', action='store_true', help='Generate eye movement across lines through time')
parser.add_argument('-a', action='store_true', help='Generate all kind of graphs')
# experiment_id, trial_id and sample size for parsing
parser.add_argument('-i', '--id', type=str, default='P131', help='Experiment ID to generate (default: 1)')
parser.add_argument('-t', '--trial', type=str, default='2', help='Trial ID to generate (default: 2)')
parser.add_argument('-s', '--sample', type=int, default=3, help='Sample size for parsing (default: 3)')

# set up paths
EMIP_dir = os.path.dirname(os.path.abspath(__file__))
Playground_dir = os.path.dirname(EMIP_dir)
Code_dir = os.path.dirname(Playground_dir)
lib_path = os.path.join(Code_dir, "EMIP-Toolkit")
sys.path.append(lib_path)
os.chdir(lib_path)

# create output directory
output_dir = os.path.join(EMIP_dir, "output")
os.makedirs(output_dir, exist_ok=True)

from emtk import parsers, visualization, util, aoi

def main():
    
    args = parser.parse_args()

    # parse the McChesney dataset
    eye_events, samples = parsers.McChesney(sample_size = args.sample)

    # default experiment_id: P131
    experiment_id = args.id

    # default trial_id: 2
    trial_id = args.trial

    trial_data = eye_events.loc[(eye_events['experiment_id'] == experiment_id) & 
                            (eye_events['trial_id'] == trial_id)]

    samples_data = samples.loc[(samples['experiment_id'] == experiment_id) & 
                                (samples['trial_id'] == trial_id)]


    # Check if data is empty
    if trial_data.empty or samples_data.empty:
        print(f"experiment_id={experiment_id}, trial_id={trial_id} No matching data")
        raise SystemExit("No matching data")

    # basefile name
    base_filename = f"experiment_{experiment_id}_trial_{trial_id}"

    if args.a or (args.he and args.fd and args.ft):
        store_all_graphs(trial_data, samples_data, output_dir, base_filename)
    elif args.he:
        output_path = os.path.join(output_dir, f"{base_filename}_heatmap.png")
        heatmap_graph(trial_data, output_path)
    elif args.fd:
        output_path = os.path.join(output_dir, f"{base_filename}_fixation_duration.png")
        fixation_duration_graph(trial_data, output_path)
    elif args.ft:
        output_path = os.path.join(output_dir, f"{base_filename}_fixation_timeline.png")
        time_line_graph(trial_data, output_path)
    else:
        output_path = os.path.join(output_dir, f"{base_filename}_default.png")
        default_graph(trial_data, samples_data, output_path)

def store_all_graphs(trial_data, samples_data, output_dir, base_filename):
    heatmap_path = os.path.join(output_dir, f"{base_filename}_heatmap.png")
    heatmap_graph(trial_data, heatmap_path)

    fixation_duration_path = os.path.join(output_dir, f"{base_filename}_fixation_duration.png")
    fixation_duration_graph(trial_data, fixation_duration_path)

    time_line_path = os.path.join(output_dir, f"{base_filename}_time_line.png")
    time_line_graph(trial_data, time_line_path)

    default_path = os.path.join(output_dir, f"{base_filename}_default.png")
    default_graph(trial_data, samples_data, default_path)

def default_graph(trial_data, samples_data, output_path):
    visualization.draw_trial(trial_data, samples_data, draw_raw_data = True, draw_fixation=True,
                        draw_aoi=True, sample_x_col="Gaze point X [DACS px]", 
                        sample_y_col="Gaze point Y [DACS px]", save_image = output_path)

def heatmap_graph(trial_data, output_path):
    visualization.heatmap(trial_data)
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()

def fixation_duration_graph(trial_data, output_path):
    img = visualization.fixation_duration(trial_data, unit_height = .01)
    img.save(output_path)

def time_line_graph(trial_data, output_path):
    visualization.fixation_timeline(trial_data)
    plt.savefig(output_path, dpi=300, bbox_inches='tight')

if __name__ == "__main__":
    main()