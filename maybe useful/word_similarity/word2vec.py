import numpy as np
from gensim.models import KeyedVectors
from ..path import setup_paths
import os
from random import sample

paths = setup_paths()
src_path = paths["src_path"]
model_path = os.path.join(src_path, "Dataset", "GoogleNews-vectors-negative300.bin")
model = KeyedVectors.load_word2vec_format(model_path, binary=True)

def word2vec(
    word_list_1, 
    word_list_2 = ["Shape", "Length", "Direction", "Position", "Duration"]
):
    '''
    Function that use word2vec model and compute the semantic similarity between words from 2 given lsit.

    :param: word_list_1: First word list.
    :param: word_list_2: Second word list. If it is not given, then the default list is ["Shape", "Length", "Direction", "Position", "Duration"]

    :return: return a dictionary which contain the score. Where the key are tuple of (word_1, word_2)
    '''
    
    print(model.vectors.shape)

    dict = {}

    for word_1 in word_list_1:
        for word_2 in word_list_2:
            similarity = model.similarity(word_1, word_2)
            dict[(word_1, word_2)] = similarity
            print(f"Similarity between '{word_1}' and '{word_2}': {similarity:.4f}")

    return dict

def average_similarity(number):
    '''
    This function return the average similarity between random words in the word2vec model.

    :param: number: Number of random pairs to sample.

    :return: average similarity score.
    '''
    words = list(model.key_to_index.keys())
    sims = []

    for _ in range(number):
        w1, w2 = sample(words, 2)
        sims.append(model.similarity(w1, w2))

    baseline = np.mean(sims)
    print("Average random similarity:", baseline)
    return baseline

    

