"""
Fixed version of Code Rendering dataset processing
Addresses the hardcoded index issue in between-group comparisons
"""

from tools.path import setup_paths
from tools.auxiliary.parse_cr_data import parse_cr_data
import pandas as pd
import os
import multimatch_gaze as m

# Setup
paths = setup_paths()
parsed_data = parse_cr_data(False)

print(f"Finishing parsing CR data")
print(f"Number of expertise level: {len(parsed_data)} {list(parsed_data.keys())}")

# Get all expertise levels and rendering types
expertise_levels = list(parsed_data.keys())
rendering_types = list(parsed_data[expertise_levels[0]].keys())

print(f"Number of rendering types: {len(rendering_types)} {rendering_types}")

# Display the matrix structure
print("\nData matrix structure:")
for expertise in expertise_levels:
    for render in rendering_types:
        if render in parsed_data[expertise]:
            print(f"{expertise} - {render}: {len(parsed_data[expertise][render])} csv files")
        else:
            print(f"{expertise} - {render}: Not available")

# ====================
# Comparison A: Within expertise, within rendering (CORRECT - no changes needed)
# ====================
print("\n" + "="*60)
print("Comparison A: Within expertise, within rendering")
print("="*60)

dimensions = ["Shape", "Direction", "Length", "Position", "Duration"]
output_path = os.path.join(paths["output_path"], "processed_dataset", "code_rendering")

for expertise in expertise_levels:
    for render in rendering_types:
        exps = parsed_data[expertise][render]
        print(f"{expertise} - {render}: {len(exps)} items")
        
        results = []
        
        for i in range(len(exps)):
            expertise_a, render_a, id_a, vec_i = exps[i]
            
            for j in range(len(exps)):
                if j <= i:  # ✅ Correct: avoid symmetric and self-comparison
                    continue
                
                expertise_b, render_b, id_b, vec_j = exps[j]
                multimatch_result = m.docomparison(vec_i, vec_j, screensize=[1920, 1080])
                
                row = {
                    'exp_a': id_a,
                    'exp_b': id_b,
                    'expertise_a': expertise_a,
                    'expertise_b': expertise_b,
                    'render_a': render_a,
                    'render_b': render_b
                }
                
                for dim, value in zip(dimensions, multimatch_result):
                    row[dim] = value
                
                results.append(row)
        
        df = pd.DataFrame(results)
        
        output_dir = os.path.join(output_path, "within_expertise_rendering")
        os.makedirs(output_dir, exist_ok=True)
        output_file = os.path.join(output_dir, f"{expertise}_{render}_result.csv")
        df.to_csv(output_file, index=False)
        print(f"Saved {len(df)} comparisons to {output_file}")

# ====================
# Comparison B: Within rendering, change expertise (FIXED)
# ====================
print("\n" + "="*60)
print("Comparison B: Within rendering, change expertise (FIXED)")
print("="*60)

for render in rendering_types:
    exps_list = []
    results = []
    
    for expertise in expertise_levels:
        exps = parsed_data[expertise][render]
        exps_list.append(exps)
    
    # ✅ FIXED: Use nested loops to traverse all expertise combinations
    for exp_idx_a in range(len(exps_list)):
        for exp_idx_b in range(len(exps_list)):
            if exp_idx_a >= exp_idx_b:  # Avoid symmetric and self-comparison
                continue
            
            print(f"  Comparing {expertise_levels[exp_idx_a]} vs {expertise_levels[exp_idx_b]} for rendering {render}")
            
            # Now compare all participant pairs from different expertise levels
            for i in range(len(exps_list[exp_idx_a])):
                expertise_a, render_a, id_a, vec_i = exps_list[exp_idx_a][i]
                
                for j in range(len(exps_list[exp_idx_b])):
                    expertise_b, render_b, id_b, vec_j = exps_list[exp_idx_b][j]
                    
                    multimatch_result = m.docomparison(vec_i, vec_j, screensize=[1920, 1080])
                    
                    row = {
                        'exp_a': id_a,
                        'exp_b': id_b,
                        'expertise_a': expertise_a,
                        'expertise_b': expertise_b,
                        'render_a': render_a,
                        'render_b': render_b
                    }
                    
                    for dim, value in zip(dimensions, multimatch_result):
                        row[dim] = value
                    
                    results.append(row)
    
    df = pd.DataFrame(results)
    
    output_dir = os.path.join(output_path, "within_expertise")
    os.makedirs(output_dir, exist_ok=True)
    output_file = os.path.join(output_dir, f"{render}_result.csv")
    df.to_csv(output_file, index=False)
    print(f"Saved {len(df)} comparisons to {output_file}")

# ====================
# Comparison C: Within expertise, change rendering (FIXED)
# ====================
print("\n" + "="*60)
print("Comparison C: Within expertise, change rendering (FIXED)")
print("="*60)

for expertise in expertise_levels:
    exps_list = []
    results = []
    
    for render in rendering_types:
        exps = parsed_data[expertise][render]
        exps_list.append(exps)
    
    # ✅ FIXED: Use nested loops to traverse all rendering combinations
    for render_idx_a in range(len(exps_list)):
        for render_idx_b in range(len(exps_list)):
            if render_idx_a >= render_idx_b:  # Avoid symmetric and self-comparison
                continue
            
            print(f"  Comparing {rendering_types[render_idx_a]} vs {rendering_types[render_idx_b]} for expertise {expertise}")
            
            # Now compare all participant pairs from different rendering types
            for i in range(len(exps_list[render_idx_a])):
                expertise_a, render_a, id_a, vec_i = exps_list[render_idx_a][i]
                
                for j in range(len(exps_list[render_idx_b])):
                    expertise_b, render_b, id_b, vec_j = exps_list[render_idx_b][j]
                    
                    multimatch_result = m.docomparison(vec_i, vec_j, screensize=[1920, 1080])
                    
                    row = {
                        'exp_a': id_a,
                        'exp_b': id_b,
                        'expertise_a': expertise_a,
                        'expertise_b': expertise_b,
                        'render_a': render_a,
                        'render_b': render_b
                    }
                    
                    for dim, value in zip(dimensions, multimatch_result):
                        row[dim] = value
                    
                    results.append(row)
    
    df = pd.DataFrame(results)
    
    output_dir = os.path.join(output_path, "within_rendering")
    os.makedirs(output_dir, exist_ok=True)
    output_file = os.path.join(output_dir, f"{expertise}_result.csv")
    df.to_csv(output_file, index=False)
    print(f"Saved {len(df)} comparisons to {output_file}")

# ====================
# Merge CSV files
# ====================
print("\n" + "="*60)
print("Merging CSV files")
print("="*60)

from tools.auxiliary.merge_csv_files import merge_csv_files

dirs = [
    os.path.join(output_path, "within_expertise"),
    os.path.join(output_path, "within_expertise_rendering"),
    os.path.join(output_path, "within_rendering")
]

for dir in dirs:
    merge_csv_files(dir)

print("\n" + "="*60)
print("✅ All processing completed!")
print("="*60)