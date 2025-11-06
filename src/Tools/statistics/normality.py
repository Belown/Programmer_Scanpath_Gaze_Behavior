import pandas as pd
from scipy.stats import shapiro
import os

def normality_test(data_dir, if_graph = False, trial_id = None):

    """
    Perform Shapiro-Wilk normality test on multiple CSV files in a directory.

    :param: data_dir: Directory containing CSV files with dimensions data
    :param: if_graph: Boolean flag to indicate whether to plot histograms
    
    :return: Dictionary with normality results for each dimension
    """
        
    # Define the five dimensions
    dimensions = ["Shape", "Length", "Direction", "Position", "Duration"]

    data_dir = os.path.join(data_dir, f"trial_{trial_id}")

    # Dictionary to store normality results for each dimension
    normality_results = {dim: {"normal": 0, "not_normal": 0, "result": None} for dim in dimensions}

    # Iterate through all CSV files in the directory
    for file_name in os.listdir(data_dir):
        if file_name.endswith(".csv"):
            file_path = os.path.join(data_dir, file_name)
            print(f"Processing file: {file_name}")
            
            # Load the data
            df = pd.read_csv(file_path)
            
            # Run Shapiro-Wilk test for each dimension
            for dim in dimensions:
                if dim in df.columns:
                    stat, p = shapiro(df[dim])
                    if p > 0.05:
                        normality_results[dim]["normal"] += 1
                    else:
                        normality_results[dim]["not_normal"] += 1
                else:
                    print(f"  {dim:10s}  → Dimension not found in file ❌")

    # Determine majority normality for each dimension
    print("\nOverall normality results based on majority:")
    for dim, results in normality_results.items():
        normal_count = results["normal"]
        not_normal_count = results["not_normal"]
        if normal_count > not_normal_count:
            normality_results[dim]["result"] = "Likely normal"
            print(f"{dim:10s} → Likely normal ✅ (Normal: {normal_count}, Not normal: {not_normal_count})")
        else:
            normality_results[dim]["result"] = "Not normal"
            print(f"{dim:10s} → Not normal ❌ (Normal: {normal_count}, Not normal: {not_normal_count})")

    if if_graph:
        import matplotlib.pyplot as plt
        import seaborn as sns
        for dim in dimensions:
            plt.figure(figsize=(6,4))
            sns.histplot(df[dim], kde=True)
            plt.title(f"{dim} distribution")
            plt.show()
    
    return normality_results