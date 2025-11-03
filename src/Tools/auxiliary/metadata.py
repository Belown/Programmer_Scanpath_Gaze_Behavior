import os
import pandas as pd
import json
from ..path import setup_paths

paths = setup_paths()
metadata_file = paths["metadata_file"]
query_path = paths["query_path"]
query_output_path = paths["query_output_path"]

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
    applied_filters_key = []  # To store applied filters for the filename
    applied_filters_value = []  # To store applied filters for the filename
    for key, value in input_dict.items(): 
        if value:
            print(f"Possible value for {key} are {metadata[key].unique().tolist()}")
            condition &= (metadata[key] == value)
            applied_filters_key.append(key)  # Add filter key to the list
            applied_filters_value.append(value)  # Add filter value to the list
    result = metadata[condition]

    # Ensure the result is also in the exp_id_dataset
    experiment_ids = result["id"].tolist()

    filtered_experiment_ids = [str(exp_id) for exp_id in experiment_ids if str(exp_id) in exp_id_dataset]

    # Save the filtered experiment IDs to the query output path
    os.makedirs(query_output_path, exist_ok=True)

    # Create hierarchical folder structure based on applied filters
    if applied_filters_key:
        # Start with the query output path
        current_path = query_output_path
        
        # Create nested folders for each filter key
        for filter_key in applied_filters_key:
            current_path = os.path.join(current_path, filter_key)
            os.makedirs(current_path, exist_ok=True)
        
        # Generate filename based on all applied values
        filters_str = "_".join(str(value) for value in applied_filters_value) if applied_filters_value else "no_filters"
        filename = f"{filters_str}.csv"
        file_path = os.path.join(current_path, filename)
    else:
        # No filters applied
        filename = "no_filters.csv"
        file_path = os.path.join(query_output_path, filename)

    # Save the filtered experiment IDs
    pd.DataFrame(filtered_experiment_ids, columns=["experiment_id"]).to_csv(file_path, index=False)
    print(f"Filtered experiment IDs saved to {file_path}")

    return filtered_experiment_ids