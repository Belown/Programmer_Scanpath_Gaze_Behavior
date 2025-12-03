"""
Parallel generation of random scanpath pairs and multimatch computation with progress tracking
"""
import pandas as pd
import numpy as np
from scipy import stats
import os
from multiprocessing import Pool, cpu_count
from functools import partial
import sys

# Add tools to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../..'))
from tools.auxiliary import gen_random_fixations
from tools.path import setup_paths
import multimatch_gaze as m

# Try to import tqdm for better progress bar, fallback to manual tracking
try:
    from tqdm import tqdm
    HAS_TQDM = True
except ImportError:
    HAS_TQDM = False
    print("Note: Install tqdm for better progress bars: pip install tqdm")


def compute_single_multimatch(i, best_name, best_params, screensize=[1920, 1080]):
    """
    Generate one random scanpath pair and compute multimatch scores.
    
    Args:
        i: Sample index
        best_name: Best distribution name ('normal', 'lognormal', or 'gamma')
        best_params: Parameters for the best distribution
        screensize: Screen resolution [width, height]
    
    Returns:
        Dictionary with sample results
    """
    # Generate random lengths for two scanpaths
    if best_name == 'normal':
        lengths = stats.norm.rvs(*best_params, size=2)
    elif best_name == 'lognormal':
        lengths = stats.lognorm.rvs(*best_params, size=2)
    elif best_name == 'gamma':
        lengths = stats.gamma.rvs(*best_params, size=2)
    
    length_1 = int(round(lengths[0]))
    length_2 = int(round(lengths[1]))
    
    # Generate random fixations for both scanpaths
    random_vec_1 = gen_random_fixations(length_1).rename(columns={'x0': 'start_x', 'y0': 'start_y'})
    random_vec_2 = gen_random_fixations(length_2).rename(columns={'x0': 'start_x', 'y0': 'start_y'})
    
    # Compute multimatch scores
    mm_score = m.docomparison(random_vec_1, random_vec_2, screensize=screensize)
    
    # Return results
    return {
        'sample_id': i + 1,
        'length_1': length_1,
        'length_2': length_2,
        'Shape': mm_score[0],
        'Direction': mm_score[1],
        'Length': mm_score[2],
        'Position': mm_score[3],
        'Duration': mm_score[4]
    }


def generate_random_multimatch_parallel(k_samples, best_name, best_params, 
                                       output_path, n_jobs=None, screensize=[1920, 1080],
                                       progress_interval=100):
    """
    Generate k random scanpath pairs and compute multimatch scores in parallel with progress tracking.
    
    Args:
        k_samples: Number of random pairs to generate
        best_name: Best distribution name from fitting
        best_params: Parameters for the best distribution
        output_path: Base output path for saving results
        n_jobs: Number of parallel jobs (default: cpu_count())
        screensize: Screen resolution [width, height]
        progress_interval: Print progress every N samples (only used if tqdm not available)
    
    Returns:
        DataFrame with results
    """
    if n_jobs is None:
        n_jobs = cpu_count()
    
    print(f"Generating {k_samples} random multimatch results using {n_jobs} parallel workers...")
    
    # Create partial function with fixed parameters
    compute_func = partial(compute_single_multimatch, 
                          best_name=best_name, 
                          best_params=best_params,
                          screensize=screensize)
    
    # Parallel processing with progress tracking
    with Pool(processes=n_jobs) as pool:
        if HAS_TQDM:
            # Use tqdm for nice progress bar
            results = list(tqdm(
                pool.imap(compute_func, range(k_samples)),
                total=k_samples,
                desc="Processing",
                unit="sample"
            ))
        else:
            # Manual progress tracking using imap_unordered for better performance
            results = []
            completed = 0
            for result in pool.imap_unordered(compute_func, range(k_samples), chunksize=max(1, k_samples // (n_jobs * 4))):
                results.append(result)
                completed += 1
                if completed % progress_interval == 0 or completed == k_samples:
                    print(f"Processed {completed}/{k_samples} samples ({100*completed/k_samples:.1f}%)")
            
            # Sort by sample_id since imap_unordered doesn't preserve order
            results.sort(key=lambda x: x['sample_id'])
    
    # Create DataFrame from results
    df_mm_results = pd.DataFrame(results)
    
    # Save to CSV file
    output_csv_path = os.path.join(output_path, "basic_dataset_study", "EMIP", "rand_mm_dataset.csv")
    os.makedirs(os.path.dirname(output_csv_path), exist_ok=True)
    df_mm_results.to_csv(output_csv_path, index=False)
    
    print(f"\nSaved results to {output_csv_path}")
    
    return df_mm_results


if __name__ == "__main__":
    # Example usage
    paths = setup_paths()
    output_base_path = os.path.join(paths['output_path'], "basic_dataset_study", "EMIP")
    os.makedirs(output_base_path, exist_ok=True)
    
    # Load and fit distribution (example)
    df = pd.read_csv(os.path.join(output_base_path, "length_list.csv"))
    data = df['length']

    
    # Fit distributions
    fits = {}
    params_norm = stats.norm.fit(data)
    loglik_norm = np.sum(stats.norm.logpdf(data, *params_norm))
    aic_norm = 2 * 2 - 2 * loglik_norm
    fits['normal'] = (aic_norm, params_norm)
    
    params_logn = stats.lognorm.fit(data, floc=0)
    loglik_logn = np.sum(stats.lognorm.logpdf(data, *params_logn))
    aic_logn = 2 * 2 - 2 * loglik_logn
    fits['lognormal'] = (aic_logn, params_logn)
    
    params_gamma = stats.gamma.fit(data, floc=0)
    loglik_gamma = np.sum(stats.gamma.logpdf(data, *params_gamma))
    aic_gamma = 2 * 2 - 2 * loglik_gamma
    fits['gamma'] = (aic_gamma, params_gamma)
    
    best_name = min(fits, key=lambda k: fits[k][0])
    best_aic, best_params = fits[best_name]

    print(f"Best distribution: {best_name}")

    distribution_info = {
        'distribution_name': best_name,
        'aic': best_aic,
    }

    if best_name == 'normal':
        distribution_info['param_mu'] = best_params[0]
        distribution_info['param_sigma'] = best_params[1]
    elif best_name == 'lognormal':
        distribution_info['param_s'] = best_params[0]
        distribution_info['param_loc'] = best_params[1]
        distribution_info['param_scale'] = best_params[2]
    elif best_name == 'gamma':
        distribution_info['param_a'] = best_params[0]
        distribution_info['param_loc'] = best_params[1]
        distribution_info['param_scale'] = best_params[2]

    distribution_df = pd.DataFrame([distribution_info])
    distribution_info_path = os.path.join(output_base_path, "distribution_info.csv")
    distribution_df.to_csv(distribution_info_path, index=False)
    print(f"Distribution info saved to: {distribution_info_path}")

    # Generate results
    df_results = generate_random_multimatch_parallel(
        k_samples=1000,
        best_name=best_name,
        best_params=best_params,
        output_path=paths['output_path'],
        n_jobs=None,  # Use all CPU cores
        progress_interval=100  # Print progress every 100 samples (if tqdm not available)
    )
