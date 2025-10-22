import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def gen_random_fixations(n, screensize=(1920, 1080), seed=None):
    """
    Generate n random fixations as a baseline scanpath, following
    Dewhurst et al. (2012)'s uniform sampling logic.
    Each fixation has start_x, start_y (pixels) and duration (seconds).
    """
    dtype = [('start_x', 'f8'), ('start_y', 'f8'), ('duration', 'f8')]
    if n <= 0:
        return np.zeros(0, dtype=dtype)
    
    if seed is not None:
        np.random.seed(seed)
    
    arr = np.zeros(n, dtype=dtype)
    margin_x = 0.05 * screensize[0]
    margin_y = 0.05 * screensize[1]
    
    arr['start_x'] = np.random.uniform(margin_x, screensize[0] - margin_x, size=n)
    arr['start_y'] = np.random.uniform(margin_y, screensize[1] - margin_y, size=n)
    arr['duration'] = np.random.uniform(800, 1500, size=n) / 1000.0  # in seconds
    
    return arr

def visualize_multimatch_scores(score, title="Multimatch Scores"):
    """
    Create a bar chart to visualize multimatch scores with adaptive y-axis
    
    Args:
        score: Dictionary with multimatch scores
        title: Title for the plot
    """
    # Get the score metrics and values
    categories = list(score.keys())
    values = [score[key] for key in categories]
    
    # Create the plot
    fig, ax = plt.subplots(figsize=(12, 6))
    
    # Create bars with different colors
    bar_colors = ['#2C3E50', '#34495E', '#566573', '#78909C', '#90A4AE']
    bars = ax.bar(categories, values, color=bar_colors, width=0.6)
    
    # Add value annotations on top of each bar
    for i, bar in enumerate(bars):
        height = bar.get_height()
        if height >= 0:
            y_pos = height + 0.01 * (max(values) - min(values))
        else:
            y_pos = height - 0.04 * (max(values) - min(values))
        ax.text(bar.get_x() + bar.get_width()/2., y_pos,
                f'{values[i]:.3f}', ha='center', fontsize=10)
    
    # Customize plot with adaptive y-axis
    # Find min and max values to set y-axis limits with some padding
    min_val = min(values)
    max_val = max(values)
    y_range = max_val - min_val
    
    # Add 20% padding to top and bottom (or at least to accommodate zero line)
    y_min = min(min_val - 0.2 * y_range, -0.05)  # Ensure negative values are visible
    y_max = max_val + 0.2 * y_range
    
    # Ensure zero is included if close to the range
    if min_val > 0 and min_val < 0.2 * y_range:
        y_min = 0
    
    ax.set_ylim(y_min, y_max)
    ax.set_ylabel('Score Value', fontsize=12)
    ax.set_title(title, fontsize=16)
    ax.grid(axis='y', linestyle='--', alpha=0.7)
    
    # Add a horizontal line at y=0
    ax.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    
    # Rotate x-axis labels for better readability if needed
    plt.xticks(fontsize=12)
    
    plt.tight_layout()
    return fig, ax

def visualize_all_scores(all_scores):
    """
    Create a grouped bar chart comparing original, baseline, and final scores
    with adaptive y-axis
    
    Args:
        all_scores: Dictionary containing original_score, base_line_score, and final_score
    """
    # Get categories (metric names)
    categories = list(all_scores["original_score"].keys())
    
    # Values for each score type
    original_values = [all_scores["original_score"][key] for key in categories]
    baseline_values = [all_scores["base_line_score"][key] for key in categories]
    final_values = [all_scores["final_score"][key] for key in categories]
    
    # Set up positions
    x = np.arange(len(categories))
    width = 0.25  # Width of bars
    
    # Create plot
    fig, ax = plt.subplots(figsize=(14, 7))
    
    # Create bars
    bars1 = ax.bar(x - width, original_values, width, label='Original', color='#3498db')
    bars2 = ax.bar(x, baseline_values, width, label='Baseline', color='#e74c3c')
    bars3 = ax.bar(x + width, final_values, width, label='Normalized', color='#2ecc71')
    
    # Collect all values for y-axis scaling
    all_values = original_values + baseline_values + final_values
    min_val = min(all_values)
    max_val = max(all_values)
    y_range = max_val - min_val
    
    # Set adaptive padding for text labels
    text_padding = 0.01 * y_range
    
    # Add value annotations
    def add_labels(bars):
        for bar in bars:
            height = bar.get_height()
            if height >= 0:
                y_pos = height + text_padding
            else:
                y_pos = height - 3 * text_padding
            ax.text(bar.get_x() + bar.get_width()/2., y_pos,
                    f'{height:.3f}', ha='center', fontsize=9, rotation=0)
    
    add_labels(bars1)
    add_labels(bars2)
    add_labels(bars3)
    
    # Customize plot with adaptive y-axis
    # Add 20% padding to top and bottom
    y_min = min(min_val - 0.2 * y_range, -0.05)  # Ensure negative values are visible
    y_max = max_val + 0.2 * y_range
    
    # Ensure zero is included if close to the range
    if min_val > 0 and min_val < 0.2 * y_range:
        y_min = 0
        
    ax.set_ylim(y_min, y_max)
    ax.set_ylabel('Score Value', fontsize=12)
    ax.set_title('Comparison of Multimatch Scores', fontsize=16)
    ax.set_xticks(x)
    ax.set_xticklabels(categories, fontsize=12)
    ax.legend(loc='upper right')
    ax.grid(axis='y', linestyle='--', alpha=0.7)
    
    # Add a horizontal line at y=0
    ax.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    
    plt.tight_layout()
    return fig, ax