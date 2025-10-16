import sys, os, json
import pandas as pd
import matplotlib.pyplot as plt
from typing import Optional

# set up paths
package_path = os.path.dirname(os.path.abspath(__file__))
image_generation_dir = os.path.dirname(package_path)
Playground_dir = os.path.dirname(image_generation_dir)
Home_dir = os.path.dirname(Playground_dir)
lib_path = os.path.join(Home_dir, "EMIP-Toolkit")
metadata_file = os.path.join(lib_path, "emtk", "datasets", "EMIP", "EMIP-Toolkit- replication package", "emip_dataset", "emip_metadata.csv")
sys.path.append(lib_path)
os.chdir(lib_path)

# create output directory
output_dir = os.path.join(Playground_dir, "output")
os.makedirs(output_dir, exist_ok=True)

from emtk import parsers, visualization, util, aoi

def emip_gen(
    experiment_id: str,
    trial_id: str, # default trial_id: 2 for vehicle, 5 for rectangle
    eye_events: pd.DataFrame,
    samples: pd.DataFrame,
    query: bool = False,
    image_type: Optional[str] = None, # "heatmap", "fixation_duration", "fixation_timeline", "all"
):
    
    '''
    Generate eye-tracking visualization images from EMIP dataset.
    :param experiment_id: Experiment ID to generate
    :param trial_id: Trial ID to generate (default: '2')
    :param sample_size: Sample size for parsing (default: 8)
    :param query: Use query to determine experiment ids (then experiment_id is ignored)
    :param image_type: Type of image to generate. Options are "heatmap", "fixation_duration", "fixation_timeline", "all". If None, generates default graph.
    :param eye_events: Pre-parsed eye events DataFrame. If None, will parse the data.
    :param samples: Pre-parsed samples DataFrame. If None, will parse the data
    '''

    if query:
        # read metadata from EMIP dataset
        metadata = pd.read_csv(metadata_file)

        query_file = os.path.join(package_path, "emip_query.json")

        try:
            with open(query_file, 'r') as f:
                input_dict = json.load(f)
        except FileNotFoundError:
            print(f"Query file {query_file} not found. Using default query parameters.")
            raise SystemExit("Query file not found")

        # add masks to filter experiment ids
        condition = pd.Series([True] * len(metadata))
        for key, value in input_dict.items():
            if value:
                condition &= (metadata[key] == value)
        result = metadata[condition]
        experiment_ids = result["id"].tolist()
    else:
        experiment_ids = [experiment_id]
    
    # iterate through all experiment ids and generate graphs
    for experiment_id in experiment_ids:
        # convert to string for matching
        exp_id_str = str(experiment_id)

        trial_data = eye_events.loc[
            (eye_events['experiment_id'] == exp_id_str) &
            (eye_events['trial_id'] == trial_id)
        ]
        samples_data = samples.loc[
            (samples['experiment_id'] == exp_id_str) &
            (samples['trial_id'] == trial_id)
        ]

        # Check if data is empty
        if trial_data.empty or samples_data.empty:
            print(f"experiment_id={experiment_id}, trial_id={trial_id} No matching data")
            continue

        # basefile name
        base_filename = f"EMIP_experiment_{experiment_id}_trial_{trial_id}"
        if image_type == "all":
            store_all_graphs(trial_data, samples_data, output_dir, base_filename)
        elif image_type == "heatmap":
            output_path = os.path.join(output_dir, f"{base_filename}_heatmap.png")
            heatmap_graph(trial_data, output_path)
        elif image_type == "fixation_duration":
            output_path = os.path.join(output_dir, f"{base_filename}_fixation_duration.png")
            fixation_duration_graph(trial_data, output_path)
        elif image_type == "fixation_timeline":
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
    plt.close()

def fixation_duration_graph(trial_data, output_path):
    img = visualization.fixation_duration(trial_data)
    img.save(output_path)

def time_line_graph(trial_data, output_path):
    visualization.fixation_timeline(trial_data)
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()

