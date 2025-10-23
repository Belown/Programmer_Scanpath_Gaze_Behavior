import sys, os, json
import pandas as pd
import matplotlib.pyplot as plt
from typing import Optional
from tools import setup_paths
from emtk import parsers, visualization, util, aoi

# set up paths
paths = setup_paths()
metadata_file = paths["metadata_file"]
query_path = paths["query_path"]
output_dir = paths["output_path"]


def emip_gen(
    exp: tuple,
    eye_events: pd.DataFrame,
    samples: pd.DataFrame,
    query: bool = False,
    image_type: Optional[str] = None, # "heatmap", "fixation_duration", "fixation_timeline", "all"
):
    
    '''
    Generate eye-tracking visualization images from EMIP dataset.
    :param exp: Tuple of (experiment_id, trial_id) to generate images for
    :param eye_events: Pre-parsed eye events DataFrame. If None, will parse the data.
    :param samples: Pre-parsed samples DataFrame.
    :param query: Use query to determine experiment ids (then experiment_id is ignored)
    :param image_type: Type of image to generate. Options are "heatmap", "fixation_duration", "fixation_timeline", "all". If None, generates default graph.
    '''
    if eye_events is None or not isinstance(eye_events, pd.DataFrame) or eye_events.empty:
        raise ValueError("eye_events is required and must be a non-empty pandas.DataFrame")
    if samples is None or not isinstance(samples, pd.DataFrame) or samples.empty:
        raise ValueError("samples is required and must be a non-empty pandas.DataFrame")
    
    experiment_id, trial_id = exp

    if query:
        # read metadata from EMIP dataset
        metadata = pd.read_csv(metadata_file)

        try:
            with open(query_path, 'r') as f:
                input_dict = json.load(f)
        except FileNotFoundError:
            print(f"Query file {query_path} not found. Using default query parameters.")
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

