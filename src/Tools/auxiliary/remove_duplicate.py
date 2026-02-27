import pandas as pd
import os
import hashlib
from typing import Tuple, Dict

def filter_duplicates(df: pd.DataFrame):
    '''
    Filter dataframe that has symmetric exp_a and exp_b entries to only keep one of them.
    :param df: DataFrame from .csv file.

    :return: filtered DataFrame.
    '''
    df = df.copy()
    df['pair_id'] = df.apply(lambda x: tuple(sorted([x['exp_a'], x['exp_b']])), axis=1)
    df = df.drop_duplicates(subset='pair_id', keep='first')
    df = df.drop(columns='pair_id')
    return df