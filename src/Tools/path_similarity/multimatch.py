import multimatch_gaze as m
import pandas as pd
from ..auxiliary import build_vector_emip, gen_random_fixations

def multimatch_emip(
    exp_a: tuple,
    exp_b: tuple,
    eye_events: pd.DataFrame,
):
    '''
    Compute scanpath similarity by using the library multimatch_gaze
    
    :param: exp_a: Tuple of (experiment_id, trial_id) for first scanpath
    :param: exp_b: Tuple of (experiment_id, trial_id) for second scanpath
    :param: eye_events: Parsed data frame for eye event, can be either corrected EMIP or original EMIP

    :return: path similarity score
    '''

    fix_vec1 = build_vector_emip(exp_a, eye_events).rename(columns={'x0': 'start_x', 'y0': 'start_y'})
    fix_vec2 = build_vector_emip(exp_b, eye_events).rename(columns={'x0': 'start_x', 'y0': 'start_y'})

    if fix_vec1.size == 0 or fix_vec2.size == 0:
        print(f"No matching data for {exp_a} and {exp_b}")
        raise SystemExit("No matching data")

    score = make_dict(m.docomparison(fix_vec1, fix_vec2, screensize=[1920, 1080]))

    return score

def make_dict(score):
    '''
    Convert the multimatch score list into a dictionary for better readability.
    
    :param: score: List of multimatch scores.
    
    :return: Dictionary of multimatch scores.
    '''
    score_names = ["Shape", "Direction", "Length", "Position", "Duration"]
    score_dict = {}
    for name, val in zip(score_names, score):
        score_dict[name] = val
    return score_dict


