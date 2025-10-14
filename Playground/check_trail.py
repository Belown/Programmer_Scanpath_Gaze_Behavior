import os
import pandas as pd

# Folder containing your .tsv files
folder_path = r'D:\Storage\ETH\Thesis\EMIP-Toolkit\emtk\datasets\EMIP\EMIP-Toolkit- replication package\emip_dataset\rawdata'

# Dictionary to store participant trial counts
participant_trials = {}

# Loop through all .tsv files in the folder
for filename in os.listdir(folder_path):
    if filename.endswith('.tsv'):
        file_path = os.path.join(folder_path, filename)
        
        with open(file_path, 'r', encoding='utf-8') as f:
            for i, line in enumerate(f):
                if not line.startswith('#'):
                    header_line = i
                    break

        df = pd.read_csv(file_path, sep='\t', header=header_line)
        
        # 用文件名前缀作为 participant_id
        participant_id = filename.split('_')[0]
        # 试着用 'Trial' 作为 trial 字段名
        if 'Trial' in df.columns:
            trial_count = df['Trial'].nunique()
            participant_trials[participant_id] = trial_count
        else:
            print(f"{filename}: No 'Trial' column found.")

# Find participants with exactly 2 trials
participants_with_2_trials = [p for p, count in participant_trials.items() if count > 1]

print("Participants with 2 trials:", participants_with_2_trials)