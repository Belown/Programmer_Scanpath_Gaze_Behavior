import os
import sys
import pandas as pd
from concurrent.futures import ProcessPoolExecutor, as_completed
from multiprocessing import cpu_count
import argparse
from ..path_similarity import multimatch_emip, nld, scasim
from ..path import setup_paths

try:
    from tqdm.auto import tqdm
    HAS_TQDM = True
except ImportError:
    HAS_TQDM = False
    print("tqdm not intalled.")

paths = setup_paths()

_global_eye_events = None
def _init_eye_events(eye_events):
    global _global_eye_events
    _global_eye_events = eye_events

def compare_experiment_pair(exp_a, exp_b, trial_id, expertise, algo):
    eye_events = _global_eye_events
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
    trial_id = str(trial_id)

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
        if algo == "NLD":
            scores = nld(
                exp_a=(exp_a, trial_id),
                exp_b=(exp_b, trial_id),
                eye_events=eye_events,
                data_set="corrected"
            )
        elif algo == "ScaSim":
            scores = scasim(
                exp_a=(exp_a, trial_id),
                exp_b=(exp_b, trial_id),
                eye_events=eye_events,
                data_set="corrected",
                normalize="duration"
            )
        else:  # Default to MultiMatch
            scores = multimatch_emip(
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
        # Add scores directly
        row.update(scores)
        return row
    except Exception as e:
        print(f"Error comparing {exp_a} and {exp_b}: {e}")
        return None


def within_group_comparison(query_output_path, eye_events, trial_id, dataset, algo, max_workers=None):
    """
    Perform within-group comparison using multimatch for each group in the specified directory.

    :param: query_output_path: Path to the directory containing group_ids.
    :param: eye_events: DataFrame containing eye event data.
    :param: trial_id: The trial ID to use for the comparison.
    :param: dataset: Specify which data set we have used.
    :param: algo: Algorithm to use (e.g., NLD, ScaSim, MultiMatch).
    :param: max_workers: Number of parallel workers (default: CPU count).

    :return: Dictionary containing comparison results for each group.
    """
    if max_workers is None:
        max_workers = cpu_count()
    
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

        # Prepare all comparison tasks
        comparison_tasks = []
        for i, exp_a in enumerate(group_ids):
            for j, exp_b in enumerate(group_ids):
                if i < j:  # Avoid self-comparison
                    # Get expertise for both experiments
                    expertise_a = group_data[group_data["experiment_id"] == exp_a]["expertise_experiment_language"].iloc[0]
                    expertise_b = group_data[group_data["experiment_id"] == exp_b]["expertise_experiment_language"].iloc[0]
                    expertise = (expertise_a, expertise_b)
                    comparison_tasks.append((exp_a, exp_b, trial_id, expertise, algo))

        # Perform pairwise comparison within the group using ProcessPoolExecutor
        group_results = []
        total_tasks = len(comparison_tasks)
        print(f"  Total comparisons to perform: {total_tasks}")
        
        with ProcessPoolExecutor(
            max_workers=max_workers,
            initializer=_init_eye_events,
            initargs=(eye_events,)
        ) as executor:
            # Submit all tasks
            future_to_task = {
                executor.submit(compare_experiment_pair, *task): task
                for task in comparison_tasks
            }
            
            # Collect results (with progress bar)
            if HAS_TQDM:
                for future in tqdm(as_completed(future_to_task), total=total_tasks, 
                                 desc=f"  {group_file}", unit="pair"):
                    result = future.result()
                    if result:
                        group_results.append(result)
            else:
                completed = 0
                for future in as_completed(future_to_task):
                    result = future.result()
                    if result:
                        group_results.append(result)
                    completed += 1
                    if completed % 100 == 0 or completed == total_tasks:
                        print(f"  Progress: {completed}/{total_tasks} ({100*completed/total_tasks:.1f}%)")

        # Store results for the group
        results[group_file] = group_results

        df_results = pd.DataFrame(group_results)
        df_results_filtered = filter_duplicates(df_results)

        # Save the results for the current group to a local file
        os.makedirs(os.path.join(comparation_output_dir, "within_group", f"trial_{str(trial_id)}"), exist_ok=True)
        output_file = os.path.join(comparation_output_dir, "within_group", f"trial_{str(trial_id)}", f"{group_file.replace('.csv', f'_results.csv')}")
        df_results_filtered.to_csv(output_file, index=False)
        print(f"Results for group {group_file} saved to {output_file}\n")

    return results


def between_group_comparison(query_output_path, eye_events, trial_id, dataset, algo, max_workers=None):
    """
    Perform between-group comparison using multimatch for experiments in different groups.

    :param: query_output_path: Path to the directory containing group_ids.
    :param: eye_events: DataFrame containing eye event data.
    :param: trial_id: The trial ID to use for the comparison.
    :param: dataset: Specify which data set we have used.
    :param: algo: Algorithm to use (e.g., NLD, ScaSim, MultiMatch).
    :param: max_workers: Number of parallel workers (default: CPU count).
    
    :return: Dictionary containing comparison results for each group pair.
    """
    if max_workers is None:
        max_workers = cpu_count()
    
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

            # Prepare all comparison tasks
            comparison_tasks = []
            for exp_a in group_ids_a:
                for exp_b in group_ids_b:
                    if exp_a != exp_b:  # Avoid self-comparison
                        # Get expertise for both experiments from their respective groups
                        expertise_a = group_data_a[group_data_a["experiment_id"] == exp_a]["expertise_experiment_language"].iloc[0]
                        expertise_b = group_data_b[group_data_b["experiment_id"] == exp_b]["expertise_experiment_language"].iloc[0]
                        expertise = (expertise_a, expertise_b)
                        comparison_tasks.append((exp_a, exp_b, trial_id, expertise, algo))

            # Perform pairwise comparison between the groups using ProcessPoolExecutor
            group_results = []
            total_tasks = len(comparison_tasks)
            print(f"  Total comparisons to perform: {total_tasks}")
            
            with ProcessPoolExecutor(
                max_workers=max_workers,
                initializer=_init_eye_events,
                initargs=(eye_events,)
            ) as executor:
                # Submit all tasks
                # NOTE: `comparison_tasks` already stores the full argument tuple
                # (exp_a, exp_b, trial_id, expertise, algo). We must unpack it here.
                future_to_task = {
                    executor.submit(compare_experiment_pair, *task): task
                    for task in comparison_tasks
                }
                
                # Collect results (with progress bar)
                if HAS_TQDM:
                    for future in tqdm(as_completed(future_to_task), total=total_tasks,
                                     desc=f"  {group_file_a} vs {group_file_b}", unit="pair"):
                        result = future.result()
                        if result:
                            group_results.append(result)
                else:
                    completed = 0
                    for future in as_completed(future_to_task):
                        result = future.result()
                        if result:
                            group_results.append(result)
                        completed += 1
                        if completed % 100 == 0 or completed == total_tasks:
                            print(f"  Progress: {completed}/{total_tasks} ({100*completed/total_tasks:.1f}%)")

            # Store results for the group pair
            group_pair_key = f"{group_file_a}_vs_{group_file_b}"
            results[group_pair_key] = group_results

            df_results = pd.DataFrame(group_results)
            df_results_filtered = filter_duplicates(df_results)

            # Save the results for the current group pair to a local file
            os.makedirs(os.path.join(comparation_output_dir, "between_group", f"trial_{str(trial_id)}"), exist_ok=True)
            output_file = os.path.join(comparation_output_dir, "between_group", f"trial_{str(trial_id)}", f"{group_file_a.replace('.csv', '')}_{group_file_b.replace('.csv', '')}_results.csv")
            df_results_filtered.to_csv(output_file, index=False)
            print(f"Results for group pair {group_file_a} vs {group_file_b} saved to {output_file}")

    return results


def filter_duplicates(df: pd.DataFrame):
    '''
    Filter dataframe that has symmetric exp_a and exp_b entries to only keep one of them.
    :param df: DataFrame from .csv file.

    :return: filtered DataFrame.
    '''
    if df.empty:
        return df
    
    df = df.copy()
    df['pair_id'] = df[['exp_a', 'exp_b']].apply(
        lambda row: tuple(sorted([str(row['exp_a']), str(row['exp_b'])])), 
        axis=1
    )
    df = df.drop_duplicates(subset='pair_id', keep='first')
    df = df.drop(columns='pair_id')
    return df


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Run parallel multimatch comparison',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Usage examples:
  # Run within-group comparison
  python -m Code.src.tools.comparison --dataset EMIP_corrected --trial_id 2 --comparison_type within --workers 8
  
  # Run all comparison
  python -m Code.src.tools.comparison --dataset EMIP_corrected --trial_id 2 --comparison_type both
        """
    )
    
    parser.add_argument('--dataset', required=True, 
                       help='dataset name (e.g., EMIP)')
    parser.add_argument('--trial_id', type=int, required=True, 
                       help='trial ID')
    parser.add_argument('--comparison_type', choices=['within', 'between', 'both'], 
                       default='both', 
                       help='comparison type: within (within-group), between (between-group), or both (Default: both)')
    parser.add_argument('--algo', type=str, default=None, 
                       help='Algorithm to use (e.g., NLD, ScaSim, MultiMatch)')
    parser.add_argument('--workers', type=int, default=None, 
                       help=f'Concurrent workers number (Default:{cpu_count()})')
    
    args = parser.parse_args()

    algo = args.algo if args.algo else "MultiMatch"

    output_base_dir = os.path.join(paths["output_path"], "processed_dataset", algo)
    os.makedirs(output_base_dir, exist_ok=True)
    
    print("="*60)
    print("Parallel Comparison Script")
    print("="*60)
    print(f"Dataset: {args.dataset}")
    print(f"Trial ID: {args.trial_id}")
    print(f"Comparison Type: {args.comparison_type}")
    print(f"Concurrent Workers: {args.workers or cpu_count()}")
    print("="*60)
    
    # Load eye event data
    print("\nLoading eye event data...")

    from ..auxiliary import parse_corrected_emip_data
    eye_events = parse_corrected_emip_data()
    print(f"Loaded {len(eye_events)} eye event records")
    
    from ..path import setup_paths
    paths = setup_paths()
    # Set query output path
    query_output_path = os.path.join(paths["src_path"], "query", "output", f"experiment_language", f"expertise_experiment_language")
    
    if not os.path.exists(query_output_path):
        print(f"\nError: Query results path does not exist: {query_output_path}")
        exit(1)
    
    # Run comparisons
    if args.comparison_type in ['within']:
        print("\n" + "="*60)
        print("Running within-group comparison...")
        print("="*60)
        within_group_comparison(
            query_output_path, 
            eye_events, 
            args.trial_id, 
            args.dataset,
            algo=algo,
            max_workers=args.workers
        )
    
    if args.comparison_type in ['between']:
        print("\n" + "="*60)
        print("Running between-group comparison...")
        print("="*60)
        between_group_comparison(
            query_output_path, 
            eye_events, 
            args.trial_id, 
            args.dataset,
            algo=algo,
            max_workers=args.workers
        )
    
    print("\n" + "="*60)
    print("All comparisons completed!")
    print("="*60)
