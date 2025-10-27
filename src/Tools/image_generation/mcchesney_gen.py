import sys, os, json
import pandas as pd
import matplotlib.pyplot as plt
from typing import Optional
from ..path import setup_paths
from emtk import parsers, visualization, util, aoi

# set up paths
paths = setup_paths()
output_dir = paths["output_path"]


def mcchesney_gen(
    experiment_id: str,
    trial_id: str,
    eye_events: pd.DataFrame,
    samples: pd.DataFrame,
    image_type: Optional[str] = None, # "heatmap", "fixation_duration", "fixation_timeline", "all"
):
    '''
    Generate eye-tracking visualization images from McChesney dataset.

    :param: experiment_id: Experiment ID to generate (default: 'P131')
    :param: trial_id: Trial ID to generate (default: '2')
    :param: eye_events: Pre-parsed eye events DataFrame. If None, will parse the data.
    :param: samples: Pre-parsed samples DataFrame.
    :param: image_type: Type of image to generate. Options are "heatmap", "fixation_duration", "fixation_timeline", "all". If None, generates default graph.
    
    :return: None
    '''

    trial_data = eye_events.loc[(eye_events['experiment_id'] == experiment_id) & 
                            (eye_events['trial_id'] == trial_id)]

    samples_data = samples.loc[(samples['experiment_id'] == experiment_id) & 
                                (samples['trial_id'] == trial_id)]

    # Check if data is empty
    if trial_data.empty or samples_data.empty:
        print(f"experiment_id={experiment_id}, trial_id={trial_id} No matching data")
        raise SystemExit("No matching data")

    # basefile name
    base_filename = f"McChesney_experiment_{experiment_id}_trial_{trial_id}"

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
    """
    Generate and save all types of graphs for the given trial data.

    :param: trial_data: DataFrame containing trial data.
    :param: samples_data: DataFrame containing sample data.
    :param: output_dir: Directory where the graphs will be saved.
    :param: base_filename: Base filename for the saved graphs.

    :return: None
    """
    heatmap_path = os.path.join(output_dir, f"{base_filename}_heatmap.png")
    heatmap_graph(trial_data, heatmap_path)

    fixation_duration_path = os.path.join(output_dir, f"{base_filename}_fixation_duration.png")
    fixation_duration_graph(trial_data, fixation_duration_path)

    time_line_path = os.path.join(output_dir, f"{base_filename}_time_line.png")
    time_line_graph(trial_data, time_line_path)

    default_path = os.path.join(output_dir, f"{base_filename}_default.png")
    default_graph(trial_data, samples_data, default_path)

def default_graph(trial_data, samples_data, output_path):
    """
    Generate and save the default graph for the given trial and sample data.

    :param: trial_data: DataFrame containing trial data.
    :param: samples_data: DataFrame containing sample data.
    :param: output_path: Path where the graph will be saved.

    :return: None
    """
    visualization.draw_trial(trial_data, samples_data, draw_raw_data = True, draw_fixation=True,
                        draw_aoi=True, sample_x_col="Gaze point X [DACS px]", 
                        sample_y_col="Gaze point Y [DACS px]", save_image = output_path)

def heatmap_graph(trial_data, output_path):
    """
    Generate and save a heatmap graph for the given trial data.

    :param: trial_data: DataFrame containing trial data.
    :param: output_path: Path where the heatmap will be saved.

    :return: None
    """
    visualization.heatmap(trial_data)
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()

def fixation_duration_graph(trial_data, output_path):
    """
    Generate and save a fixation duration graph for the given trial data.

    :param: trial_data: DataFrame containing trial data.
    :param: output_path: Path where the graph will be saved.

    :return: None
    """
    img = visualization.fixation_duration(trial_data, unit_height = .01)
    img.save(output_path)

def time_line_graph(trial_data, output_path):
    """
    Generate and save a timeline graph for the given trial data.

    :param: trial_data: DataFrame containing trial data.
    :param: output_path: Path where the graph will be saved.

    :return: None
    """
    visualization.fixation_timeline(trial_data)
    plt.savefig(output_path, dpi=300, bbox_inches='tight')