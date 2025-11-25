import os
import pandas as pd
from ..path import setup_paths
from emtk.parsers.EMIP import read_SMIRed250
from emtk.parsers.eye_events import get_eye_event_columns
from emtk.parsers.samples import get_samples_columns

paths = setup_paths()
lib_path = paths["lib_path"]

# Constants
EYE_TRACKER = "SMIRed250"
RAWDATA_MODULE = os.path.join(lib_path, "emtk", "datasets", "EMIP", "EMIP-Toolkit- replication package", "emip_dataset", "rawdata")
STIMULI_MODULE = os.path.join(lib_path, "emtk", "datasets", "EMIP", "EMIP-Toolkit- replication package", "emip_dataset", "stimuli")
SAMPLE_BASE_COLUMNS = ['Time', 'Type', 'Trial', 'L Raw X [px]', 'L Raw Y [px]', 'R Raw X [px]',
                       'R Raw Y [px]', 'L Dia X [px]', 'L Dia Y [px]', 'L Mapped Diameter [mm]',
                       'R Dia X [px]', 'R Dia Y [px]', 'R Mapped Diameter [mm]', 'L CR1 X [px]',
                       'L CR1 Y [px]', 'L CR2 X [px]', 'L CR2 Y [px]', 'R CR1 X [px]', 'R CR1 Y [px]',
                       'R CR2 X [px]', 'R CR2 Y [px]', 'L POR X [px]', 'L POR Y [px]', 'R POR X [px]',
                       'R POR Y [px]', 'Timing', 'L Validity', 'R Validity', 'Pupil Confidence',
                       'L Plane', 'R Plane', 'L EPOS X', 'L EPOS Y', 'L EPOS Z', 'R EPOS X', 'R EPOS Y',
                       'R EPOS Z', 'L GVEC X', 'L GVEC Y', 'L GVEC Z', 'R GVEC X', 'R GVEC Y',
                       'R GVEC Z', 'Frame', 'Aux1']


def parse_single_experiment(experiment_id):
    """
    Parse a single experiment's eye events and samples from the raw data.
    
    :param: experiment_id: Experiment ID to parse
    
    :return: Tuple of (eye_events DataFrame, samples DataFrame)
    """

    eye_events = []
    samples = []

    # Check if raw data directory exists
    if not os.path.isdir(RAWDATA_MODULE):
        raise FileNotFoundError(f"Raw data directory not found: {RAWDATA_MODULE}")

    # Search for the experiment file in the raw data directory
    experiment_found = False
    for root, _, files in os.walk(RAWDATA_MODULE):
        for file in files:
            if not file.endswith(".tsv"):
                continue

            # Require exact id before the first underscore
            file_id = file.split("_", 1)[0]
            if file_id == experiment_id:
                experiment_found = True
                print(f"Parsing experiment: {experiment_id} from file: {file}")

                # Parse the experiment file
                new_eye_events, new_samples = read_SMIRed250(
                    root_dir=root,
                    filename=file,
                    experiment_id=experiment_id,
                )

                eye_events.extend(new_eye_events)
                samples.extend(new_samples)
                break

        if experiment_found:
            break

    if not experiment_found:
        raise ValueError(f"Experiment ID {experiment_id} not found in raw data directory.")

    # Convert eye events and samples to DataFrames
    eye_events_df = pd.DataFrame(eye_events, columns=get_eye_event_columns())
    samples_df = pd.DataFrame(samples, columns=get_samples_columns(SAMPLE_BASE_COLUMNS))

    # Convert numeric columns
    id_dfs = samples_df[["experiment_id", "participant_id", "trial_id"]]
    samples_df = samples_df.apply(convert_numeric)
    samples_df[id_dfs.columns] = id_dfs

    return eye_events_df, samples_df

def convert_numeric(series):
    try:
        return pd.to_numeric(series)
    except (ValueError, TypeError):
        return series