from ..path import setup_paths
from .build_vector import build_vector_cr
import pandas as pd
import os

def parse_cr_data(info = False):
    """
    Parse the Code Rendering dataset.

    :param: info: If True, print information about the dataset

    :return: Parsed pandas DataFrame organized by expertise and render type in matrix form
    """
    paths = setup_paths()
    corrected_cr_path = paths['cr_dataset']

    # read all file names in the cr_dataset folder
    files = os.listdir(corrected_cr_path)

    # Build a matrix to store data vectors
    data_frames = {}

    for file in files:
        if file.endswith('.csv'):
            if file == "metadata.csv":
                continue
            file_path = os.path.join(corrected_cr_path, file)
            if info:
                print(f"Processing file: {file_path}")
            expertise, render, id, df = build_vector_cr(file_path)
            if expertise not in data_frames:
                data_frames[expertise] = {}
            if render not in data_frames[expertise]:
                data_frames[expertise][render] = []
            data_frames[expertise][render].append((expertise, render, id, df))
    return data_frames