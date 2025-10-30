import pandas as pd
import json
from ..path import setup_paths

paths = setup_paths()
metadata_file = paths["metadata_file"]
query_path = paths["query_path"]

def metadata_query(
    data: pd.DataFrame
):
    '''
    Query metadata file based on input JSON file (in the folder called 'query') and return list of experiment ids that are contained in the input data.

    :return: List of experiment ids matching the query
    '''
    
    # read metadata from EMIP dataset
    metadata = pd.read_csv(metadata_file)

    exp_id_dataset = data["experiment_id"].unique().tolist()

    try:
        with open(query_path, 'r') as f:
            input_dict = json.load(f)
    except FileNotFoundError:
        print(f"Query file {query_path} not found. Using default query parameters.")
        raise SystemExit("Query file not found")

    # add masks to filter experiment ids
    condition = pd.Series([True] * len(metadata))
    for key, value in input_dict.items():
        if value:
            condition &= (metadata[key] == value)
    result = metadata[condition]

    # Ensure the result is also in the exp_id_dataset
    experiment_ids = result["id"].tolist()

    filtered_experiment_ids = [str(exp_id) for exp_id in experiment_ids if str(exp_id) in exp_id_dataset]

    return filtered_experiment_ids