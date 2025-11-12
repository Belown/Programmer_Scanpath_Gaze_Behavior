import os, sys

def setup_paths():
    '''
    Set up and manage file paths for the project.

    :return: Dictionary containing various important paths
    '''

    tools_path = os.path.dirname(os.path.abspath(__file__))
    src_path = os.path.dirname(tools_path)

    # The base path for the project
    home_path = os.path.dirname(src_path)

    # Path to the EMIP-Toolkit library
    lib_path = os.path.join(home_path, "src", "EMIP-Toolkit")
    # Path to the metadata file from EMIP dataset
    metadata_file = os.path.join(lib_path, "emtk", "datasets", "EMIP", "EMIP-Toolkit- replication package", "emip_dataset", "emip_metadata.csv")
    # Path to the corrected EMIP dataset
    corrected_dataset = os.path.join(lib_path, "emtk", "datasets", "Corrected EMIP Dataset", "finalset_line_part.csv")

    # Paths for query files and output
    query_path = os.path.join(src_path, "query", "emip_query.json")
    query_output_path = os.path.join(src_path, "query", "output")

    # Output path for images
    output_path = os.path.join(home_path, "output")
    os.makedirs(output_path, exist_ok=True)

    return {
        "tools_path": tools_path,
        "src_path": src_path,
        "home_path": home_path,
        "lib_path": lib_path,
        "metadata_file": metadata_file,
        "corrected_dataset": corrected_dataset,
        "query_path": query_path,
        "query_output_path": query_output_path,
        "output_path": output_path
    }