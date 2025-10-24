import multimatch_gaze as m
import numpy as np
import sys, os
import pandas as pd
from tools.auxiliary import gen_random_fixations, build_vector

def multimatch(
    exp_a: tuple,
    exp_b: tuple,
    eye_events: pd.DataFrame
):
    '''
    Compute scanpath similarity by using the library multimatch_gaze
    :param exp_a: Tuple of (experiment_id, trial_id) for first scanpath
    :param exp_b: Tuple of (experiment_id, trial_id) for second scanpath
    :param eye_events: Parsed data frame for eye event
    :return: path similarity score
    '''
    exp_id_str_a, trial_id_str_a = exp_a
    exp_id_str_b, trial_id_str_b = exp_b

    fix_vec1 = build_vector(exp_id_str_a, trial_id_str_a, eye_events)
    fix_vec2 = build_vector(exp_id_str_b, trial_id_str_b, eye_events)

    random_vec1 = gen_random_fixations(len(fix_vec1))
    random_vec2 = gen_random_fixations(len(fix_vec2))

    if fix_vec1.size == 0 or fix_vec2.size == 0:
        print("No matching data")
        raise SystemExit("No matching data")

    score = m.docomparison(fix_vec1, fix_vec2, screensize=[1920, 1080])

    original_score_dict = make_dict(score)
    
    base_line_score = m.docomparison(random_vec1, random_vec2, screensize=[1920, 1080])

    base_line_score_dict = make_dict(base_line_score)
    
    final_score_dict = {}
    for name in original_score_dict.keys():
        final_score_dict[name] = original_score_dict[name] - base_line_score_dict[name]

    return {
        "original_score": original_score_dict,
        "base_line_score": base_line_score_dict,
        "final_score": final_score_dict
    }

def make_dict(score):
    score_names = ["Shape", "Length", "Direction", "Position", "Duration"]
    score_dict = {}
    if isinstance(score, list) and len(score) == 1 and isinstance(score[0], list):
        for name, val in zip(score_names, score[0]):
            score_dict[name] = val
    else:
        for name, val in zip(score_names, score):
            score_dict[name] = val
    return score_dict

