import os
import pandas as pd
from concurrent.futures import ThreadPoolExecutor
from .path_similarity import multimatch

def compare_experiment_pair(exp_a, exp_b, trial_id, eye_events, data_set):
    """
    Compare a pair of experiments using multimatch.

    :param exp_a: Experiment ID for the first experiment.
    :param exp_b: Experiment ID for the second experiment.
    :param trial_id: Trial ID for both experiments.
    :param eye_events: DataFrame containing eye event data.
    :param data_set: Specify which data set to use ("original" or "corrected").
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

    try:
        scores = multimatch(
            exp_a=(exp_a, trial_id),
            exp_b=(exp_b, trial_id),
            eye_events=eye_events,
            data_set=data_set,
        )
        row = {
            "exp_a": exp_a,
            "exp_b": exp_b,
            "trial_id": trial_id,
        }
        row.update(scores.get("original_score", {}))
        return row
    except Exception as e:
        print(f"Error comparing {exp_a} and {exp_b}: {e}")
        return None


def within_group_comparison(base_path, eye_events, data_set="corrected", output_dir="comparison_results"):
    """
    Perform within-group comparison using multimatch for each group in the specified directory.

    :param base_path: Path to the directory containing group_ids.
    :param eye_events: DataFrame containing eye event data.
    :param data_set: Specify which data set to use ("original" or "corrected").
    :param output_dir: Directory to save the comparison results.
    :return: Dictionary containing comparison results for each group.
    """
    results = {}
    trial_id = '2'

    # Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Iterate through each group folder
    for group_file in os.listdir(base_path):
        group_path = os.path.join(base_path, group_file)

        # Skip if not a CSV file
        if not group_file.endswith(".csv"):
            continue

        # Read group IDs
        group_data = pd.read_csv(group_path)
        group_ids = group_data["experiment_id"].tolist()

        print(f"Processing group: {group_file} with {len(group_ids)} IDs")

        # Perform pairwise comparison within the group using ThreadPoolExecutor
        group_results = []
        with ThreadPoolExecutor() as executor:
            futures = [
                executor.submit(compare_experiment_pair, exp_a, exp_b, trial_id, eye_events, data_set)
                for i, exp_a in enumerate(group_ids)
                for j, exp_b in enumerate(group_ids)
                if i < j  # Avoid duplicate comparisons and self-comparison
            ]
            for future in futures:
                result = future.result()
                if result:
                    group_results.append(result)

        # Store results for the group
        results[group_file] = group_results

        # Save the results for the current group to a local file
        output_file = os.path.join(output_dir, f"{group_file.replace('.csv', f'_trial_id_{trial_id}_results.csv')}")
        pd.DataFrame(group_results).to_csv(output_file, index=False)
        print(f"Results for group {group_file} saved to {output_file}")

    return results
