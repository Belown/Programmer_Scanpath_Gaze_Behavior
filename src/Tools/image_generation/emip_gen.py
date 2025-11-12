import os
import pandas as pd
import matplotlib.pyplot as plt
from typing import Optional
from ..path import setup_paths
from emtk import visualization

# set up paths
paths = setup_paths()
metadata_file = paths["metadata_file"]
query_path = paths["query_path"]
output_dir = paths["output_path"]


def emip_gen(
    exp: tuple,
    eye_events: pd.DataFrame,
    samples: pd.DataFrame,
    image_type: Optional[str] = None, # "heatmap", "fixation_duration", "fixation_timeline", "all"
    compare_exp: Optional[tuple] = None,
):
    
    '''
    Generate eye-tracking visualization images from EMIP dataset.

    :param: exp: Tuple of (experiment_id, trial_id) to generate images for
    :param: eye_events: Pre-parsed eye events DataFrame. If None, will parse the data.
    :param: samples: Pre-parsed samples DataFrame.
    :param: image_type: Type of image to generate. Options are "heatmap", "fixation_duration", "fixation_timeline", "all". If None, generates default graph.
    :param: compare_exp: Tuple of (experiment_id, trial_id) to compare with using overlapped heatmap. If provided, will generate comparison heatmap instead.

    :return: None
    '''

    if eye_events is None or not isinstance(eye_events, pd.DataFrame) or eye_events.empty:
        raise ValueError("eye_events is required and must be a non-empty pandas.DataFrame")
    if samples is None or not isinstance(samples, pd.DataFrame) or samples.empty:
        raise ValueError("samples is required and must be a non-empty pandas.DataFrame")
    
    # If compare_exp is provided, generate comparison heatmap
    if compare_exp is not None:
        compare_experiments_heatmap(exp, compare_exp, eye_events, output_dir)
        return

    experiment_id, trial_id = exp
    
    # convert to string for matching
    exp_id_str = str(experiment_id)

    # Filter eye_events and samples for the specified experiment_id and trial_id
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
        raise SystemExit("No matching data")

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
    visualization.draw_trial(
            trial_data, samples_data, draw_raw_data=True, draw_aoi=True, draw_saccade=True,
            sample_x_col="R POR X [px]", sample_y_col="R POR Y [px]",
            save_image = output_path
    )

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
    img = visualization.fixation_duration(trial_data)
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
    plt.close()

def overlapped_heatmap(tuple1, tuple2, output_path, alpha=0.6, colors=['red', 'blue']):
    """
    Helper function for compare_experiments_heatmap.

    :param: tuple1: Tuple containing (trial_data1, exp1), where exp1 is (experiment_id, trial_id).
    :param: tuple2: Tuple containing (trial_data2, exp2), where exp2 is (experiment_id, trial_id).
    :param: output_path: Path to save the overlapped heatmap.
    :param: alpha: Transparency level for overlapping (0-1).
    :param: colors: List of colors for each heatmap ['color1', 'color2'].

    :return: None
    """
    import seaborn as sns
    from matplotlib.patches import Patch
    from emtk.util import _get_meta_data, _get_stimuli

    trial_data1, exp1 = tuple1
    trial_data2, exp2 = tuple2
    
    # Get metadata and stimuli (assuming both experiments use same stimuli)
    eye_tracker, stimuli_module, stimuli_name = _get_meta_data(
        trial_data1, "eye_tracker", "stimuli_module", "stimuli_name"
    )
    stimuli = _get_stimuli(stimuli_module, stimuli_name, eye_tracker)
    
    # Extract fixations from both datasets
    fixations1 = trial_data1.loc[trial_data1["eye_event_type"] == "fixation"]
    fixations2 = trial_data2.loc[trial_data2["eye_event_type"] == "fixation"]
    
    # Create figure and axis
    fig, ax = plt.subplots(figsize=(15, 10))
    
    # Display background stimuli
    ax.imshow(stimuli)
    
    # Track if we have any plots for legend
    legend_elements = []
    
    # Draw first heatmap
    if not fixations1.empty:
        x_cords1 = fixations1["x0"]
        y_cords1 = fixations1["y0"]
        sns.kdeplot(ax=ax, x=x_cords1, y=y_cords1,
                    color=colors[0], fill=True,
                    thresh=0.5, alpha=alpha)
        legend_elements.append(Patch(facecolor=colors[0], alpha=alpha, 
                                   label=f"Exp {exp1[0]}, Trial {exp1[1]}"))
    
    # Draw second heatmap
    if not fixations2.empty:
        x_cords2 = fixations2["x0"]
        y_cords2 = fixations2["y0"]
        sns.kdeplot(ax=ax, x=x_cords2, y=y_cords2,
                    color=colors[1], fill=True,
                    thresh=0.5, alpha=alpha)
        legend_elements.append(Patch(facecolor=colors[1], alpha=alpha, 
                                   label=f"Exp {exp2[0]}, Trial {exp2[1]}"))
    
    # Add legend only if we have elements
    if legend_elements:
        ax.legend(handles=legend_elements)
    
    ax.set_title('Overlapped Heatmap Comparison')
    
    # Save and close
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.show()

def compare_experiments_heatmap(exp1, exp2, eye_events, output_dir):
    """
    Generate overlapped heatmap.

    :param: exp1: Tuple of (experiment_id, trial_id) for the first experiment.
    :param: exp2: Tuple of (experiment_id, trial_id) for the second experiment.
    :param: eye_events: DataFrame containing eye event data.
    :param: output_dir: Directory to save the comparison image.

    :return: None
    """
    experiment_id1, trial_id1 = exp1
    experiment_id2, trial_id2 = exp2
    
    # Get trial data for both experiments
    trial_data1 = eye_events.loc[
        (eye_events['experiment_id'] == str(experiment_id1)) &
        (eye_events['trial_id'] == trial_id1)
    ]
    
    trial_data2 = eye_events.loc[
        (eye_events['experiment_id'] == str(experiment_id2)) &
        (eye_events['trial_id'] == trial_id2)
    ]
    
    if trial_data1.empty or trial_data2.empty:
        print("One or both experiments have no data")
        return
    
    # Generate overlapped heatmap
    filename = f"comparison_exp{experiment_id1}_trial{trial_id1}_vs_exp{experiment_id2}_trial{trial_id2}_heatmap.png"
    output_path = os.path.join(output_dir, filename)

    overlapped_heatmap((trial_data1,exp1), (trial_data2,exp2), output_path, alpha=0.6, colors=['red', 'blue'])
    print(f"Overlapped heatmap saved to: {output_path}")
    plt.close()

