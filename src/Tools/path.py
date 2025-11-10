import os, sys

def setup_paths():
    '''
    Set up and manage file paths for the project.

    :return: Dictionary containing various important paths
    '''
    tools_path = os.path.dirname(os.path.abspath(__file__))
    src_path = os.path.dirname(tools_path)
    home_path = os.path.dirname(src_path)
    lib_path = os.path.join(home_path, "src", "EMIP-Toolkit")
    metadata_file = os.path.join(lib_path, "emtk", "datasets", "EMIP", "EMIP-Toolkit- replication package", "emip_dataset", "emip_metadata.csv")
    query_path = os.path.join(src_path, "query", "emip_query.json")
    query_output_path = os.path.join(src_path, "query", "output")

    corrected_dataset = os.path.join(lib_path, "emtk", "datasets", "Corrected EMIP Dataset", "finalset_line_part.csv")

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