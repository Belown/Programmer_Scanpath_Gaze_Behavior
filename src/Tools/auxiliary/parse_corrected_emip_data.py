from ..path import setup_paths
import pandas as pd

def parse_corrected_emip_data(info = False):
    """
    Parse the corrected EMIP dataset from the given path.

    :param: path: Path to the corrected EMIP dataset CSV file

    :return: Parsed pandas DataFrame
    """
    paths = setup_paths()
    corrected_emip_path = paths['corrected_dataset']

    # Load the data
    emip_df = pd.read_csv(corrected_emip_path)

    # Drop the first unnamed column of df
    emip_df.drop(emip_df.columns[0], axis=1, inplace=True)

    # Add columns required for build_vector function
    emip_df['eye_event_type'] = 'fixation'
    emip_df['eye_tracker'] = 'SMIRed250'
    emip_df['stimuli_module'] = 'emtk/datasets/EMIP/EMIP-Toolkit- replication package/emip_dataset/stimuli'
    emip_df['stimuli_name'] = emip_df['code_file']

    # Change column names to match with build_vector function
    emip_df.rename(columns={'x_cord': 'x0', 'y_cord': 'y0'}, inplace=True)
    emip_df.rename(columns={'participant': 'experiment_id', 'trial': 'trial_id'}, inplace=True)

    # Ensure experiment_id and trial_id are strings (remove surrounding whitespace)
    emip_df['experiment_id'] = emip_df['experiment_id'].astype(str).str.strip()
    emip_df['trial_id'] = emip_df['trial_id'].astype(str).str.strip()

    # Create 'aoi_name' column for nld
    emip_df['aoi_name'] = 'line ' + emip_df['line'].astype(str) + ' ' + 'part ' + emip_df['part'].astype(str)

    print(f"Processing data for {len(emip_df['experiment_id'].unique())} participants...")

    if info:
        print("Available corrected EMIP data for experiments:")
        unique_ids = emip_df['experiment_id'].dropna().unique()
        sorted_ids = sorted(unique_ids, key=lambda x: int(x) if x.isdigit() else x)
        print("sorted_ids:", sorted_ids)

    return emip_df