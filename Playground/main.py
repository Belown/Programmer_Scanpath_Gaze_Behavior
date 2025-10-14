import sys, os
import pandas as pd
import argparse
import matplotlib.pyplot as plt

# set up paths
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
lib_path = os.path.join(parent_dir, "EMIP-Toolkit")
program_path = os.path.join(parent_dir, "Playground")
metadata_file = os.path.join(lib_path, "emtk", "datasets", "EMIP", "EMIP-Toolkit- replication package", "emip_dataset", "emip_metadata.csv")
sys.path.append(lib_path)
os.chdir(lib_path)

# create output directory
output_dir = os.path.join(program_path, "output")
os.makedirs(output_dir, exist_ok=True)

from emtk import parsers, visualization, util, aoi

def main():
    parser = argparse.ArgumentParser(description="Process EMIP dataset and visualize trials.")
    parser.add_argument('-he', action='store_true', help='Generate Heatmap')
    parser.add_argument('-fd', action='store_true', help='Generate duration of fixation on each line')
    parser.add_argument('-ft', action='store_true', help='Generate eye movement across lines through time')
    parser.add_argument('-a', action='store_true', help='Generate all kind of graphs')
    
    args = parser.parse_args()

    # read metadata from EMIP dataset
    metadata = pd.read_csv(metadata_file)

    # parse the EMIP dataset
    eye_events, samples = parsers.EMIP(sample_size = 8)

    # default trial_id: 2 for vehicle, 5 for rectangle
    trial_id = 2 

    # construct the input_dict for query in metadata
    input_dict = {
        "gender": "female",
        "mother_tongue": "Chinese",
    }

    # add masks to filter experiment ids
    condition = pd.Series([True] * len(metadata))
    for key, value in input_dict.items():
        condition &= (metadata[key] == value)

    result = metadata[condition]
    experiment_ids = result["id"].tolist()

    for experiment_id in experiment_ids:
        # convert to string for matching
        exp_id_str = str(experiment_id)
        trial_id_str = str(trial_id)

        trial_data = eye_events.loc[
            (eye_events['experiment_id'] == exp_id_str) &
            (eye_events['trial_id'] == trial_id_str)
        ]
        samples_data = samples.loc[
            (samples['experiment_id'] == exp_id_str) &
            (samples['trial_id'] == trial_id_str)
        ]

        # Check if data is empty
        if trial_data.empty or samples_data.empty:
            print(f"experiment_id={experiment_id}, trial_id={trial_id} No matching data")
            continue

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
    visualization.draw_trial(
            trial_data, samples_data, draw_raw_data=True, draw_aoi=True, draw_saccade=True,
            sample_x_col="R POR X [px]", sample_y_col="R POR Y [px]",
            save_image = output_path
    )

def heatmap_graph(trial_data, output_path):
    visualization.heatmap(trial_data)
    plt.savefig(output_path, dpi=300, bbox_inches='tight')

def fixation_duration_graph(trial_data, output_path):
    img = visualization.fixation_duration(trial_data)
    img.save(output_path)

def time_line_graph(trial_data, output_path):
    visualization.fixation_timeline(trial_data)
    plt.savefig(output_path, dpi=300, bbox_inches='tight')

if __name__ == "__main__":
    main()
