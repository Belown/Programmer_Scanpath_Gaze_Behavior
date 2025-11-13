import os
import pandas as pd
from concurrent.futures import ThreadPoolExecutor
from .path_similarity import multimatch
from .path import setup_paths

paths = setup_paths()
output_base_dir = os.path.join(paths["output_path"], "processed_dataset")
os.makedirs(output_base_dir, exist_ok=True)


def compare_experiment_pair(exp_a, exp_b, trial_id, eye_events, expertise):
    """
    Compare a pair of experiments using multimatch.

    :param: exp_a: Experiment ID for the first experiment.
    :param: exp_b: Experiment ID for the second experiment.
    :param: trial_id: Trial ID for both experiments.
    :param: eye_events: DataFrame containing eye event data.
    :param: expertise: Tuple containing expertise levels for both experiments.

    :return: Dictionary containing comparison results for the pair.
    """
    # Ensure exp_a and exp_b are strings
    exp_a = str(exp_a)
    exp_b = str(exp_b)

    # Check if trial_id is valid for exp_a and exp_b
    valid_trial_a = not eye_events[
        (eye_events["experiment_id"] == exp_a) & (eye_events["trial_id"] == trial_id)
    ].empty
    valid_trial_b = not eye_events[
        (eye_events["experiment_id"] == exp_b) & (eye_events["trial_id"] == trial_id)
    ].empty

    if not valid_trial_a or not valid_trial_b:
        return None
    
    expertise_a, expertise_b = expertise

    try:
        scores = multimatch(
            exp_a=(exp_a, trial_id),
            exp_b=(exp_b, trial_id),
            eye_events=eye_events,
        )
        row = {
            "exp_a": exp_a,
            "exp_b": exp_b,
            "trial_id": trial_id,
            "expertise_a": expertise_a,
            "expertise_b": expertise_b,
        }
        row.update(scores.get("final_score", {}))
        return row
    except Exception as e:
        print(f"Error comparing {exp_a} and {exp_b}: {e}")
        return None


def within_group_comparison(query_output_path, eye_events, trial_id, dataset):
    """
    Perform within-group comparison using multimatch for each group in the specified directory.

    :param: query_output_path: Path to the directory containing group_ids.
    :param: eye_events: DataFrame containing eye event data.
    :param: trial_id: The trial ID to use for the comparison.
    :param: dataset: Specify which data set we have used.

    :return: Dictionary containing comparison results for each group.
    """
    results = {}

    # Ensure the output directory exists
    comparation_output_dir = os.path.join(output_base_dir, dataset)
    os.makedirs(comparation_output_dir, exist_ok=True)

    # Iterate through each group folder
    for group_file in os.listdir(query_output_path):
        group_path = os.path.join(query_output_path, group_file)

        # Skip if not a CSV file
        if not group_file.endswith(".csv"):
            continue

        # Read group IDs
        group_data = pd.read_csv(group_path)
        group_ids = group_data["experiment_id"].tolist()

        print(f"Processing group: {group_file} with {len(group_ids)} IDs with trial_id {trial_id}")

        # Perform pairwise comparison within the group using ThreadPoolExecutor
        group_results = []
        with ThreadPoolExecutor() as executor:
            futures = []
            for i, exp_a in enumerate(group_ids):
                for j, exp_b in enumerate(group_ids):
                    if i != j:  # Avoid self-comparison
                        # Get expertise for both experiments
                        expertise_a = group_data[group_data["experiment_id"] == exp_a]["expertise_experiment_language"].iloc[0]
                        expertise_b = group_data[group_data["experiment_id"] == exp_b]["expertise_experiment_language"].iloc[0]
                        expertise = (expertise_a, expertise_b)
                        
                        futures.append(
                            executor.submit(compare_experiment_pair, exp_a, exp_b, trial_id, eye_events, expertise)
                        )
            
            for future in futures:
                result = future.result()
                if result:
                    group_results.append(result)
        # Store results for the group
        results[group_file] = group_results

        # Save the results for the current group to a local file
        os.makedirs(os.path.join(comparation_output_dir, "within_group", f"trial_{str(trial_id)}"), exist_ok=True)
        output_file = os.path.join(comparation_output_dir, "within_group", f"trial_{str(trial_id)}", f"{group_file.replace('.csv', f'_results.csv')}")
        pd.DataFrame(group_results).to_csv(output_file, index=False)
        print(f"Results for group {group_file} saved to {output_file}")

    return results

def between_group_comparison(query_output_path, eye_events, trial_id, dataset):
    """
    Perform between-group comparison using multimatch for experiments in different groups.

    :param: query_output_path: Path to the directory containing group_ids.
    :param: eye_events: DataFrame containing eye event data.
    :param: data_set: Specify which data set to use ("original" or "corrected").
    :param: trial_id: The trial ID to use for the comparison.
    :param: dataset: Specify which data set we have used.
    
    :return: Dictionary containing comparison results for each group pair.
    """
    results = {}

    # Ensure the output directory exists
    comparation_output_dir = os.path.join(output_base_dir, dataset)
    os.makedirs(comparation_output_dir, exist_ok=True)

    # Get all group files
    group_files = [f for f in os.listdir(query_output_path) if f.endswith(".csv")]

    # Perform pairwise comparison between groups
    for i, group_file_a in enumerate(group_files):
        for j, group_file_b in enumerate(group_files):
            if i >= j:  # Avoid self-comparison and duplicate comparisons
                continue

            group_path_a = os.path.join(query_output_path, group_file_a)
            group_path_b = os.path.join(query_output_path, group_file_b)

            # Read group IDs
            group_data_a = pd.read_csv(group_path_a)
            group_data_b = pd.read_csv(group_path_b)
            group_ids_a = group_data_a["experiment_id"].tolist()
            group_ids_b = group_data_b["experiment_id"].tolist()

            print(f"Processing groups: {group_file_a} vs {group_file_b} with trial_id {trial_id}")

            # Perform pairwise comparison between the groups using ThreadPoolExecutor
            group_results = []
            with ThreadPoolExecutor() as executor:
                futures = []
                for exp_a in group_ids_a:
                    for exp_b in group_ids_b:
                        if exp_a != exp_b:  # Avoid self-comparison
                            # Get expertise for both experiments from their respective groups
                            expertise_a = group_data_a[group_data_a["experiment_id"] == exp_a]["expertise_experiment_language"].iloc[0]
                            expertise_b = group_data_b[group_data_b["experiment_id"] == exp_b]["expertise_experiment_language"].iloc[0]
                            expertise = (expertise_a, expertise_b)
                            
                            futures.append(
                                executor.submit(compare_experiment_pair, exp_a, exp_b, trial_id, eye_events, expertise)
                            )
                
                for future in futures:
                    result = future.result()
                    if result:
                        group_results.append(result)

            # Store results for the group pair
            group_pair_key = f"{group_file_a}_vs_{group_file_b}"
            results[group_pair_key] = group_results

            # Save the results for the current group pair to a local file
            os.makedirs(os.path.join(comparation_output_dir, "between_group", f"trial_{str(trial_id)}"), exist_ok=True)
            output_file = os.path.join(comparation_output_dir, "between_group", f"trial_{str(trial_id)}", f"{group_file_a.replace('.csv', '')}_{group_file_b.replace('.csv', '')}_results.csv")
            pd.DataFrame(group_results).to_csv(output_file, index=False)
            print(f"Results for group pair {group_file_a} vs {group_file_b} saved to {output_file}")

    return results
