from ..path import setup_paths
from .build_vector import build_vector_cr
import pandas as pd
import os

def parse_cr_data(info = False):
    """
    Parse the Code Rendering dataset.

    :param: info: If True, print information about the dataset

    :return: Nested dictionary dict[expertise][render] that contain a tuple (expertise, render, id, DataFrame). The DataFrame contains the data vectors for each code rendering sample.
    """
    paths = setup_paths()
    corrected_cr_path = paths['cr_dataset']

    # read all file names in the cr_dataset folder
    files = os.listdir(corrected_cr_path)

    # Build a matrix to store data vectors
    result = {}

    for file in files:
        if file.endswith('.csv'):
            if file == "metadata.csv":
                continue
            file_path = os.path.join(corrected_cr_path, file)
            if info:
                print(f"Processing file: {file_path}")
            expertise, render, id, df = build_vector_cr(file_path)
            if expertise not in result:
                result[expertise] = {}
            if render not in result[expertise]:
                result[expertise][render] = []
            result[expertise][render].append((expertise, render, id, df))
    return result